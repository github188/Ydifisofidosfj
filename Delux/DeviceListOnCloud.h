//
//  DeviceListOnCloud.h
//  IOTCamViewer
//
//  Created by TUTK_MacMini2 on 14/4/22.
//  Copyright (c) 2014年 TUTK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "MyCamera.h"

extern FMDatabase *database;

@protocol DeviceOnCloudDelegate;

@interface DeviceListOnCloud : NSObject<NSURLConnectionDataDelegate>

@property (nonatomic, assign) id<DeviceOnCloudDelegate> delegate;

-(void)addDeviceUID:(NSString *)cameraUID deviceName:(NSString *)cameraName userID:(NSString *)userID PWD:(NSString*)userPWD;
-(void)syncDeviceUID:(NSString *)cameraUID deviceName:(NSString *)cameraName userID:(NSString *)userID PWD:(NSString*)userPWD;
-(void)downloadDeviceListID:(NSString *)userID PWD:(NSString*)userPWD;

@end

@protocol DeviceOnCloudDelegate <NSObject>

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData;

@end
