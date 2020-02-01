public struct DatabaseInfo {
    /** Size of a database page. This is currently the same for all databases. */
    let size: Int
    
    /** Depth (height) of the B-tree */
    let depth: Int
    
    /** Number of internal (non-leaf) pages */
    let branchPages: Int
    
    /** Number of leaf pages */
    let leafPages: Int
    
    /** Number of overflow pages */
    let overflowPages: Int
    
    /** Number of data items */
    let entries: Int
}
