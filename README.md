# SwiftLMDB [![SPM Version](https://img.shields.io/github/tag/VFK/swift-lmdb.svg?color=success&label=SPM)](https://swift.org/package-manager/)
A wrapper for [LMDB](https://symas.com/lmdb/) written in Swift for [Package Manager](https://swift.org/package-manager/).

Works on all platforms supported by Swift.

## Usage
SwiftLMDB works with [Data](https://developer.apple.com/documentation/foundation/data) types for keys and values.
Let's say you have the following data:
```swift
let key = "master-key".data(using: .utf8)!
let value = "master-value".data(using: .utf8)!
```
You'll also need [filesystem url](https://developer.apple.com/documentation/foundation/nsurl/1417505-init) to a file or a directory like:
```swift
let url = URL(fileURLWithPath: "/usr/local/some-database", isDirectory: true)
```

You can use it like this:
```swift
import LMDB

let lmdb = try LMDB(url: url)
try lmdb.beginTransaction { database in
    try database.put(value: value, forKey: key)
    
    let dbValue = try database.get(key: key)
    
    try database.del(key: key)
}
```

Cursors are also supported:
```swift
import LMDB

let lmdb = try LMDB(url: url)
try lmdb.beginTransactionWithCursor { database, cursor in
    try cursor.put(value: value, forKey: key)
    
    let dbValue = try cursor.get(.first)
    
    try cursor.del()
}
```

* This library abstracts many things. You don't need to create environment, open a database and start/commit/abort transactions, this is all done for you.
* You don't need to create intermediate directories in your path, those will be created if needed.
* Successful transaction commits automatically and if something throws inside `beginTransaction` block - transaction aborts.
* Some lmdb flags are set automatically: if url points to a file - `MDB_NOSUBDIR` will be set on environment. If you pass `isReadOnly` to SwiftLMDB constructor - `MDB_RDONLY` flag will be added etc.

For named databases use `beginTransaction(name: String?, flags: DatabaseFlags?)` but also make sure to `setMaxDbs` to something >0 _before_ this call like:
```swift
let lmdb = try LMDB(url: url)

try lmdb.configureEnvironment { configuration in
    configuration.setMaxDbs(1)
}

try lmdb.beginTransaction(name: "my-database") { database in
    ...
}
```

### Additionally direct mappings to lmdb methods are also provided
You can [follow official guide](http://www.lmdb.tech/doc/starting.html) and do things the way you'd them with the original lmdb library:
```swift
let url = URL(fileURLWithPath: "/usr/local/some-database", isDirectory: true)
let key = "master-key".data(using: .utf8)!
let value = "master-value".data(using: .utf8)!

let environment = try Environment(url: url, isReadOnly: false)
let transaction = Transaction(environment: environment, isReadOnly: false)
let database = Database(transaction: transaction)

try environment.configure { (configiration) in 
    try configuration.setMaxDbs(10)
    try configuration.setFlags([.noSync, .noTls])
}

try environment.open()
try database.open(name: "some-database", flags: [.dupSort])

try transaction.begin()
try database.put(value: value, forKey: key, flags: [.noDupData])
try transaction.commit()
```
