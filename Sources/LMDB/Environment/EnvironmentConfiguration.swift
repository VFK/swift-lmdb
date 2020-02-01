import Clmdb

public class EnvironmentConfiguration {
    private weak var environment: Environment?
    internal var flags: EnvironmentFlags = []
    
    public func setMaxDbs(_ maxDbs: Int) throws {
        try self.environment?.setMaxDbs(maxDbs)
    }
    
    public func setMaxReaders(_ maxReaders: Int) throws {
        try self.environment?.setMaxReaders(maxReaders)
    }
    
    public func setMapSize(_ mapSize: Int) throws {
        try self.environment?.setMapSize(mapSize)
    }
    
    public func setFlags(_ flags: EnvironmentFlags) throws {
        self.flags.formUnion(flags)
        
        if let environment = self.environment {
            if environment.isOpened {
                try environment.setFlags(flags)
            }
        }
    }
    
    public func unsetFlags(_ flags: EnvironmentFlags) throws {
        self.flags.subtract(flags)
        
        if let environment = self.environment {
            if environment.isOpened {
                try environment.unsetFlags(flags)
            }
        }
    }
    
    init(with environment: Environment) {
        self.environment = environment
        
        if environment.isReadOnly {
            self.flags.formUnion(EnvironmentFlags(rawValue: MDB_RDONLY))
        }
        
        if !environment.url.hasDirectoryPath {
            self.flags.formUnion(EnvironmentFlags(rawValue: MDB_NOSUBDIR))
        }
    }
}
