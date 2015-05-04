//
//  CheckNetwork.m
//  IOTCamViewer
//
//  Created by tutk on 6/5/12.
//  Copyright (c) 2012 TUTK. All rights reserved.
//

#import "CheckNetwork.h"
#import "Reachability.h"

@implementation CheckNetwork

+(BOOL)pingServer
{
    NSURL *url = [NSURL URLWithString:@"http://push1.ipcam.hk"];
    NSURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSHTTPURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:&response error:NULL];
    return (response != nil);
}

+(BOOL)isExistenceNetwork
{
	BOOL isExistenceNetwork = FALSE;
	Reachability *r = [Reachability reachabilityWithHostName:@"www.apple.com"];
    
    if (r == nil) {
        return FALSE;
    }
    
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
			isExistenceNetwork=FALSE;
            break;
        case ReachableViaWWAN:
			isExistenceNetwork=TRUE;
            break;
        case ReachableViaWiFi:
			isExistenceNetwork=TRUE;
            break;
    }
    
	return isExistenceNetwork;
}
@end