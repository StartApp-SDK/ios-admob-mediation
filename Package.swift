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
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", Version("9.13.0")..<Version("10.0.0")),
        .package(url: "https://gitlab.hosts-app.com/sdk/ios-sdk-swift-package.git", branch: "master")
    ],
    targets: [
        .target(
            name: "StartioAdmobMediation",
            dependencies: [
                .product(name: "StartApp", package: "ios-sdk-swift-package"),
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
            ],
            path: "StartioAdmobMediation",
            publicHeadersPath: ""
        )
    ]
)
