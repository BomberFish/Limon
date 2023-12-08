// bomberfish
// exception.h – Limon
// created on 2023-12-07

#ifndef exception_h
#define exception_h

#import <Foundation/Foundation.h>
#import <mach/mach.h>
#import <pthread.h>
#import <sys/sysctl.h>

kern_return_t catch_exception_raise(mach_port_t exception_port,
                                    mach_port_t thread,
                                    mach_port_t task,
                                    exception_type_t exception,
                                    exception_data_t code,
                                    mach_msg_type_number_t code_count);
void *exception_handler(void *argument);
void create_thread(mach_port_t port);

#endif /* exception_h */
