import NIOAdvanced
import ErrorHandle

public extension Error {
    var vaporlized: Abort {
        return errorInterpret(error: self)
        
        @Sendable
        func errorInterpret<T: Error>(error: T) -> Abort {
            if let err = error as? any Err {
                let reason = String(describing: err.error.rawValue) + (err.explain == nil ? "" : ", " + err.explain!)
                
                switch err.category {
                case .external(suggestions: let suggestions):
                    return Abort(
                        .badRequest,
                        reason: reason,
                        identifier: err.error.identifier,
                        suggestedFixes: suggestions,
                        file: err.file,
                        function: err.function,
                        line: .init(err.line)
                    )
                case .inherit:
                    if let subError = err.subError {
                        return errorInterpret(error: subError)
                    }
                    
                    fallthrough
                case .internal:
                    return Abort(
                        .internalServerError,
                        reason: "服务器内部错误",
                        identifier: err.error.identifier,
                        suggestedFixes: ["请联系管理员以解决该错误"],
                        file: err.file,
                        function: err.function,
                        line: .init(err.line)
                    )
                case .none: fatalError("错误处理系统异常")
                }
            } else {
                return Abort(
                    .internalServerError,
                    reason: "服务器内部错误",
                    identifier: "Unknown",
                    suggestedFixes: ["请联系管理员以解决该错误"]
                )
            }
        }
    }
}

public extension EventLoopResult {
    var vaporlized: EventLoopFuture<Value> {
        return self.flatMapErrorThrowing { error throws(Abort) in
            throw error.vaporlized
        }.wrapped
    }
}
