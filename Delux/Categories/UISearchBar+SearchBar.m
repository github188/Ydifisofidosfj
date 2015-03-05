//
//  UISearchBar+SearchBar.m
//
//  Created by Darktt on 13/9/2.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import "UISearchBar+SearchBar.h"

@implementation UISearchBar (SearchBar)

+ (id)searchBarWithFrame:(CGRect)frame
{
    UISearchBar *searchBar = [[[UISearchBar alloc] initWithFrame:frame] autorelease];
    
    return searchBar;
}

#pragma mark - Get searchBar in superview

+ (UISearchBar *)searchBarInView:(UIView *)superview withTag:(NSUInteger)tag
{
    UISearchBar *searchBar = (UISearchBar *)[superview viewWithTag:tag];
    
    if (![searchBar isKindOfClass:[UISearchBar class]]) {
#ifdef DEBUG
        
        NSLog(@"%s [%d] : SearchBar not found.", __func__, __LINE__);
        
#endif
        return nil;
    }
    
    return searchBar;
}

@end
