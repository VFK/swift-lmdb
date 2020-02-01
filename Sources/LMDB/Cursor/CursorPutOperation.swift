import Clmdb

public enum CursorPutOperation {
    /**
     Replace the item at the current cursor position. The key parameter must still be provided, and must match it.
     If using sorted duplicates (MDB_DUPSORT) the data item must still sort into the same place.
     This is intended to be used when the new data is the same size as the old. Otherwise it will simply perform a delete of the old record followed by an insert.
     */
    case current
    
    /**
     Enter the new key/data pair only if it does not already appear in the database. This flag may only be specified if the database was opened with MDB_DUPSORT.
     The function will return MDB_KEYEXIST if the key/data pair already appears in the database.
     */
    case noDupData
    
    /**
     Enter the new key/data pair only if the key does not already appear in the database.
     The function will return MDB_KEYEXIST if the key already appears in the database, even if the database supports duplicates (MDB_DUPSORT).
     */
    case noOverwrite
    
    /**
     Reserve space for data of the given size, but don't copy the given data. Instead, return a pointer to the reserved space, which the caller can fill in later.
     This saves an extra memcpy if the data is being generated later. This flag must not be specified if the database was opened with MDB_DUPSORT.
     */
    case reserve
    
    /**
     Append the given key/data pair to the end of the database. No key comparisons are performed.
     This option allows fast bulk loading when keys are already known to be in the correct order. Loading unsorted keys with this flag will cause a MDB_KEYEXIST error.
     */
    case append
    
    /**
     Same as APPEND, but for sorted dup data.
     */
    case appendDup
    
    /**
     Store multiple contiguous data elements in a single request. This flag may only be specified if the database was opened with MDB_DUPFIXED.
     The data argument must be an array of two MDB_vals. The mv_size of the first MDB_val must be the size of a single data element.
     The mv_data of the first MDB_val must point to the beginning of the array of contiguous data elements.
     The mv_size of the second MDB_val must be the count of the number of data elements to store.
     On return this field will be set to the count of the number of elements actually written. The mv_data of the second MDB_val is unused.
     */
    case multiple
    
    func lmdbValue() -> Int32 {
        switch self {
        case .current:
            return MDB_CURRENT
        case .noDupData:
            return MDB_NODUPDATA
        case .noOverwrite:
            return MDB_NOOVERWRITE
        case .reserve:
            return MDB_RESERVE
        case .append:
            return MDB_APPEND
        case .appendDup:
            return MDB_APPENDDUP
        case .multiple:
            return MDB_MULTIPLE
        }
    }
}
