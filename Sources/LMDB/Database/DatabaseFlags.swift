import Clmdb

public struct DatabaseFlags: OptionSet {
    public var rawValue: Int32
    
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
    
    /**
     Keys are strings to be compared in reverse order, from the end of the strings to the beginning.
     By default, Keys are treated as strings and compared from beginning to end.
     */
    static let reverseKey = DatabaseFlags(rawValue: MDB_REVERSEKEY)
    
    /**
     Duplicate keys may be used in the database. (Or, from another perspective, keys may have multiple
     data items, stored in sorted order.) By default keys must be unique and may have only a single data item.
     */
    static let dupSort = DatabaseFlags(rawValue: MDB_DUPSORT)
    
    /**
     Keys are binary integers in native byte order, either unsigned int or size_t, and will be sorted as such.
     The keys must all be of the same size.
     */
    static let integerKey = DatabaseFlags(rawValue: MDB_INTEGERKEY)
    
    /**
     This flag may only be used in combination with MDB_DUPSORT. This option tells the library that the data
     items for this database are all the same size, which allows further optimizations in storage and retrieval.
     When all data items are the same size, the MDB_GET_MULTIPLE and MDB_NEXT_MULTIPLE cursor operations may be
     used to retrieve multiple items at once.
     */
    static let dupFixed = DatabaseFlags(rawValue: MDB_DUPFIXED)
    
    /**
     This option specifies that duplicate data items are binary integers, similar to MDB_INTEGERKEY keys.
     */
    static let integerDup = DatabaseFlags(rawValue: MDB_INTEGERDUP)
    
    /**
     This option specifies that duplicate data items should be compared as strings in reverse order.
     */
    static let reverseDup = DatabaseFlags(rawValue: MDB_REVERSEDUP)
}
