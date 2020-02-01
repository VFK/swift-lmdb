public struct EnvironmentInfo {
    /** Address of map, if fixed */
    public let mapAddress: UnsafeMutableRawPointer?
    
    /** Size of the data memory map */
    public let mapSize: Int
    
    /** ID of the last used page */
    public let lastPageId: Int
    
    /** ID of the last committed transaction */
    public let lastTransactionId: Int
    
    /** max reader slots in the environment */
    public let maxReaders: Int
    
    /** max reader slots used in the environment */
    public let numReaders: Int
}
