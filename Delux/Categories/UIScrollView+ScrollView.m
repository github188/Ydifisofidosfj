//
//  UIScrollView+ScrollView.m
//
//  Created by Darktt on 13/5/4.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import "UIScrollView+ScrollView.h"

@implementation UIScrollView (ScrollView)

+ (id)scrollWithFrame:(CGRect)frame
{
    UIScrollView *scroll = [[[UIScrollView alloc] initWithFrame:frame] autorelease];
    
    return scroll;
}

+ (id)scrollPagingWithFrame:(CGRect)frame
{
    UIScrollView *scroll = [self scrollWithFrame:frame];
    [scroll setPagingEnabled:YES];
    
    return scroll;
}

#pragma mark - Get scrollView in superview

+ (UIScrollView *)scrollViewInView:(UIView *)superview withTag:(NSUInteger)tag
{
    UIScrollView *scrollView = (UIScrollView *)[superview viewWithTag:tag];
    
    if (![scrollView isKindOfClass:[self class]]) {
#ifdef DEBUG
        
        NSLog(@"%s [%d] : ScrollView not found.", __func__, __LINE__);
        
#endif
        return nil;
    }
    
    return scrollView;
}

@end
