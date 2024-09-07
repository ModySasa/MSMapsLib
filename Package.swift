// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MSMapsLib",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MSMapsLib",
            targets: ["MSMapsLib"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
//        .package(url: "https://github.com/googlemaps/google-maps-ios-utils.git", .upToNextMinor(from: "4.2.2")),
        .package(url: "https://github.com/googlemaps/ios-places-sdk", .upToNextMinor(from: "9.0.0")),
        .package(url: "https://github.com/googlemaps/ios-maps-sdk", .upToNextMinor(from: "9.0.0")),
//        .package(url: "https://github.com/ModySasa/NetworkLib", .branch("main")),
        .package(url: "https://github.com/dtagdev/NetworkLib", branch: "DTagMain"),
//            .package(url: "https://bitbucket.org/systemira-ios/networklib", branch: "main"),
    ],

    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MSMapsLib",
            dependencies: [
                .product(name: "GooglePlaces", package: "ios-places-sdk"),
                .product(name: "GoogleMaps", package: "ios-maps-sdk"),
//                .product(name: "GoogleMapsBase", package: "ios-maps-sdk"),
//                .product(name: "GoogleMapsCore", package: "ios-maps-sdk"),
                .product(name: "NetworkLib", package: "NetworkLib"),
//                .product(name: "NetworkLib", package: "networklib"),
//                .product(name: "GoogleMapsUtils", package: "google-maps-ios-utils"),
            ],
            resources: [
                
            ]
        ),
        .testTarget(
            name: "MSMapsLibTests",
            dependencies: ["MSMapsLib"]
        ),
    ]
)
