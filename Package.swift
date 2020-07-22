// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Blog",
    products: [
        .executable(name: "Blog", targets: ["Blog"])
    ],
    dependencies: [
        .package(url: "https://github.com/johnsundell/publish.git", .exact("0.5.0"))
    ],
    targets: [
        .target(
            name: "Blog",
            dependencies: [
                "Publish"
            ]
        )
    ]
)
