//
//  cCustomNavigationController.m
//  IOTCamViewer
//
//  Created by TUTK_MacMini2 on 2014/7/7.
//  Copyright (c) 2014年 TUTK. All rights reserved.
//

#import "cCustomNavigationController.h"

@interface cCustomNavigationController ()

@end

@implementation cCustomNavigationController


//自定義的NavigationController，可在此決定是否支援旋轉以及預設方向、支援的旋轉方向等參數
- (BOOL)shouldAutorotate {
//    return [self.visibleViewController shouldAutorotate];
    return YES;

}

//- (NSUInteger)supportedInterfaceOrientations {
//    return [self.visibleViewController supportedInterfaceOrientations];
//    
//}
//
//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return [self.visibleViewController preferredInterfaceOrientationForPresentation];
//}

@end