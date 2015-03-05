//
//  UINavigationController+Navigation.m
//
//  Created by Darktt on 13/1/16.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import "UINavigationController+Navigation.h"

@implementation UINavigationController (Navigation)

+ (instancetype)navigationWithRootViewController:(UIViewController *)rootViewController
{
    UINavigationController *navigation = [[[UINavigationController alloc] initWithRootViewController:rootViewController] autorelease];
    
    return navigation;
}

+ (instancetype)navigationWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass
{
    UINavigationController *navigation = [[[UINavigationController alloc] initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass] autorelease];
    
    return navigation;
}

//- (UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleLightContent;
//}

#pragma mark - Autorotate Methods

- (NSUInteger)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    }
    
    return YES;
}

@end
