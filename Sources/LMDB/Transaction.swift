import Clmdb

public class Transaction {
    let environment: Environment
    let isReadOnly: Bool
    weak var parent: Transaction?
    private(set) var handle: OpaquePointer?
    
    public init(environment: Environment, isReadOnly: Bool = false) {
        self.environment = environment
        self.isReadOnly = isReadOnly
    }
    
    public func addParent(_ parent: Transaction) throws {
        if self.isReadOnly {
            throw LMDBError.userError("Read-only transactions can't be nested.")
        }
        
        self.parent = parent
    }
    
    public func begin() throws {
        let flags = self.isReadOnly ? MDB_RDONLY : 0
        let status = mdb_txn_begin(environment.handle, parent?.handle, UInt32(flags), &handle)
        guard status == 0 else {
            throw LMDBError.lmdbError(status)
        }
    }
    
    public func commit() throws {
        let status = mdb_txn_commit(handle)
        guard status == 0 else {
            throw LMDBError.lmdbError(status)
        }
    }
    
    public func abort() {
        mdb_txn_abort(handle)
    }
}
