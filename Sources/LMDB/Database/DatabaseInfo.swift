public struct DatabaseInfo {
    /** Size of a database page. This is currently the same for all databases. */
    public let size: Int
    
    /** Depth (height) of the B-tree */
    public let depth: Int
    
    /** Number of internal (non-leaf) pages */
    public let branchPages: Int
    
    /** Number of leaf pages */
    public let leafPages: Int
    
    /** Number of overflow pages */
    public let overflowPages: Int
    
    /** Number of data items */
    public let entries: Int
}
