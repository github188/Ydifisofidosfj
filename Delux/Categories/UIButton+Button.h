//
//  UIButton+Button.h
//
//  Created by Darktt on 13/10/15.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Button)

// Get button in superview
+ (UIButton *)buttonViewInView:(UIView *)superview withTag:(NSInteger)tag;

@end
