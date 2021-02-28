import Foundation
import Clmdb

public class LMDB {
    public let environment: Environment
    private let dbUrl: URL
    private let isReadOnly: Bool
    
    public init(url: URL, isReadOnly: Bool = false) throws {
        self.dbUrl = url
        self.isReadOnly = isReadOnly
        
        try self.environment = Environment(url: url, isReadOnly: isReadOnly)
    }
    
    @available(*, deprecated, renamed: "environment.configure")
    public func configureEnvironment( _ configurationHandle: (EnvironmentConfiguration) throws -> ()) throws {
        try self.environment.configure({ (configuration) in
            try configurationHandle(configuration)
        })
    }
    
    public func beginTransaction(onDatabase name: String? = nil, flags: DatabaseFlags = [], _ transactionHandle: (Database) throws -> ()) throws {
        if !self.environment.isOpened {
            try self.environment.open()
        }
        
        let transaction = Transaction(environment: self.environment, isReadOnly: self.isReadOnly)
        let database = Database(transaction: transaction)
        
        do {
            try transaction.begin()
            try database.open(name: name, flags: flags)
            try transactionHandle(database)
            try transaction.commit()
        } catch let error {
            transaction.abort()
            throw error
        }
    }
    
    public func beginTransactionWithCursor(onDatabase name: String? = nil, flags: DatabaseFlags = [], _ transactionHandle: (Database, Cursor) throws -> ()) throws {
        try self.beginTransaction(onDatabase: name, flags: flags) { database in
            let cursor = Cursor(database: database)
            try cursor.open()
            try transactionHandle(database, cursor)
        }
    }
}

extension LMDB {
    public static var version: String {
        var major: Int32 = 0
        var minor: Int32 = 0
        var patch: Int32 = 0
        
        mdb_version(&major, &minor, &patch)
        
        return "\(major).\(minor).\(patch)"
    }
    
    public static var buildDate: String {
        return MDB_VERSION_DATE
    }
}
