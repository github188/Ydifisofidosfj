//
//  UIButton+GradientColorButton.h
//
//  Created by Darktt on 13/6/6.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTInstancetype.h"

@interface UIButton (GradientColorButton)

+ (DTInstancetype)blueButtonWithFrame:(CGRect)frame conerRadius:(CGFloat)conerRadius;
+ (DTInstancetype)grayButtonWithFrame:(CGRect)frame conerRadius:(CGFloat)conerRadius;
+ (DTInstancetype)greenButtonWithFrame:(CGRect)frame conerRadius:(CGFloat)conerRadius;
+ (DTInstancetype)purpleButtonWithFrame:(CGRect)frame conerRadius:(CGFloat)conerRadius;
+ (DTInstancetype)redButtonWithFrame:(CGRect)frame conerRadius:(CGFloat)conerRadius;

@end
