import XCTest
@testable import LMDB

final class LMDBTests: XCTestCase {
    let dbDirectory = URL(fileURLWithPath: NSTemporaryDirectory().appending("LMDB-tests/db-directory"), isDirectory: true)
    let dbFile = URL(fileURLWithPath: NSTemporaryDirectory().appending("LMDB-tests/db-file/db-file.database"), isDirectory: false)
    
    override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(at: self.dbDirectory.deletingLastPathComponent())
    }
    
    func testShouldReturnVersion() {
        let version = LMDB.version
        let result = version.range(of: #"\d+\.\d+\.\d+"#, options: .regularExpression)
        XCTAssertNotNil(result)
    }
    
    func testShouldReturnBuildDate() {
        let buildDate = LMDB.buildDate
        XCTAssertTrue(buildDate.count > 4)
    }
    
    func testShouldCreateNonDirectoryDatabase() {
        do {
            let lmdb = try LMDB(url: self.dbFile)
            XCTAssertNoThrow(try lmdb.beginTransaction { database in } )
            XCTAssertTrue(FileManager.default.fileExists(atPath: self.dbFile.path))
            XCTAssertTrue(FileManager.default.fileExists(atPath: self.dbFile.path.appending("-lock")))
        } catch let error {
            XCTAssertNil(error)
        }
    }
    
    func testShouldThrowWithNamedDatabaseAndNoMaxDbsSet() {
        let lmdb = try! LMDB(url: self.dbDirectory)
        XCTAssertThrowsError(try lmdb.beginTransaction(onDatabase: "test") { database in })
    }
    
    func testShouldNotThrowWithNamedDatabaseAndMaxDbsSet() {
        let lmdb = try! LMDB(url: self.dbDirectory)
        XCTAssertNoThrow(try lmdb.environment.configure { configuration in
            try configuration.setMaxDbs(1)
        })
        XCTAssertNoThrow(try lmdb.beginTransaction(onDatabase: "test") { database in })
    }
    
    func testShouldPutGetAndDelValues() {
        let key = "master-key".data(using: .utf8)!
        let value = "master-value".data(using: .utf8)!
        
        do {
            let lmdb = try LMDB(url: self.dbDirectory)
            try lmdb.beginTransaction { database in
                XCTAssertEqual(database.stat().entries, 0)
                
                try database.put(value: value, forKey: key)
                XCTAssertEqual(database.stat().entries, 1)
                
                let dbValue = try database.get(key: key)
                XCTAssertEqual(dbValue, value)
                
                try database.del(key: key)
                XCTAssertEqual(database.stat().entries, 0)
                
                let nilDbValue = try database.get(key: key)
                XCTAssertNil(nilDbValue)
            }
        } catch let error {
            XCTAssertNil(error)
        }
    }
    
    func testShouldPutGetAndDelValuesWithCursor() {
        let key = "master-key".data(using: .utf8)!
        let value = "master-value".data(using: .utf8)!
        let key2 = "master-key-2".data(using: .utf8)!
        let value2 = "master-value-2".data(using: .utf8)!
        
        do {
            let lmdb = try LMDB(url: self.dbDirectory)
            try lmdb.beginTransactionWithCursor { database, cursor in
                try cursor.put(value: value, forKey: key)
                try cursor.put(value: value2, forKey: key2)
                
                let dbValue1 = try cursor.get(.last)
                XCTAssertEqual(dbValue1?.key, key2)
                XCTAssertEqual(dbValue1?.value, value2)
                
                let dbValue2 = try cursor.get(.first)
                XCTAssertEqual(dbValue2?.key, key)
                XCTAssertEqual(dbValue2?.value, value)
                
                XCTAssertNoThrow(try cursor.del())
                XCTAssertNoThrow(try cursor.del())
                XCTAssertNil(try cursor.get(.first))
            }
        } catch let error {
            XCTAssertNil(error)
        }
    }
    
    func testShouldSupportDupSortWithCursor() {
        let key1 = "master-key".data(using: .utf8)!
        let value1 = "some".data(using: .utf8)!
        let value2 = "other".data(using: .utf8)!
        let value3 = "another".data(using: .utf8)!
        
        do {
            let lmdb = try LMDB(url: self.dbDirectory)
            try lmdb.beginTransactionWithCursor(flags: [.dupSort, .reverseDup], { (database, cursor) in
                try cursor.put(value: value1, forKey: key1)
                try cursor.put(value: value2, forKey: key1)
                try cursor.put(value: value3, forKey: key1)
                
                _ = try cursor.get(key: key1, .firstDup)
                let dbValue1 = try cursor.get(.getCurrent)
                XCTAssertEqual(dbValue1?.key, key1)
                XCTAssertEqual(dbValue1?.value, value1)
                
                _ = try cursor.get(.nextDup)
                let dbValue2 = try cursor.get(.getCurrent)
                XCTAssertEqual(dbValue2?.key, key1)
                XCTAssertEqual(dbValue2?.value, value2)
                
                _ = try cursor.get(key: key1, .lastDup)
                let dbValue3 = try cursor.get(.getCurrent)
                XCTAssertEqual(dbValue3?.key, key1)
                XCTAssertEqual(dbValue3?.value, value3)
            })
        } catch let error {
            XCTAssertNil(error)
        }
    }

    static var allTests = [
        ("testShouldReturnVersion", testShouldReturnVersion),
        ("testShouldReturnBuildDate", testShouldReturnBuildDate),
        ("testShouldCreateNonDirectoryDatabase", testShouldCreateNonDirectoryDatabase),
        ("testShouldThrowWithNamedDatabaseAndNoMaxDbsSet", testShouldThrowWithNamedDatabaseAndNoMaxDbsSet),
        ("testShouldNotThrowWithNamedDatabaseAndMaxDbsSet", testShouldNotThrowWithNamedDatabaseAndMaxDbsSet),
        ("testShouldPutGetAndDelValues", testShouldPutGetAndDelValues),
        ("testShouldPutGetAndDelValuesWithCursor", testShouldPutGetAndDelValuesWithCursor),
    ]
}
