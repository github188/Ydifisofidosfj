//
//  UIImage+DrawImage.h
//
//  Created by Darktt on 13/6/3.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTInstancetype.h"

@interface UIImage (DrawImage)

// Draw Gradient Image
+ (DTInstancetype)imageWithColor:(UIColor *)color size:(CGSize)size;
+ (DTInstancetype)drawGradientImageWithRect:(CGRect)frame beginColor:(UIColor *)beginColor endColor:(UIColor *)endColor location:(CGFloat *)loaction;
+ (DTInstancetype)drawGradientImageWithRect:(CGRect)frame gradientColors:(NSArray *)gradientColors location:(CGFloat *)loaction;

// Custom Gradient Image
+ (DTInstancetype)bicycleMapsNavigationImage;
+ (DTInstancetype)redGradientImageWithRect:(CGRect)frame;
+ (DTInstancetype)grayGradientImageWithRect:(CGRect)frame;
+ (DTInstancetype)blueGradientImageWithRect:(CGRect)frame;
+ (DTInstancetype)greenGradientImageWithRect:(CGRect)frame;
+ (DTInstancetype)purpleGradientImageWithRect:(CGRect)frame;
+ (DTInstancetype)lightYellowGradientImageWithRect:(CGRect)frame;

// Draw Rounded Rect Gradient Image
+ (DTInstancetype)drawRounedRectImageWithRect:(CGRect)frame cornerRadius:(CGFloat)cornerRadius gradientColors:(NSArray *)gradientColors lineColor:(UIColor *)lineColor gradientLocation:(CGFloat *)gradientLocation;

@end
