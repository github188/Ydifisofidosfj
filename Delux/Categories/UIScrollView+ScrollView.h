//
//  UIScrollView+ScrollView.h
//
//  Created by Darktt on 13/5/4.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (ScrollView)

+ (id)scrollWithFrame:(CGRect)frame;
+ (id)scrollPagingWithFrame:(CGRect)frame;

// Get scrollView in superview
+ (UIScrollView *)scrollViewInView:(UIView *)superview withTag:(NSUInteger)tag;

@end
