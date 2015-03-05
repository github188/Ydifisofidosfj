//
//  UISearchBar+SearchBar.h
//
//  Created by Darktt on 13/9/2.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UISearchBar (SearchBar)

+ (id)searchBarWithFrame:(CGRect)frame;

// Get searchBar in superview
+ (UISearchBar *)searchBarInView:(UIView *)superview withTag:(NSUInteger)tag;

@end
