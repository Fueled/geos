// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "geos",
    platforms: [.iOS(.v12), .macOS(.v10_13)],
    products: [
        .library(
            name: "geos",
            targets: ["GEOSwiftCore"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "GEOSwiftCore",
            path: "Binaries/GEOSwiftCore.xcframework"
        ),
    ],
    cxxLanguageStandard: .cxx14
)

