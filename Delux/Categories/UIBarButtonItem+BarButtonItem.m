//
//  UIBarButtonItem+BarButtonItem.m
//
//  Created by Darktt on 13/12/24.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import "UIBarButtonItem+BarButtonItem.h"

@implementation UIBarButtonItem (BarButtonItem)

+ (instancetype)flexibleSpace
{
    return [self barButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

+ (instancetype)barButtonSystemItem:(UIBarButtonSystemItem)systemItem target:(id)target action:(SEL)action
{
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:systemItem target:target action:action];
    
    return [buttonItem autorelease];
}

@end
