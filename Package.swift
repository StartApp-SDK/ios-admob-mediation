// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StartioAdmobMediation",
    platforms: [.iOS(.v12)],
    products: [
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
    static let admob: Package.Dependency = .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", from: Version("11.12.0"))
    static let startApp: Package.Dependency = .package(url: "https://github.com/StartApp-SDK/StartAppSDK-SwiftPackage.git", from: Version("4.10.5"))
}

extension Target.Dependency {
    static let GoogleMobileAds: Target.Dependency = .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads")
    static let StartApp: Target.Dependency = .product(name: "StartApp", package: "StartAppSDK-SwiftPackage")
}
