import Foundation
import Clmdb

public class Database {
    private(set) var isOpened = false
    public let transaction: Transaction
    private(set) var handle: MDB_dbi = 0
    
    public init(transaction: Transaction) {
        self.transaction = transaction
    }
    
    public func open(name: String?, flags: DatabaseFlags = []) throws {
        var dbFlags = flags
        if name != nil && !self.transaction.isReadOnly && !self.transaction.environment.isReadOnly {
            dbFlags.formUnion(DatabaseFlags(rawValue: MDB_CREATE))
        }
        
        let status = mdb_dbi_open(self.transaction.handle, name?.cString(using: .utf8), UInt32(dbFlags.rawValue), &handle)
        guard status == 0 else {
            throw LMDBError.lmdbError(status)
        }
        
        self.isOpened = true
    }
    
    public func put(value: Data, forKey key: Data, flags: DatabasePutFlags = []) throws {
        try key.withUnsafeBytes {keyPtr in
            let keyAddress = UnsafeMutableRawPointer(mutating: keyPtr.baseAddress)
            var lmdbKey = MDB_val(mv_size: key.count, mv_data: keyAddress)
            
            try value.withUnsafeBytes {valuePtr in
                let valueAddress = UnsafeMutableRawPointer(mutating: valuePtr.baseAddress)
                var lmdbValue = MDB_val(mv_size: value.count, mv_data: valueAddress)
                
                let status = mdb_put(self.transaction.handle, self.handle, &lmdbKey, &lmdbValue, UInt32(flags.rawValue))
                guard status == 0 else {
                    throw LMDBError.lmdbError(status)
                }
            }
        }
    }
    
    public func get(key: Data) throws -> Data? {
        return try key.withUnsafeBytes {keyPtr in
            var lmdbValue = MDB_val()
            let address = UnsafeMutableRawPointer(mutating: keyPtr.baseAddress)
            var lmdbKey = MDB_val(mv_size: key.count, mv_data: address)
            let status = mdb_get(self.transaction.handle, self.handle, &lmdbKey, &lmdbValue)
            guard status == 0 || status == MDB_NOTFOUND else {
                throw LMDBError.lmdbError(status)
            }
            
            return status == MDB_NOTFOUND ? nil : Data(bytes: lmdbValue.mv_data, count: lmdbValue.mv_size)
        }
    }
    
    public func del(key: Data, withValue: Data? = nil) throws {
        try key.withUnsafeBytes {keyPtr in
            let keyAddress = UnsafeMutableRawPointer(mutating: keyPtr.baseAddress)
            var lmdbKey = MDB_val(mv_size: key.count, mv_data: keyAddress)
            
            if let value = withValue {
                try value.withUnsafeBytes {valuePtr in
                    let valueAddress = UnsafeMutableRawPointer(mutating: valuePtr.baseAddress)
                    var lmdbValue = MDB_val(mv_size: value.count, mv_data: valueAddress)
                    
                    let status = mdb_del(self.transaction.handle, self.handle, &lmdbKey, &lmdbValue)
                    guard status == 0 || status == MDB_NOTFOUND else {
                        throw LMDBError.lmdbError(status)
                    }
                }
            } else {
                let status = mdb_del(self.transaction.handle, self.handle, &lmdbKey, nil)
                guard status == 0 || status == MDB_NOTFOUND else {
                    throw LMDBError.lmdbError(status)
                }
            }
        }
    }
    
    public func stat() -> DatabaseInfo {
        var mdbStat = MDB_stat()
        mdb_stat(self.transaction.handle, self.handle, &mdbStat)
        
        return DatabaseInfo(
            size: Int(mdbStat.ms_psize),
            depth: Int(mdbStat.ms_depth),
            branchPages: mdbStat.ms_branch_pages,
            leafPages: mdbStat.ms_leaf_pages,
            overflowPages: mdbStat.ms_overflow_pages,
            entries: mdbStat.ms_entries
        )
    }
    
    public func close() {
        if self.isOpened {
            mdb_dbi_close(self.transaction.environment.handle, self.handle)
        }
    }
    
    deinit {
        self.close()
    }
}
