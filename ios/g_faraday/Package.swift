// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "g_faraday",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        // If the plugin name contains "_", replace with "-" for the library name.
        .library(name: "g-faraday", targets: ["g_faraday"])
    ],
    // 注意：不要声明 FlutterFramework 依赖（该 wrapper 包需 Flutter >= 3.44 工具链自动生成），
    // 留空则新旧工具链均可正常解析；Flutter.xcframework 由 App 侧集成提供。
    dependencies: [],
    targets: [
        .target(
            name: "g_faraday",
            dependencies: []
        )
    ]
)
