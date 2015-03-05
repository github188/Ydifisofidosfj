//
//  UIView+View.m
//
//  Created by Darktt on 13/4/15.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import "UIView+View.h"

@implementation UIView (View)

+ (id)viewWithFrame:(CGRect)frame
{
    UIView *view = [[[UIView alloc] initWithFrame:frame] autorelease];
    
    return view;
}

+ (id)viewWithFrame:(CGRect)frame backgroundColor:(UIColor *)bgColor
{
    UIView *view = [[[UIView alloc] initWithFrame:frame] autorelease];
    [view setBackgroundColor:bgColor];
    
    return view;
}

#pragma mark - Override Property Methods

- (void)setOrigin:(CGPoint)origin
{
    CGRect selfFrame = self.frame;
    
    selfFrame.origin = origin;
    
    [self setFrame:selfFrame];
}

- (CGPoint)origin
{
    return self.frame.origin;
}

- (void)setSize:(CGSize)size
{
    CGRect selfFrame = self.frame;
    
    selfFrame.size = size;
    
    [self setFrame:selfFrame];
}

- (CGSize)size
{
    return self.frame.size;
}

- (void)setX:(CGFloat)x
{
    CGRect selfFrame = self.frame;
    
    selfFrame.origin.x = x;
    
    [self setFrame:selfFrame];
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y
{
    CGRect selfFrame = self.frame;
    
    selfFrame.origin.y = y;
    
    [self setFrame:selfFrame];
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setWidth:(CGFloat)width
{
    CGRect selfFrame = self.frame;
    
    selfFrame.size.width = width;
    
    [self setFrame:selfFrame];
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height
{
    CGRect selfFrame = self.frame;
    
    selfFrame.size.height = height;
    
    [self setFrame:selfFrame];
}

- (CGFloat)height
{
    return self.frame.size.height;
}

#pragma mark - Instance Method

- (void)addSubviews:(NSArray *)views
{
    void (^enumBlock) (id, NSUInteger, BOOL *) = ^(UIView *view, NSUInteger index, BOOL *stop){
        if (![view isKindOfClass:[UIView class]]) {
            [NSException raise:NSInvalidArgumentException format:@"%@-line %d: %@ not UIView class.", [self class], __LINE__, view];
        }
        
        [self addSubview:view];
    };
    
    [views enumerateObjectsUsingBlock:enumBlock];
}

@end
