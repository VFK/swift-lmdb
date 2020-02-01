import Clmdb

public struct OperationFlags: OptionSet {
    public var rawValue: Int32
    
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
    
    /**
     Enter the new key/data pair only if it does not already appear in the database. This flag may
     only be specified if the database was opened with MDB_DUPSORT. The function will return MDB_KEYEXIST
     if the key/data pair already appears in the database.
     */
    public static let noDupData = OperationFlags(rawValue: MDB_NODUPDATA)
    
    /**
     Enter the new key/data pair only if the key does not already appear in the database.
     The function will return MDB_KEYEXIST if the key already appears in the database, even if the database
     supports duplicates (MDB_DUPSORT). The data parameter will be set to point to the existing item.
     */
    public static let noOverwrite = OperationFlags(rawValue: MDB_NOOVERWRITE)
    
    /**
     Reserve space for data of the given size, but don't copy the given data. Instead, return a pointer
     to the reserved space, which the caller can fill in later - before the next update operation or the
     transaction ends. This saves an extra memcpy if the data is being generated later.
     LMDB does nothing else with this memory, the caller is expected to modify all of the space requested.
     This flag must not be specified if the database was opened with MDB_DUPSORT.
     */
    public static let reserve = OperationFlags(rawValue: MDB_RESERVE)
    
    /**
     Append the given key/data pair to the end of the database. This option allows fast bulk loading when
     keys are already known to be in the correct order. Loading unsorted keys with this flag will
     cause a MDB_KEYEXIST error.
     */
    public static let append = OperationFlags(rawValue: MDB_APPEND)
    
    /**
     As .append, but for sorted dup data.
     */
    public static let appendDup = OperationFlags(rawValue: MDB_APPENDDUP)
}
