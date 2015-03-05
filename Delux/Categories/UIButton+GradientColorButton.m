//
//  UIButton+GradientColorButton.m
//
//  Created by Darktt on 13/6/6.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import "UIButton+GradientColorButton.h"

@implementation UIButton (GradientColorButton)

#pragma mark - Gradient Color Button

#pragma mark Blue Button
+ (DTInstancetype)blueButtonWithFrame:(CGRect)frame conerRadius:(CGFloat)conerRadius
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    
    [button setTitleLabeForGradientButton];
    
    // Colors
    UIColor *beginColor = [UIColor colorWithRed:43/255.0f green:128/255.0f blue:240/255.0f alpha:1];
    UIColor *endColor = [UIColor colorWithRed:43/255.0f green:108/255.0f blue:194/255.0f alpha:1];
    UIColor *lineColor = [UIColor colorWithRed:7/255.0f green:64/255.0f blue:140/255.0f alpha:1];
    NSArray *colors = [NSArray arrayWithObjects:(id)beginColor.CGColor, (id)endColor.CGColor, nil];
    NSArray *revertColors = [NSArray arrayWithObjects:(id)endColor.CGColor, (id)beginColor.CGColor, nil];
    
    // Normal Style
    UIImage *buttomImage = [button drawRounedRectImageWithRect:button.bounds
                                                  cornerRadius:conerRadius
                                                gradientColors:colors
                                                     lineColor:lineColor];
    [button setBackgroundImage:buttomImage forState:UIControlStateNormal];
    
    // Press Style
    UIImage *buttonPressImage = [button drawRounedRectImageWithRect:button.bounds
                                                       cornerRadius:conerRadius
                                                     gradientColors:revertColors
                                                          lineColor:lineColor];
    [button setBackgroundImage:buttonPressImage forState:UIControlStateHighlighted];
    
    return button;
}

#pragma mark Gray Button
+ (DTInstancetype)grayButtonWithFrame:(CGRect)frame conerRadius:(CGFloat)conerRadius
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    
    [button setTitleLabeForGrayGradientButton];
   
    // Colors
    UIColor *beginColor = [UIColor colorWithWhite:235/255.0f alpha:1];
    UIColor *endColor = [UIColor colorWithWhite:220/255.0f alpha:1];
    UIColor *lineColor = [UIColor colorWithWhite:175/255.0f alpha:1];
    NSArray *colors = [NSArray arrayWithObjects:(id)beginColor.CGColor, (id)endColor.CGColor, nil];
    NSArray *revertColors = [NSArray arrayWithObjects:(id)endColor.CGColor, (id)beginColor.CGColor, nil];
    
    // Normal Style
    UIImage *buttomImage = [button drawRounedRectImageWithRect:button.bounds
                                                  cornerRadius:conerRadius
                                                gradientColors:colors
                                                     lineColor:lineColor];
    [button setBackgroundImage:buttomImage forState:UIControlStateNormal];
    
    // Press Style
    UIImage *buttonPressImage = [button drawRounedRectImageWithRect:button.bounds
                                                       cornerRadius:conerRadius
                                                     gradientColors:revertColors
                                                          lineColor:lineColor];
    [button setBackgroundImage:buttonPressImage forState:UIControlStateHighlighted];
    
    return button;
}

#pragma mark Green Button
+ (DTInstancetype)greenButtonWithFrame:(CGRect)frame conerRadius:(CGFloat)conerRadius
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    
    [button setTitleLabeForGradientButton];
    
    // Colors
    UIColor *beginColor = [UIColor colorWithRed:68/255.0f green:205/255.0f blue:37/255.0f alpha:1];
    UIColor *endColor = [UIColor colorWithRed:59/255.0f green:164/255.0f blue:36/255.0f alpha:1];
    UIColor *lineColor = [UIColor colorWithRed:37/255.0f green:124/255.0f blue:17/255.0f alpha:1];
    NSArray *colors = [NSArray arrayWithObjects:(id)beginColor.CGColor, (id)endColor.CGColor, nil];
    NSArray *revertColors = [NSArray arrayWithObjects:(id)endColor.CGColor, (id)beginColor.CGColor, nil];
    
    // Normal Style
    UIImage *buttomImage = [button drawRounedRectImageWithRect:button.bounds
                                                  cornerRadius:conerRadius
                                                gradientColors:colors
                                                     lineColor:lineColor];
    [button setBackgroundImage:buttomImage forState:UIControlStateNormal];
    
    // Press Style
    UIImage *buttonPressImage = [button drawRounedRectImageWithRect:button.bounds
                                                       cornerRadius:conerRadius
                                                     gradientColors:revertColors
                                                          lineColor:lineColor];
    [button setBackgroundImage:buttonPressImage forState:UIControlStateHighlighted];
    
    return button;
}

#pragma mark Purple Button
+ (DTInstancetype)purpleButtonWithFrame:(CGRect)frame conerRadius:(CGFloat)conerRadius
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    
    [button setTitleLabeForGradientButton];
    
    // Colors
    UIColor *beginColor = [UIColor colorWithRed:90/255.0f green:0 blue:139/255.0f alpha:1];
    UIColor *endColor = [UIColor colorWithRed:40/255.0f green:0 blue:88/255.0f alpha:1];
    UIColor *lineColor = [UIColor colorWithRed:35/255.0f green:0 blue:75/255.0f alpha:1];
    NSArray *colors = [NSArray arrayWithObjects:(id)beginColor.CGColor, (id)endColor.CGColor, nil];
    NSArray *revertColors = [NSArray arrayWithObjects:(id)endColor.CGColor, (id)beginColor.CGColor, nil];
    
    // Normal Style
    UIImage *buttomImage = [button drawRounedRectImageWithRect:button.bounds
                                                  cornerRadius:conerRadius
                                                gradientColors:colors
                                                     lineColor:lineColor];
    [button setBackgroundImage:buttomImage forState:UIControlStateNormal];
    
    // Press Style
    UIImage *buttonPressImage = [button drawRounedRectImageWithRect:button.bounds
                                                       cornerRadius:conerRadius
                                                     gradientColors:revertColors
                                                          lineColor:lineColor];
    [button setBackgroundImage:buttonPressImage forState:UIControlStateHighlighted];
    
    return button;
}

#pragma mark Red Button
+ (DTInstancetype)redButtonWithFrame:(CGRect)frame conerRadius:(CGFloat)conerRadius
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    
    [button setTitleLabeForGradientButton];
    
    // Colors
    UIColor *beginColor = [UIColor colorWithRed:230/255.0f green:54/255.0f blue:54/255.0f alpha:1];
    UIColor *endColor = [UIColor colorWithRed:186/255.0f green:51/255.0f blue:51/255.0f alpha:1];
    UIColor *lineColor = [UIColor colorWithRed:133/255.0f green:14/255.0f blue:14/255.0f alpha:1];
    NSArray *colors = [NSArray arrayWithObjects:(id)beginColor.CGColor, (id)endColor.CGColor, nil];
    NSArray *revertColors = [NSArray arrayWithObjects:(id)endColor.CGColor, (id)beginColor.CGColor, nil];
    
    // Normal Style
    UIImage *buttomImage = [button drawRounedRectImageWithRect:button.bounds
                                                  cornerRadius:conerRadius
                                                gradientColors:colors
                                                     lineColor:lineColor];
    [button setBackgroundImage:buttomImage forState:UIControlStateNormal];
    
    // Press Style
    UIImage *buttonPressImage = [button drawRounedRectImageWithRect:button.bounds
                                                       cornerRadius:conerRadius
                                                     gradientColors:revertColors
                                                          lineColor:lineColor];
    [button setBackgroundImage:buttonPressImage forState:UIControlStateHighlighted];
    
    return button;
}

#pragma mark - Set Title Lable For Gradient Button

- (void)setTitleLabeForGrayGradientButton
{
    CGFloat fontSize = [UIFont systemFontSize];
    [self.titleLabel setFont:[UIFont boldSystemFontOfSize:fontSize]];
    [self.titleLabel setShadowOffset:CGSizeMake(0, 1)];
    [self setTitleColor:[UIColor colorWithWhite:105/255.0f alpha:1] forState:UIControlStateNormal];
    [self setTitleShadowColor:[UIColor lightTextColor] forState:UIControlStateNormal];
}

- (void)setTitleLabeForGradientButton
{
    CGFloat fontSize = [UIFont systemFontSize];
    [self.titleLabel setFont:[UIFont boldSystemFontOfSize:fontSize]];
    [self.titleLabel setShadowOffset:CGSizeMake(0, -1)];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.3f] forState:UIControlStateNormal];
}

#pragma mark - Draw Rouned Rect Image

- (UIImage *)drawRounedRectImageWithRect:(CGRect)frame cornerRadius:(CGFloat)cornerRadius gradientColors:(NSArray *)gradientColors lineColor:(UIColor *)lineColor
{
    CGSize imageSize = CGSizeMake(frame.size.width + 1.5f, frame.size.height + 1.5f);
    CGFloat linWidth = 3.0f;
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, scale);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat gradientLocation[] = {0, 1};
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)gradientColors, gradientLocation);
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:cornerRadius];
    
    CGContextSaveGState(context);
    [bezierPath addClip];
    
    CGPoint beginPoint = CGPointMake(imageSize.width / 2, 0);
    CGPoint endPoint = CGPointMake(imageSize.width / 2, imageSize.height);
    
    CGContextDrawLinearGradient(context, gradient, beginPoint, endPoint, 0);
    
    if (lineColor != nil) {
        CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
        
        [bezierPath setLineWidth:linWidth];
        [bezierPath stroke];
    }
    
    CGContextRestoreGState(context);
    
    UIImage *drawnImage = UIGraphicsGetImageFromCurrentImageContext();
    [drawnImage resizableImageWithCapInsets:UIEdgeInsetsMake(linWidth, linWidth, linWidth, linWidth)];
    
    UIGraphicsEndImageContext();
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
    
    return drawnImage;
}

@end
