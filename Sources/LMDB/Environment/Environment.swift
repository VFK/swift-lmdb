import Foundation
import Clmdb

public class Environment {
    public let isReadOnly: Bool
    public let url: URL
    var configuration: EnvironmentConfiguration?
    private(set) var isOpened = false
    private(set) var handle: OpaquePointer?
    private let permissions: UInt16 = 0o755
    
    public init(url: URL, isReadOnly: Bool = false) throws {
        self.isReadOnly = isReadOnly
        self.url = url
        
        try self.prepareFilesystem(for: url)
        
        let status = mdb_env_create(&handle)
        guard status == 0 else {
            throw LMDBError.lmdbError(status)
        }
    }
    
    public func configure(_ configurationHandle: (EnvironmentConfiguration) throws -> ()) throws {
        if self.configuration == nil {
            self.configuration = EnvironmentConfiguration(with: self)
        }

        try configurationHandle(self.configuration!)
    }
    
    public func open() throws {
        try self.configure { (configuration) in
            let status = mdb_env_open(handle, self.url.path.cString(using: .utf8), UInt32(configuration.flags.rawValue), mdb_mode_t(self.permissions))
            guard status == 0 else {
                throw LMDBError.lmdbError(status)
            }
        }
        
        self.isOpened = true
    }
    
    private func prepareFilesystem(for url: URL) throws {
        let isExists = FileManager.default.fileExists(atPath: url.absoluteString)
        guard !isExists else {
            return
        }
        
        let baseUrl =  url.hasDirectoryPath ? url : url.deletingLastPathComponent()
        let attributes: [FileAttributeKey: UInt16] = [.posixPermissions: self.permissions]
        try FileManager.default.createDirectory(at: baseUrl, withIntermediateDirectories: true, attributes: attributes)
    }
    
    public func setMaxDbs(_ maxDbs: Int) throws {
        guard !self.isOpened else {
            throw LMDBError.userError("This function may only be called after mdb_env_create() and before mdb_env_open()")
        }
        
        let status = mdb_env_set_maxdbs(self.handle, MDB_dbi(maxDbs))
        guard status == 0 else {
            throw LMDBError.lmdbError(status)
        }
    }
    
    public func setMaxReaders(_ maxReaders: Int) throws {
        guard !self.isOpened else {
            throw LMDBError.userError("This function may only be called after mdb_env_create() and before mdb_env_open()")
        }
        
        let status = mdb_env_set_maxreaders(self.handle, UInt32(maxReaders))
        guard status == 0 else {
            throw LMDBError.lmdbError(status)
        }
    }
    
    public func setMapSize(_ mapSize: Int) throws {
        let status = mdb_env_set_mapsize(self.handle, mdb_size_t(mapSize))
        guard status == 0 else {
            throw LMDBError.lmdbError(status)
        }
    }
    
    public func setFlags(_ flags: EnvironmentFlags) throws {
        let status = mdb_env_set_flags(self.handle, UInt32(flags.rawValue), 1)
        guard status == 0 else {
            throw LMDBError.lmdbError(status)
        }
    }
    
    public func unsetFlags(_ flags: EnvironmentFlags) throws {
        let status = mdb_env_set_flags(self.handle, UInt32(flags.rawValue), 0)
        guard status == 0 else {
            throw LMDBError.lmdbError(status)
        }
    }
    
    public func getInfo() -> EnvironmentInfo {
        var mdbInfo = MDB_envinfo()
        mdb_env_info(handle, &mdbInfo)
        
        return EnvironmentInfo(
            mapAddress: mdbInfo.me_mapaddr,
            mapSize: mdbInfo.me_mapsize,
            lastPageId: mdbInfo.me_last_pgno,
            lastTransactionId: mdbInfo.me_last_txnid,
            maxReaders: Int(mdbInfo.me_maxreaders),
            numReaders: Int(mdbInfo.me_numreaders)
        )
    }
    
    public func close() {
        if self.isOpened {
            mdb_env_close(handle)
        }
    }
    
    deinit {
        self.close()
    }
}
