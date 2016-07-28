import PackageDescription

let package = Package(
    name: "VaporApp",
    dependencies: [
        .Package(url: "https://github.com/qutheory/vapor.git", majorVersion: 0, minor: 14),
        .Package(url: "https://github.com/qutheory/vapor-mustache.git", majorVersion: 0, minor: 10),
        .Package(url: "../Turnstile-Vapor", majorVersion: 0),
        .Package(url: "https://github.com/qutheory/vapor-mysql", majorVersion: 0, minor: 2)
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
        "Tests",
    ]
)
