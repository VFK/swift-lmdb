import Clmdb

public enum LMDBError: Error {
    case lmdbError(_ statusCode: Int32)
    case userError(_ description: String?)
}

extension LMDBError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .lmdbError(statusCode: let code):
            let pointer = mdb_strerror(code)
            return String(cString: pointer!)
        case .userError(description: let description):
            return description ?? "Unknown Error"
        }
    }
}
