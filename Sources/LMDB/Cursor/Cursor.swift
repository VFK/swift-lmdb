import Foundation
import Clmdb

public class Cursor {
    private(set) var isOpened = false
    let database: Database
    
    private(set) var handle: OpaquePointer?
    
    public init(database: Database) {
        self.database = database
    }
    
    public func open() throws {
        let status = mdb_cursor_open(database.transaction.handle, database.handle, &handle)
        guard status == 0 else {
            throw LMDBError.lmdbError(status)
        }
        
        self.isOpened = true
    }
    
    public func get(key: Data? = nil, _ operation: CursorGetOperation) throws -> CursorResult? {
        var lmdbKey = MDB_val()
        
        if let key = key {
            key.withUnsafeBytes {keyPtr in
                let keyAddress = UnsafeMutableRawPointer(mutating: keyPtr.baseAddress)
                lmdbKey = MDB_val(mv_size: key.count, mv_data: keyAddress)
            }
        }
        
        var value = MDB_val()
        
        let status = mdb_cursor_get(handle, &lmdbKey, &value, operation.lmdbValue())
        guard status == 0 || status == MDB_NOTFOUND else {
            throw LMDBError.lmdbError(status)
        }
        
        guard status != MDB_NOTFOUND else {
            return nil
        }
        
        let dataKey = Data(bytes: lmdbKey.mv_data, count: lmdbKey.mv_size)
        let dataValue = Data(bytes: value.mv_data, count: value.mv_size)
        
        return CursorResult(key: dataKey, value: dataValue)
    }
    
    public func put(value: Data, forKey key: Data, _ operation: CursorPutOperation? = nil) throws {
        try key.withUnsafeBytes {keyPtr in
            let keyAddress = UnsafeMutableRawPointer(mutating: keyPtr.baseAddress)
            var lmdbKey = MDB_val(mv_size: key.count, mv_data: keyAddress)
            
            try value.withUnsafeBytes {valuePtr in
                let valueAddress = UnsafeMutableRawPointer(mutating: valuePtr.baseAddress)
                var lmdbValue = MDB_val(mv_size: value.count, mv_data: valueAddress)
                let status = mdb_cursor_put(handle, &lmdbKey, &lmdbValue, UInt32(operation?.lmdbValue() ?? 0))
                guard status == 0 else {
                    throw LMDBError.lmdbError(status)
                }
            }
        }
    }
    
    public func del(allForKey: Bool = false) throws {
        let status = mdb_cursor_del(handle, allForKey ? UInt32(MDB_NODUPDATA) : 0)
        guard status == 0 else {
            throw LMDBError.lmdbError(status)
        }
    }
    
    public func count() throws -> Int {
        var count = 0
        let status = mdb_cursor_count(handle, &count)
        guard status == 0 else {
            throw LMDBError.lmdbError(status)
        }
        
        return count
    }
    
    public func close() {
        if self.isOpened {
            mdb_cursor_close(handle)
        }
    }
    
    deinit {
        self.close()
    }
}
