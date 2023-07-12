// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.
// Copyright (C) 2023, Mark Melton

import PackageDescription

let package = Package(
  name: "MetalPlugin",

  platforms: [.macOS(.v13)],
  
  products: [
    .library(name: "Example", targets: ["Example"]),
    .executable(name: "ExampleTool", targets: ["ExampleTool"]),
    .executable(name: "MetalPluginTool", targets: ["MetalPluginTool"]),
    .plugin(name: "MetalPlugin", targets: ["MetalPlugin"])
  ],

  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0")
  ],
  
  targets: [
    .target(name: "Example", plugins: ["MetalPlugin"]),
    .testTarget(name: "ExampleTest", dependencies: ["Example"]),
    .executableTarget(
      name: "ExampleTool",
      dependencies: [ "Example" ],
      linkerSettings: [ .linkedFramework("CoreGraphics") ]
    ),
    .executableTarget(
      name: "MetalPluginTool",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ]
    ),
    .plugin(
      name: "MetalPlugin",
      capability: .buildTool(),
      dependencies: ["MetalPluginTool"]
    )
  ]
)
