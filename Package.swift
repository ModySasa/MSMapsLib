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
        .package(url: "https://github.com/googlemaps/ios-places-sdk", .upToNextMinor(from: "9.4.0")),
        .package(url: "https://github.com/googlemaps/ios-maps-sdk", .upToNextMinor(from: "9.4.0")),
    ],

    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MSMapsLib",
            dependencies: [
                .product(name: "GooglePlaces", package: "ios-places-sdk"),
                .product(name: "GoogleMaps", package: "ios-maps-sdk"),
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
