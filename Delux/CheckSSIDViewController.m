//
//  CheckSSIDViewController.m
//  IOTCamViewer
//
//  Created by TUTK_MacMini2 on 14/5/13.
//  Copyright (c) 2014年 TUTK. All rights reserved.
//

#import <IOTCamera/IOTCAPIs.h>
#import <IOTCamera/Camera.h>

#import "CheckSSIDViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "LANSearchDevice.h"
#import "AddCameraDetailController.h"

@interface CheckSSIDViewController ()

@end

@implementation CheckSSIDViewController

@synthesize uid;

-(id)fetchSSIDInfo
{
    NSArray *ifs = (id)CNCopySupportedInterfaces();
    NSLog(@"%s: Supported interfaces: %@", __func__, ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (id)CNCopyCurrentNetworkInfo((CFStringRef)ifnam);
        if (info && [info count]) {
            break;
        }
        [info release];
    }
    [ifs release];
    return [info autorelease];
}

- (void)lanSearch
{
    int num = 0;
    //int k = 0;
    int cnt = 0;
    
    while (num == 0 & cnt++ < 2) {
        
        LanSearch_t *pLanSearchAll = [Camera LanSearch:&num timeout:2000];
        printf("camera found(%d)\n", num);
        
        uid = [NSString stringWithFormat:@"%s", pLanSearchAll[0].UID];
        
        if(pLanSearchAll) {
            free(pLanSearchAll);
        }
    }
}


- (void)checkSSID {
    NSDictionary *ifs = [self fetchSSIDInfo];
    NSString *ssid = [ifs objectForKey:@"SSID"];
    if (![ssid isEqualToString:@""]){
        
        [self lanSearch];
        
        AddCameraDetailController *controller = [[AddCameraDetailController alloc] initWithNibName:@"AddCameraDetail" bundle:nil delegate:[[self.navigationController viewControllers] objectAtIndex:1]];
        controller.uid = uid;
        controller.ssid = ssid;
        
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];

        
    } else {
        bgImage.hidden = YES;
        cautionView.hidden = NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    cautionLabel.text = NSLocalizedString(@"Please connect to your device’s Wi-Fi network to continue.", @"");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkSSID) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
