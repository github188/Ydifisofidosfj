//
//  UIBarButtonItem+BarButtonItem.h
//
//  Created by Darktt on 13/12/24.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (BarButtonItem)

+ (instancetype)flexibleSpace;
+ (instancetype)barButtonSystemItem:(UIBarButtonSystemItem)systemItem target:(id)target action:(SEL)action;

@end
