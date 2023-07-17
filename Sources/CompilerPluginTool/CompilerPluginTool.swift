

import Foundation
import os

@main
struct CompilerPluginTool {
    static func main() throws {
        let p = Process()
        p.executableURL = URL(filePath: "/usr/bin/xcrun")
        let args: [String] = Array(CommandLine.arguments[1...])
        print("xcrun", args.joined(separator: " "))
        p.arguments = args
        try p.run()
    }
}
