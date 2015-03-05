//
//  UIImageView+ImageView.h
//
//  Created by Darktt on 13/4/23.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (ImageView)

+ (id)imageViewWithFrame:(CGRect)frame;
+ (id)imageViewWithImage:(UIImage *)image;

+ (id)imageViewWithScreenShotFrame:(CGRect)frame;

// Get imageView in superview
+ (UIImageView *)imageViewInView:(UIView *)superview withTag:(NSInteger)tag;

@end
