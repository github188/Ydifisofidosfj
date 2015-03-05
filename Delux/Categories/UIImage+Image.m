//
//  UIImage+Image.m
//
//  Created by Darktt on 13/3/28.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import "UIImage+Image.h"
#import <QuartzCore/QuartzCore.h>

#define USE_QUARTZCORE_FRAMEWORK

@implementation UIImage (Image)

+ (UIImage *)screenImageWithRect:(CGRect)rect view:(UIView *)view
{
#ifdef USE_QUARTZCORE_FRAMEWORK
    CALayer *layer = view.layer;
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, scale);
    
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    rect = CGRectMake(rect.origin.x * scale, rect.origin.y * scale
                      , rect.size.width * scale, rect.size.height * scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([screenshot CGImage], rect);
    UIImage *croppedScreenshot = [UIImage imageWithCGImage:imageRef scale:scale orientation:screenshot.imageOrientation];
    CGImageRelease(imageRef);
    
    return croppedScreenshot;
#else
    return nil;
#endif
}

@end
