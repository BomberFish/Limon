// bomberfish
// JIT.swift – Limon
// created on 2023-11-29

import Foundation

// thanks: C22
func enableJIT() -> Int32 {
    let argc = CommandLine.argc
    let argv = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: Int(argc))
    for i in 0..<Int(argc) {
        argv[i] = UnsafeMutablePointer<Int8>(mutating: CommandLine.unsafeArgv[i])
    }
    let result = enableTSJIT(argc, argv)
    argv.deallocate()
    return result
}
