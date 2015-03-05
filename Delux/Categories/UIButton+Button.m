//
//  UIButton+Button.m
//
//  Created by Darktt on 13/10/15.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import "UIButton+Button.h"

@implementation UIButton (Button)

#pragma mark - Get imageView in superview

+ (UIButton *)buttonViewInView:(UIView *)superview withTag:(NSInteger)tag
{
    UIButton *button = (UIButton *)[superview viewWithTag:tag];
    
    if (![button isKindOfClass:[self class]]) {
#ifdef DEBUG
        
        NSLog(@"%s [%d] : Button not found.", __func__, __LINE__);
        
#endif
        return nil;
    }
    
    return button;
}

@end
