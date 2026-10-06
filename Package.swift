// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StartioAdmobMediation",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "StartioAdmobMediation",
            targets: ["StartioAdmobMediation"])
    ],
    dependencies: [
        .admob,
        .startio
    ],
    targets: [
        .target(
            name: "StartioAdmobMediation",
            dependencies: [
                .StartIO,
                .GoogleMobileAds
            ],
            path: "StartioAdmobMediation",
            publicHeadersPath: ""
        )
    ]
)

extension Package.Dependency {
    static let admob: Package.Dependency = .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", .upToNextMajor(from: "13.11.0"))
    static let startio: Package.Dependency = .package(url: "https://github.com/StartApp-SDK/StartAppSDK-SwiftPackage.git", .upToNextMajor(from: "4.15.0"))
}

extension Target.Dependency {
    static let GoogleMobileAds: Target.Dependency = .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads")
    static let StartIO: Target.Dependency = .product(name: "StartApp", package: "StartAppSDK-SwiftPackage")
}
