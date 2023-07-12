
import Metal

print("Running Metal setup")

guard let device = MTLCreateSystemDefaultDevice() else {
    fatalError("Metal: failed to get the system device");
}

print("\(device.name)");
print("  allocated size   : \(device.currentAllocatedSize / 1024)k")
print("  working set size : \(device.recommendedMaxWorkingSetSize / 1024)k")
print("  unified memory   : \(device.hasUnifiedMemory)")

if (!device.hasUnifiedMemory) {
    print("  transfer rate    : \(device.maxTransferRate / 1024)k")
}

let _ = Bundle.allBundles.map {
    print($0)
}

let bundleUrl = Bundle.main.resourceURL!.appendingPathComponent("MetalPlugin_Example.bundle")
print(bundleUrl)

let bundle = Bundle(url: bundleUrl)!
let libraryUrl = bundle.url(forResource: "default", withExtension: "metallib")!
let library = try! device.makeLibrary(URL: libraryUrl)

print(library)

let add_function = library.makeFunction(name: "add")!
print(add_function)

guard let queue = device.makeCommandQueue() else {
    fatalError("metal: failed to make command queue")
}

guard let commandBuffer = queue.makeCommandBuffer() else {
    fatalError("metal: failed to make command buffer")
}

guard let commandEncoder = commandBuffer.makeComputeCommandEncoder() else {
    fatalError("metal: failed to make command encoder")
}

let pipelineState = try! device.makeComputePipelineState(function: add_function)
commandEncoder.setComputePipelineState(pipelineState)

let numberElements = 1024 * 1024 * 1024
let elementSize = MemoryLayout<Float32>.stride
let numberBytes = elementSize * numberElements

guard let bufferR = device.makeBuffer(length: numberBytes, options: .storageModeShared) else {
    fatalError("metal: failed to make buffer")
}

guard let bufferA = device.makeBuffer(length: numberBytes, options: .storageModeShared) else {
    fatalError("metal: failed to make buffer")
}

guard let bufferB = device.makeBuffer(length: numberBytes, options: .storageModeShared) else {
    fatalError("metal: failed to make buffer")
}

memset(bufferA.contents(), 0, numberBytes)
memset(bufferB.contents(), 0, numberBytes)
commandEncoder.setBuffer(bufferR, offset: 0, index: 0)
commandEncoder.setBuffer(bufferA, offset: 0, index: 1)
commandEncoder.setBuffer(bufferB, offset: 0, index: 2)

let gridSize = MTLSizeMake(numberElements, 1, 1)
let threadGroupSize = MTLSizeMake(64, 1, 1)
commandEncoder.dispatchThreads(gridSize, threadsPerThreadgroup: threadGroupSize)
commandEncoder.endEncoding()

commandBuffer.commit()
commandBuffer.waitUntilCompleted()

if memcmp(bufferA.contents(), bufferR.contents(), numberBytes) != 0 {
    fatalError("metal: incorrect computation results")
}

let deltaTimeGPU = commandBuffer.gpuEndTime - commandBuffer.gpuStartTime
print(deltaTimeGPU)

let deltaTimeCPU = commandBuffer.kernelEndTime - commandBuffer.kernelStartTime
print(deltaTimeCPU)

print("All done")
