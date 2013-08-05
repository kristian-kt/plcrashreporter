/*
 * Author: Landon Fuller <landonf@plausiblelabs.com>
 *
 * Copyright (c) 2008-2013 Plausible Labs Cooperative, Inc.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

#import "GTMSenTestCase.h"

#import "PLCrashSysctl.h"
#import "PLCrashProcessInfo.h"

@interface PLCrashProcessInfoTests : SenTestCase {
@private
    struct kinfo_proc _process_info;
    PLCrashProcessInfo *_pinfo;
}
@end

@implementation PLCrashProcessInfoTests

- (void) setUp {
    /* Fetch the kinfo_proc structure for the target pid */
    int process_info_mib[] = {
        CTL_KERN,
        KERN_PROC,
        KERN_PROC_PID,
        getpid()
    };
    size_t process_info_len = sizeof(_process_info);
    
    if (sysctl(process_info_mib, sizeof(process_info_mib)/sizeof(process_info_mib[0]), &_process_info, &process_info_len, NULL, 0) != 0) {
        STFail(@"Unexpected sysctl error %d: %s", errno, strerror(errno));
    }
    
    _pinfo = [[PLCrashProcessInfo currentProcessInfo] retain];
}

- (void) testProcessID {
    STAssertEquals(getpid(), _pinfo.processID, @"Incorrect process ID");
}

- (void) testProcessName {
    STAssertEqualStrings([[NSProcessInfo processInfo] processName], _pinfo.processName, @"Incorrect process name");
}

- (void) testParentProcessID {
    STAssertEquals(getppid(), _pinfo.parentProcessID, @"Incorrect process ID");
}

- (void) testDebuggerAttached {
    STAssertEquals(_pinfo.isTraced, (BOOL) ((_process_info.kp_proc.p_flag & P_TRACED) ? YES : NO), @"Debugger not attached");
}

@end
