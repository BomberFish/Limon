// bomberfish
// JIT.swift – Limon
// created on 2023-11-29

import Foundation
import Darwin
import MachO

// thanks: UTM project
func spawnPtraceChild(argc: Int32, argv: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>) -> Bool {
//    let argc = CommandLine.argc
//    let argv = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: Int(argc))
    defer {
        argv.deallocate() // free
    }
    for i in 0..<Int(argc) {
        argv[i] = UnsafeMutablePointer<Int8>(mutating: CommandLine.unsafeArgv[i])
    }
    let ret: Int32 = 0
    let pid: pid_t = 0
    if (argc > 1 && strcmp(argv[1], childArgv[1]) == 0) { // real funny how sometimes you can straight up paste objc code into swift and it works with minimal changes
        ret = ptrace(PT_TRACE_ME, 0, NULL, 0);
        NSLog("child: ptrace(PT_TRACE_ME) %d", ret);
        exit(ret);
    }
    
    childArgv[0] = argv[0];
    if ((ret = posix_spawnp(&pid, argv[0], NULL, NULL, childArgv, NULL)) != 0) {
        return false;
    }
    return true;
}

func enablePtraceHack(argc: Int32, argv: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>) -> Bool {
    let isAlreadyDebugged: Bool = getppid() != 1
    
    let ret = ptrace(0 /* PT_TRACE_ME */, 0, NULL, 0)
    
    if ret < 0 {
        return false
    }
}


func enableJIT() -> Bool {
    let argc = CommandLine.argc
    let argv = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: Int(argc))
    if spawnPtraceChild(argc: argc, argv: argv) {
        NSLog("[JIT] spawned child (just like your mom)")
    } else if enablePtraceHack(argc: argc, argv: argv) {
        NSLog("[JIT] doing 1337 ptrace hax...")
    } else {
        NSLog("[JIT] shit failed (womp womp)")
        let otherRet = enableTSJIT(argc, argv)
        
        switch otherRet {
        case 1:
            NSLog("[JIT] holy shit it worked (un womp womp)")
        case 0:
            NSLog("[JIT] even more shit failed (womp womp)")
        case -1:
            print("[JIT] no trollstore? <megamind here>")
        default:
            print("[JIT] unknown error")
        }
    }
}
