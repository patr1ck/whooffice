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
        MDNSTimedProbe *probe = [[MDNSTimedProbe alloc] init];
        [probe start];
        [[NSRunLoop currentRunLoop] run];
    }
    
    return 0;
}

