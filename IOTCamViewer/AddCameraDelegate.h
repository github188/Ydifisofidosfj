//
//  CameraDidAddDelegate.h
//  IOTCamViewer
//
//  Created by Cloud Hsiao on 12/6/28.
//  Copyright (c) 2012年 TUTK. All rights reserved.
//

#ifndef IOTCamViewer_AddCameraDelegate_h
#define IOTCamViewer_AddCameraDelegate_h

@protocol AddCameraDelegate <NSObject>
@required
- (void) camera:(NSString*)UID didAddwithName:(NSString *)name password:(NSString *)password syncOnCloud:(BOOL)isSync addToCloud:(BOOL)isAdd addFromCloud:(BOOL)isFromCloud;

@end

#endif