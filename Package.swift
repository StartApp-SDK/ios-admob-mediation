// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StartioAdmobMediation",
    platforms: [.iOS(.v11)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "StartioAdmobMediation",
            targets: ["StartioAdmobMediation"])
    ],
    dependencies: [
        .admob,
        .startApp
    ],
    targets: [
        .target(
            name: "StartioAdmobMediation",
            dependencies: [
                .StartApp,
                .GoogleMobileAds
            ],
            path: "StartioAdmobMediation",
            publicHeadersPath: ""
        )
    ]
)

extension Package.Dependency {
    static let admob: Package.Dependency = .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", from: Version("9.13.0"))
    static let startApp: Package.Dependency = .package(url: "https://gitlab.hosts-app.com/sdk/ios-sdk-swift-package.git", branch: "master")
}

extension Target.Dependency {
    static let GoogleMobileAds: Target.Dependency = .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads")
    static let StartApp: Target.Dependency = .product(name: "StartApp", package: "ios-sdk-swift-package")
}
