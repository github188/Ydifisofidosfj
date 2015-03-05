//
//  UIToolbar+Toolbar.h
//
//  Created by Darktt on 13/9/9.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIToolbar (Toolbar)

+ (id)toolbarWithFrame:(CGRect)frame;

// Get toolbar in superview
+ (UIToolbar *)toolbarInView:(UIView *)superview withTag:(NSInteger)tag;

// Get UIBarButtonItem from current items
- (UIBarButtonItem *)itemAtIndex:(NSUInteger)index;

@end
