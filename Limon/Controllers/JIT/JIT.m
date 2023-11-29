// bomberfish
// JIT.m – Limon
// created on 2023-11-29

#import <Foundation/Foundation.h>
#import <mach-o/dyld.h>
#import <spawn.h>
#import <sys/sysctl.h>
#if __has_feature(modules)
@import UIKit;
@import Foundation;
#else
#import "UIKit/UIKit.h"
#import "Foundation/Foundation.h"
#endif

#define CS_PLATFORM_BINARY 0x4000000
#define PT_TRACE_ME 0
#define PT_DETACH 11
#define CS_DEBUGGED 0x10000000

// declarations
extern char** environ;
int csops(pid_t pid, unsigned int ops, void *useraddr, size_t usersize);
CFTypeRef SecTaskCopyValueForEntitlement(void* task, NSString* entitlement, CFErrorRef  _Nullable *error);
void* SecTaskCreateFromSelf(CFAllocatorRef allocator);
int ptrace(int, pid_t, caddr_t, int);
void saveIntValueToUserDefaults(int value, NSString *key) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:value forKey:key];
    [defaults synchronize];
}
#define DISPATCH_ASYNC_START dispatch_async(dispatch_get_main_queue(), ^{
#define DISPATCH_ASYNC_CLOSE });

// get entitlement
BOOL getEntitlementValue(NSString *key) {
    void *secTask = SecTaskCreateFromSelf(NULL);
    CFTypeRef value = SecTaskCopyValueForEntitlement(SecTaskCreateFromSelf(NULL), key, nil);
    if (value != nil) {
        CFRelease(value);
    }
    CFRelease(secTask);

    return value != nil && [(__bridge id)value boolValue];
}

// check if jit is already enabled
BOOL isJITAlreadyEnabled(BOOL checkCSFlags) {
    if (!checkCSFlags && (getEntitlementValue(@"dynamic-codesigning"))) {
        return YES;
    }

    int flags;
    csops(getpid(), 0, &flags, sizeof(flags));
    return (flags & CS_DEBUGGED) != 0;
}

void ShowAlert(NSString* title, NSString* message)
{
    DISPATCH_ASYNC_START
        UIWindow* mainWindow = [[UIApplication sharedApplication] windows].lastObject;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                    message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"ok!"
                                                style:UIAlertActionStyleDefault
                                                handler:nil]];
        [mainWindow.rootViewController presentViewController:alert
                                                    animated:true
                                                completion:nil];
    DISPATCH_ASYNC_CLOSE
}


// here's the fun part
int enableTSJIT(int argc, char **argv) {
    // thanks: RedNick16
    int result = 0;
    if (getppid() != 1) {
        NSLog(@"Parent process is *NOT* PID1, enabling JIT using PT_TRACE_ME");
        result = ptrace(PT_TRACE_ME, 0, 0, 0);
    }
    
    // thanks: PojavLauncher Team
    if (!isJITAlreadyEnabled(true) && (getEntitlementValue(@"com.apple.private.security.no-sandbox") || getEntitlementValue(@"com.apple.private.security.container-required") || getEntitlementValue(@"com.apple.private.security.no-sandbox"))) {
        NSLog(@"TrollStore detected, enabling JIT...");
        int pid;
        int ret = posix_spawnp(&pid, argv[0], NULL, NULL, (char *[]){argv[0], "", NULL}, environ);
        if (ret == 0) {
            // Cleanup child process
            waitpid(pid, NULL, WUNTRACED);
            ptrace(PT_DETACH, pid, NULL, 0);
            kill(pid, SIGTERM);
            wait(NULL);
             
            // pray to the kernel gods that jit enables somehow
            if (isJITAlreadyEnabled(true)) {
                NSLog(@"JIT Enabled using TRACE_ME!");
            } else {
                NSLog(@"Failed to enable JIT for unknown reason");
                result = 0;
            }
        } else {
            NSLog(@"Failed to enable JIT: posix_spawn() failed errno %d", errno);
            result = 0;
        }
    } else {
        NSLog(@"JIT is already enabled or entitlements are missing, skipping...");
        result = -1;
    }
    return result;
}

// thanks: C22
__attribute__((constructor)) static void entry(int argc, char **argv)
{
    int result = enableTSJIT(argc, argv);
    
    // TODO: Figure out how to put this in a switch statement?
    if(result == 1) {
        int intValueToStore = 1;
        NSString *key = @"jitStatus";
        saveIntValueToUserDefaults(intValueToStore, key);
    }
    if(result == 0) {
        int intValueToStore = 0;
        NSString *key = @"jitStatus";
        saveIntValueToUserDefaults(intValueToStore, key);
        ShowAlert(@"Error", @"Failed to enable JIT: unknown reason");
    }
    if(result == -1) {
        int intValueToStore = 2;
        NSString *key = @"jitStatus";
        saveIntValueToUserDefaults(intValueToStore, key);
    }
}
