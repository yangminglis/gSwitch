#import <Foundation/Foundation.h>
#import "AppInstaller.h"


#include "AppKitPrevention.h"

int main(int __unused argc, const char __unused *argv[])
{
    @autoreleasepool
    {
        NSArray<NSString *> *args = [[NSProcessInfo processInfo] arguments];
        if (args.count != 2) {
            return EXIT_FAILURE;
        }
        
        NSString *hostBundleIdentifier = args[1];
        
        AppInstaller *appInstaller = [[AppInstaller alloc] initWithHostBundleIdentifier:hostBundleIdentifier];
        [appInstaller start];
        
        // Ignore SIGTERM because we are going to catch it ourselves
        signal(SIGTERM, SIG_IGN);
        
        dispatch_source_t sigtermSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_SIGNAL, SIGTERM, 0, dispatch_get_main_queue());
        dispatch_source_set_event_handler(sigtermSource, ^{
            [appInstaller cleanupAndExitWithStatus:SIGTERM];
        });
        dispatch_resume(sigtermSource);
        
        [[NSRunLoop currentRunLoop] run];
    }

    return EXIT_SUCCESS;
}
