//
//  UIToolbar+Toolbar.m
//
//  Created by Darktt on 13/9/9.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import "UIToolbar+Toolbar.h"

@implementation UIToolbar (Toolbar)

+ (id)toolbarWithFrame:(CGRect)frame
{
    UIToolbar *toolbar = [[[UIToolbar alloc] initWithFrame:frame] autorelease];
    
    return toolbar;
}

#pragma mark - Get Toolbar In Superview

+ (UIToolbar *)toolbarInView:(UIView *)superview withTag:(NSInteger)tag
{
    UIToolbar *toolbar = (UIToolbar *)[superview viewWithTag:tag];
    
    if (![toolbar isKindOfClass:[self class]]) {
#ifdef DEBUG
        
        NSLog(@"%s [%d] : Toolbar not found.", __func__, __LINE__);
        
#endif
        return nil;
    }
    
    return toolbar;
}

#pragma mark - Get UIBarButtonItem At Current Items

- (UIBarButtonItem *)itemAtIndex:(NSUInteger)index
{
    UIBarButtonItem *barButtonItem = (UIBarButtonItem *)self.items[index];
    
    return barButtonItem;
}

@end
