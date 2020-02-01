// swift-tools-version:5.0

import PackageDescription
let package = Package(
    name: "swift-lmdb",
    platforms: [
        .macOS("10.11")
    ],
    products: [
        .library(
            name: "LMDB",
            targets: ["LMDB"]),
    ],
    targets: [
        .target(
            name: "Clmdb",
            path: "lib/libraries/liblmdb",
            sources: ["midl.h", "midl.c", "mdb.c", "lmdb.h"],
            publicHeadersPath: "."),
        .target(
            name: "LMDB",
            dependencies: ["Clmdb"]),
        .testTarget(
            name: "LMDBTests",
            dependencies: ["LMDB"]),
    ]
)
