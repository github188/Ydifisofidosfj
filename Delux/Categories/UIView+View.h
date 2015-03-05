//
//  UIView+View.h
//
//  Created by Darktt on 13/4/15.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^UIViewAnimationsBlock) (void);
typedef void (^UIViewCompletionBlock) (BOOL finshed);

@interface UIView (View)

@property (nonatomic, assign) CGPoint   origin;
@property (nonatomic, assign) CGSize    size;
@property (nonatomic, assign) CGFloat   x;
@property (nonatomic, assign) CGFloat   y;
@property (nonatomic, assign) CGFloat   width;
@property (nonatomic, assign) CGFloat   height;

+ (id)viewWithFrame:(CGRect)frame;
+ (id)viewWithFrame:(CGRect)frame backgroundColor:(UIColor *)bgColor;

- (void)addSubviews:(NSArray *)views;

@end
