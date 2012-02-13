//
//  MDNSTimedProbe.h
//  whoofficed
//
//  Created by Patrick Gibson on 2/9/12.
//

#import <Foundation/Foundation.h>

@interface MDNSTimedProbe : NSObject <NSNetServiceBrowserDelegate>

- (id)initWithInterval:(int)interval andServer:(NSString *)server;
- (void)start;

@end
