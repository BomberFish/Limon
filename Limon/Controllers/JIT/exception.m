// bomberfish
// exception.m – Limon
// created on 2023-12-07

#import <Foundation/Foundation.h>
#import <mach/mach.h>
#import <pthread.h>
#import <sys/sysctl.h>
#include "exception.h"

// thanks: saagarjha
boolean_t exc_server(mach_msg_header_t *, mach_msg_header_t *);
int ptrace(int, pid_t, caddr_t, int);

kern_return_t catch_exception_raise(mach_port_t exception_port,
                                    mach_port_t thread,
                                    mach_port_t task,
                                    exception_type_t exception,
                                    exception_data_t code,
                                    mach_msg_type_number_t code_count) {
    // Forward the request to the next-level Mach exception handler. This will
    // probably be ReportCrash's.
    return KERN_FAILURE;
}

void *exception_handler(void *argument) {
    mach_port_t port = *(mach_port_t *)argument;
    mach_msg_server(exc_server, 2048, port, 0);
    return NULL;
}

void create_thread(mach_port_t port) { // too lazy to port to swift
    pthread_t thread;
    pthread_create(&thread, NULL, exception_handler, (void *)&port);
}
