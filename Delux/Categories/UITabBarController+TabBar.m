//
//  UITabBarController+TabBar.m
//
//  Created by Darktt on 13/1/16.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import "UITabBarController+TabBar.h"

@implementation UITabBarController (TabBar)

+ (id)defauleTabBar
{
    UITabBarController *tabBar = [[UITabBarController new] autorelease];
    
    return tabBar;
}

+ (id)tabBarWithViewControllers:(NSArray *)viewControllers
{
    UITabBarController *tabBar = [[UITabBarController new] autorelease];
    [tabBar setViewControllers:viewControllers];
    
    return tabBar;
}

@end
