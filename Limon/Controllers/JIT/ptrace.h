// bomberfish
// ptrace.h – Limon
// created on 2023-12-07

#ifndef ptrace_h
#define ptrace_h
#import <Foundation/Foundation.h>
#include <dlfcn.h>
#include <errno.h>
#include <mach/mach.h>
#include <mach-o/loader.h>
#include <mach-o/getsect.h>
#include <pthread.h>
#include <spawn.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/sysctl.h>
#include <sys/utsname.h>

extern int ptrace(int request, pid_t pid, caddr_t addr, int data);

#endif /* ptrace_h */
