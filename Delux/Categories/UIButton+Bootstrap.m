//
//  UIButton+Bootstrap.m
//
//  Created by Darktt on 13/10/14.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import "UIButton+Bootstrap.h"

static CGFloat kDefaultCornerRadius = 4.0f;

@implementation UIButton (Bootstrap)

+ (DTInstancetype)bootstrapButtonWithFrame:(CGRect)frame style:(DTBootstrapStyle)style
{
    UIButton *bootstrap = [[[UIButton alloc] initWithFrame:frame style:style] autorelease];
    
    return bootstrap;
}

- (DTInstancetype)initWithFrame:(CGRect)frame style:(DTBootstrapStyle)style
{
    self = [super initWithFrame:frame];
    
    if (self == nil) return nil;
    
    [self.layer setCornerRadius:kDefaultCornerRadius];
    
    if (style == DTBootstrapStyleDefault) {
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    } else {
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    }
    
    [self setBootstrapButtonWithStyle:style];
    
    return self;
}

- (void)setBootstrapButtonWithStyle:(DTBootstrapStyle)style
{
    UIColor *backgroundColor = nil;
    UIColor *highlightColor = nil;
    UIColor *borderColor = nil;
    
    switch (style) {
        case DTBootstrapStyleDefault:
            backgroundColor = [UIColor whiteColor];
            highlightColor = [UIColor colorWithWhite:235/255.0 alpha:1.0f];
            borderColor = [UIColor colorWithWhite:204/255.0 alpha:1.0f];
            break;
            
        case DTBootstrapStylePrimary:
            backgroundColor = [UIColor colorWithRed:66/255.0 green:139/255.0 blue:202/255.0 alpha:1.0f];
            highlightColor = [UIColor colorWithRed:51/255.0 green:119/255.0 blue:172/255.0 alpha:1.0f];
            borderColor = [UIColor colorWithRed:53/255.0 green:126/255.0 blue:189/255.0 alpha:1.0f];
            break;
            
        case DTBootstrapStyleSuccess:
            backgroundColor = [UIColor colorWithRed:92/255.0 green:184/255.0 blue:92/255.0 alpha:1.0f];
            highlightColor = [UIColor colorWithRed:69/255.0 green:164/255.0 blue:84/255.0 alpha:1.0f];
            borderColor = [UIColor colorWithRed:76/255.0 green:174/255.0 blue:76/255.0 alpha:1.0f];
            break;
            
        case DTBootstrapStyleInfo:
            backgroundColor = [UIColor colorWithRed:91/255.0 green:192/255.0 blue:222/255.0 alpha:1];
            highlightColor = [UIColor colorWithRed:57/255.0 green:180/255.0 blue:211/255.0 alpha:1];
            borderColor = [UIColor colorWithRed:70/255.0 green:184/255.0 blue:218/255.0 alpha:1];
            break;
            
        case DTBootstrapStyleWarning:
            backgroundColor = [UIColor colorWithRed:240/255.0 green:173/255.0 blue:78/255.0 alpha:1];
            highlightColor = [UIColor colorWithRed:237/255.0 green:155/255.0 blue:67/255.0 alpha:1];
            borderColor = [UIColor colorWithRed:238/255.0 green:162/255.0 blue:54/255.0 alpha:1];
            break;
            
        case DTBootstrapStyleDanger:
            backgroundColor = [UIColor colorWithRed:217/255.0 green:83/255.0 blue:79/255.0 alpha:1];
            highlightColor = [UIColor colorWithRed:210/255.0 green:48/255.0 blue:51/255.0 alpha:1];
            borderColor = [UIColor colorWithRed:212/255.0 green:63/255.0 blue:58/255.0 alpha:1];
            break;
            
        default:
            break;
    }
    
    [self setBackgroundImage:[self backgroundImageWithColor:backgroundColor borderColor:borderColor cornerRadius:kDefaultCornerRadius] forState:UIControlStateNormal];
    [self setBackgroundImage:[self backgroundImageWithColor:highlightColor borderColor:borderColor cornerRadius:kDefaultCornerRadius] forState:UIControlStateHighlighted];
}

- (UIImage *)backgroundImageWithColor:(UIColor *)color borderColor:(UIColor *)borderColor cornerRadius:(CGFloat)cornerRadius
{
    CGSize size = self.bounds.size;
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:cornerRadius];
    
    CGContextSaveGState(context);
    [bezierPath addClip];
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    [bezierPath fill];
    
    if (borderColor != nil) {
        CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
        
        [bezierPath setLineWidth:1.0f * scale];
        [bezierPath stroke];
    }
    
    CGContextRestoreGState(context);
    
    UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
    [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(2.0f, 2.0f, 2.0f, 2.0f)];
    
    UIGraphicsEndImageContext();
    
    return backgroundImage;
}

@end
