//
//  UITableView+TableView.h
//
//  Created by Darktt on 13/3/22.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (TableView)

+ (id)tableViewWithFrame:(CGRect)frame style:(UITableViewStyle)tableViewStyle forTarger:(id<UITableViewDataSource, UITableViewDelegate>)targer;

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)tableViewStyle forTarger:(id<UITableViewDataSource, UITableViewDelegate>)targer;

// Get tableView in superview
+ (UITableView *)tableViewInView:(UIView *)superview withTag:(NSInteger)tag;

@end
