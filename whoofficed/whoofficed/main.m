//
//  main.m
//  whoofficed
//
//  Created by Patrick Gibson on 2/9/12.
//

#import <Foundation/Foundation.h>

#import "MDNSTimedProbe.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        NSArray *arguments = [[NSProcessInfo processInfo] arguments];
        
        if ([arguments count] < 3) {
            NSLog(@"Invalid number of arguments passed.\nUSAGE: whoofficed <timer interval> <server url>");
            return 1;
        }
        
        int interval = [[arguments objectAtIndex:1] intValue];
        NSString *server = [arguments objectAtIndex:2];
        
        MDNSTimedProbe *probe = [[MDNSTimedProbe alloc] initWithInterval:interval andServer:server];
        [probe start];
        
        [[NSRunLoop currentRunLoop] run];
    }
    
    return 0;
}

