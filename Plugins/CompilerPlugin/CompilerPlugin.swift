// Copyright (C) 2023, Mark Melton
//
import PackagePlugin

@main
struct CompilerPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        guard let target = target as? SourceModuleTarget else { return [] }
        
        let xcrunTool = try context.tool(named: "CompilerPluginTool").path
        
        let sourceFiles = target.sourceFiles.compactMap {
            return $0.path.extension == "metal" ? $0.path : nil
        }
        
        let airCommands = sourceFiles.map {
            let outputName = $0.stem + ".air"
            let outputPath = context.pluginWorkDirectory.appending(outputName)
            return Command.buildCommand(
              displayName: "Compiling \(outputName) from \($0.lastComponent)",
              executable: xcrunTool,
              arguments: ["-sdk", "macosx", "metal", "-I/include/metal",
                          "-c", "-frecord-sources", "\($0)",
                          "-o", "\(outputPath)"],
              inputFiles: [ $0 ],
              outputFiles: [ outputPath ]
            )
        }

        let airFiles = sourceFiles.map { context.pluginWorkDirectory.appending($0.stem + ".air") }
        let archiveName = "default.metalar"
        let archivePath = context.pluginWorkDirectory.appending(archiveName)
        
        let archiveCommand = Command.buildCommand(
          displayName: "Archiving air files to \(archiveName)",
          executable: xcrunTool,
          arguments: ["metal-ar", "r", archivePath] + airFiles,
          inputFiles: airFiles,
          outputFiles: [ archivePath ]
        )

        let libraryName = "default.metallib"
        let libraryPath = context.pluginWorkDirectory.appending(libraryName)
        let libraryCommand = Command.buildCommand(
          displayName: "Creating metal library \(libraryName) from archive \(archiveName)",
          executable: xcrunTool,
          arguments: ["-sdk", "macosx", "metallib", archivePath, "-o", libraryPath],
          inputFiles: [ archivePath ],
          outputFiles: [ libraryPath ]
        )
        
        return airCommands +  [archiveCommand, libraryCommand]
    }
}



