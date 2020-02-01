import Clmdb

public enum CursorOperation {
    /** Position at first key/data item */
    case first
    
    /** Position at first data item of current key. Only for MDB_DUPSORT */
    case firstDup
    
    /** Position at key/data pair. Only for MDB_DUPSORT */
    case getBoth
    
    /** position at key, nearest data. Only for MDB_DUPSORT */
    case getBothRange
    
    /** Return key/data at current cursor position */
    case getCurrent
    
    /** Return key and up to a page of duplicate data items from current cursor position. Move cursor to prepare for MDB_NEXT_MULTIPLE. Only for MDB_DUPFIXED */
    case getMultiple
    
    /** Position at last key/data item */
    case last
    
    /** Position at last data item of current key. Only for MDB_DUPSORT */
    case lastDup
    
    /** Position at next data item */
    case next
    
    /** Position at next data item of current key. Only for MDB_DUPSORT */
    case nextDup
    
    /** Return key and up to a page of duplicate data items from next cursor position. Move cursor to prepare for MDB_NEXT_MULTIPLE. Only for MDB_DUPFIXED */
    case nextMultiple
    
    /** Position at first data item of next key */
    case nextNoDup
    
    /** Position at previous data item */
    case prev
    
    /** Position at previous data item of current key. Only for MDB_DUPSORT */
    case prevDup
    
    /** Position at last data item of previous key */
    case prevNoDup
    
    /** Position at specified key */
    case set
    
    /** Position at specified key, return key + data */
    case setKey
    
    /** Position at first key greater than or equal to specified key. */
    case setRange
    
    func lmdbValue() -> MDB_cursor_op {
        switch self {
        case .first:
            return MDB_cursor_op(rawValue: MDB_FIRST.rawValue)
        case .firstDup:
            return MDB_cursor_op(rawValue: MDB_FIRST_DUP.rawValue)
        case .getBoth:
            return MDB_cursor_op(rawValue: MDB_GET_BOTH.rawValue)
        case .getBothRange:
            return MDB_cursor_op(rawValue: MDB_GET_BOTH_RANGE.rawValue)
        case .getCurrent:
            return MDB_cursor_op(rawValue: MDB_GET_CURRENT.rawValue)
        case .getMultiple:
            return MDB_cursor_op(rawValue: MDB_GET_MULTIPLE.rawValue)
        case .last:
            return MDB_cursor_op(rawValue: MDB_LAST.rawValue)
        case .lastDup:
            return MDB_cursor_op(rawValue: MDB_LAST_DUP.rawValue)
        case .next:
            return MDB_cursor_op(rawValue: MDB_NEXT.rawValue)
        case .nextDup:
            return MDB_cursor_op(rawValue: MDB_NEXT_DUP.rawValue)
        case .nextMultiple:
            return MDB_cursor_op(rawValue: MDB_NEXT_MULTIPLE.rawValue)
        case .nextNoDup:
            return MDB_cursor_op(rawValue: MDB_NEXT_NODUP.rawValue)
        case .prev:
            return MDB_cursor_op(rawValue: MDB_PREV.rawValue)
        case .prevDup:
            return MDB_cursor_op(rawValue: MDB_PREV_DUP.rawValue)
        case .prevNoDup:
            return MDB_cursor_op(rawValue: MDB_PREV_NODUP.rawValue)
        case .set:
            return MDB_cursor_op(rawValue: MDB_SET.rawValue)
        case .setKey:
            return MDB_cursor_op(rawValue: MDB_SET_KEY.rawValue)
        case .setRange:
            return MDB_cursor_op(rawValue: MDB_SET_RANGE.rawValue)
        }
    }
}
