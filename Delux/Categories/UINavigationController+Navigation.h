//
//  UINavigationController+Navigation.h
//
//  Created by Darktt on 13/1/16.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (Navigation)

+ (instancetype)navigationWithRootViewController:(UIViewController *)rootViewController;
+ (instancetype)navigationWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass;

@end
