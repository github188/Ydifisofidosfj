//
//  ChangeCameraSettingDelegate.h
//  IOTCamViewer
//
//  Created by Cloud Hsiao on 12/6/29.
//  Copyright (c) 2012年 TUTK. All rights reserved.
//

#ifndef IOTCamViewer_ChangeCameraSettingDelegate_h
#define IOTCamViewer_ChangeCameraSettingDelegate_h

#import <IOTCamera/Camera.h>

@protocol ChangeCameraSettingDelegate <NSObject>
@required
- (void)camera:(Camera *)camera didChangeName:(NSString *)name Password:(NSString *)password;

@end

#endif
