// swift-tools-version:5.5
import PackageDescription

let package = Package(
        name: "OneInchKit",
        platforms: [
          .iOS(.v13),
        ],
        products: [
          .library(
                  name: "OneInchKit",
                  targets: ["OneInchKit"]
          ),
        ],
        dependencies: [
          .package(url: "https://github.com/attaswift/BigInt.git", .upToNextMajor(from: "5.0.0")),
          .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "5.0.1")),
          .package(url: "https://github.com/horizontalsystems/EvmKit.Swift.git", .upToNextMajor(from: "1.1.1")),
          .package(url: "https://github.com/horizontalsystems/Eip20Kit.Swift.git", .upToNextMajor(from: "1.0.0")),
          .package(url: "https://github.com/horizontalsystems/HsCryptoKit.Swift.git", .upToNextMajor(from: "1.0.0")),
          .package(url: "https://github.com/horizontalsystems/HsExtensions.Swift.git", .upToNextMajor(from: "1.0.0")),
        ],
        targets: [
          .target(
                  name: "OneInchKit",
                  dependencies: [
                    "BigInt",
                    "RxSwift",
                    .product(name: "EvmKit", package: "EvmKit.Swift"),
                    .product(name: "Eip20Kit", package: "Eip20Kit.Swift"),
                    .product(name: "HsCryptoKit", package: "HsCryptoKit.Swift"),
                    .product(name: "HsExtensions", package: "HsExtensions.Swift"),
                  ]
          )
        ]
)
