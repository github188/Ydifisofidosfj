//
//  UIApplication+KeyView.m
//
//  Created by Darktt on 13/8/12.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import "UIApplication+KeyView.h"

@implementation UIApplication (KeyView)

- (UIView *)keyView
{
    UIWindow *keyWindow = [self keyWindow];
    
    if (keyWindow.subviews.count > 0) {
        return keyWindow.subviews[0];
    }
    
    return keyWindow;
}

@end
