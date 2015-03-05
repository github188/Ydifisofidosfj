//
//  UIScreen+WinSize.m
//
//  Created by Darktt on 13/1/4.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import "UIScreen+WinSize.h"

@implementation UIScreen (WinSize)

- (CGSize)winSize
{
    CGRect screenRect = [self bounds];
    CGFloat width = CGRectGetWidth(screenRect);
    CGFloat height = CGRectGetHeight(screenRect);
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    CGSize winSize = CGSizeZero;
    
    if(UIInterfaceOrientationIsPortrait(interfaceOrientation)){
        winSize = CGSizeMake(width, height);
    }else if(UIInterfaceOrientationIsLandscape(interfaceOrientation)){
        winSize = CGSizeMake(height, width);
    }
    
    return winSize;
}

- (CGPoint)centerPointOfScreen
{
    CGRect screenRect = CGRectZero;
    screenRect.size = [self winSize];
    
    CGFloat centerX = CGRectGetMidX(screenRect);
    CGFloat centerY = CGRectGetMidY(screenRect);
    
    return CGPointMake(centerX, centerY);
}

@end
