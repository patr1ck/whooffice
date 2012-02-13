//
//  MDNSTimedProbe.m
//  whoofficed
//
//  Created by Patrick Gibson on 2/9/12.
//

#import "MDNSTimedProbe.h"

@interface MDNSTimedProbe ()
@property (nonatomic, strong) NSNetServiceBrowser *_netServiceBrowser;
@property (nonatomic, strong) NSMutableArray *_deviceNames;
@property (nonatomic, strong) NSArray *_serviceTypesToSearch;
@property (nonatomic, assign) int _searchIndex;
@property (nonatomic, strong) NSTimer *_searchTimer;
@property (nonatomic, assign) int _timerInterval;
@property (nonatomic, strong) NSString *_server;
@end


@implementation MDNSTimedProbe

@synthesize _netServiceBrowser;
@synthesize _deviceNames;
@synthesize _serviceTypesToSearch;
@synthesize _searchIndex;
@synthesize _searchTimer;
@synthesize _timerInterval;
@synthesize _server;

#pragma mark Public methods

- (id)initWithInterval:(int)interval andServer:(NSString *)server;
{
    self = [super init];
    if (self) {
        self._deviceNames = [NSMutableArray arrayWithCapacity:10];
        self._serviceTypesToSearch = [NSArray arrayWithObjects:@"_daap._tcp.", @"_ssh._tcp.", @"_apple-mobdev._tcp.", nil];
        self._searchIndex = 0;
        self._searchTimer = nil;
        self._timerInterval = interval;
        self._server = server;
    }
    return self;
}

- (void)start;
{
    [NSTimer scheduledTimerWithTimeInterval:_timerInterval
                                     target:self 
                                   selector:@selector(beginDeviceSearch:) 
                                   userInfo:nil 
                                    repeats:YES];
    [self beginDeviceSearch:nil];
}

- (void)submitData;
{
    NSDictionary *jsonDict = [NSDictionary dictionaryWithObject:_deviceNames forKey:@"device_names"];
    
    NSLog(@"Dictionary: %@", jsonDict);
    
    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict 
                                                       options:0
                                                         error:&jsonError];
    
    if (!jsonData && jsonError) {
        NSLog(@"ERROR: Couldn't encode JSON: %@", [jsonError localizedDescription]);
    }
    
    
    NSString *apiEndpoint = [NSString stringWithFormat:@"%@/in_office.json", _server];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiEndpoint]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:jsonData];
    
    NSError *connectionError = nil;
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:&response
                                      error:&connectionError];

    if (connectionError) {
        NSLog(@"ERROR: Couldn't connect to submit data: %@", [connectionError localizedDescription]);
    }
}

- (void)beginDeviceSearch:(id)sender;
{
    _searchIndex = 0;
    [self startNextSearch];
}

- (void)startNextSearch;
{
    // Check to see if there are services left to search
    if (_searchIndex >= [_serviceTypesToSearch count]) {
        NSLog(@"Done searching all services. Found devices: %@", _deviceNames);
        [self submitData];
        return;
    }
    
    // Grab the next service type and start the search
    self._netServiceBrowser = [[NSNetServiceBrowser alloc] init];
    [_netServiceBrowser setDelegate:self];
    NSString *serviceType = [_serviceTypesToSearch objectAtIndex:_searchIndex];
    [_netServiceBrowser searchForServicesOfType:serviceType inDomain:@""];
    NSLog(@"Starting search for %@", serviceType);
    
    // Start a timer to cancel the search if it takes too long
    if ([self._searchTimer isValid]) { [_searchTimer invalidate]; }
    self._searchTimer = [NSTimer timerWithTimeInterval:10 
                                                target:self 
                                              selector:@selector(stopSearch:)
                                              userInfo:nil
                                               repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_searchTimer forMode:NSDefaultRunLoopMode];
    
    // Bump the serch index for the next round.
    self._searchIndex++;
}

- (void)stopSearch:(id)sender;
{
    [_netServiceBrowser stop];
}

#pragma mark NSNetServiceBrowserDelegate Methods

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing;
{
    NSLog(@"Found device name: %@ with service type %@ ", [netService name], [netService type]);
    if (![_deviceNames containsObject:[netService name]]) {
        [_deviceNames addObject:[netService name]];
    }
    
    if (!moreServicesComing) {
        [netServiceBrowser stop];
    }
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser;
{
    [self startNextSearch];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didNotSearch:(NSDictionary *)errorInfo;
{
    NSLog(@"ERROR: Didn't search: %@", errorInfo);
    [self startNextSearch];
}

@end
