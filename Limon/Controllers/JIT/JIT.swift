// bomberfish
// JIT.swift – Limon
// created on 2023-11-29

import Foundation
import Darwin
import MachO

// thanks: saagarjha
let PT_TRACE_ME: CInt = 0
let PT_SIGEXC: CInt = 12
let ptrace = unsafeBitCast(dlsym(dlopen(nil, RTLD_LAZY), "ptrace"), to: (@convention(c) (CInt, pid_t, caddr_t?, CInt) -> CInt).self)

// thanks: UTM project
func spawnPtraceChild(argc: Int32, argv: UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>) -> Bool {
//    let argc = CommandLine.argc
//    let argv = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: Int(argc))
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
    let isAlreadyDebugged: Bool = isJITAlreadyEnabled(true)
    
    let ret = ptrace(PT_TRACE_ME, 0, NULL, 0);
    
    // MARK: Make system not crash (like holy shit why does this happen)
    ptrace(PT_SIGEXC, 0, NULL, 0);
    let port: mach_port_t = MACH_PORT_NULL
    mach_port_insert_right(mach_task_self(), port, port, MACH_MSG_TYPE_MAKE_SEND);
    // PT_SIGEXC maps signals to EXC_SOFTWARE; note that this will interfere
    // with the debugger (which will try to do the same thing via PT_ATTACHEXC).
    // Usually you'd check for that and predicate the execution of the following
    // code on whether it's attached.
    task_set_exception_ports(mach_task_self(), EXC_MASK_SOFTWARE, port, EXCEPTION_DEFAULT, THREAD_STATE_NONE);
    create_thread(port)
    if ret < 0 {
        return false
    }
}



func enableJIT() -> Bool {
    let argc = CommandLine.argc
    let argv = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: Int(argc))
    defer {
        argv.deallocate() // free
    }
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
            return false
        case -1:
            print("[JIT] no trollstore? <megamind here>")
            return false
        default:
            print("[JIT] unknown error")
            return false
        }
    }
    return true
}
