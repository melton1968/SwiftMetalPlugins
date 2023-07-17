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
    .executable(name: "CompilerPluginTool", targets: ["CompilerPluginTool"]),
    .plugin(name: "CompilerPlugin", targets: ["CompilerPlugin"])
  ],

  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0")
  ],
  
  targets: [
    .target(name: "Example", plugins: ["CompilerPlugin"]),
    .testTarget(name: "ExampleTest", dependencies: ["Example"]),
    .executableTarget(
      name: "ExampleTool",
      dependencies: [ "Example" ],
      linkerSettings: [ .linkedFramework("CoreGraphics") ]
    ),
    .executableTarget(
      name: "CompilerPluginTool",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ]
    ),
    .plugin(
      name: "CompilerPlugin",
      capability: .buildTool(),
      dependencies: ["CompilerPluginTool"]
    )
  ]
)
