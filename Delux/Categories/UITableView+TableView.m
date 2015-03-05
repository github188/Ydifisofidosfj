//
//  UITableView+TableView.m
//
//  Created by Darktt on 13/3/22.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import "UITableView+TableView.h"

@implementation UITableView (TableView)

+ (id)tableViewWithFrame:(CGRect)frame style:(UITableViewStyle)tableViewStyle forTarger:(id<UITableViewDataSource, UITableViewDelegate>)targer
{
    UITableView *table = [[[UITableView alloc] initWithFrame:frame style:tableViewStyle] autorelease];
    
    [table setDataSource:(id<UITableViewDataSource>)targer];
    [table setDelegate:(id<UITableViewDelegate>)targer];
    
    return table;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)tableViewStyle forTarger:(id<UITableViewDataSource, UITableViewDelegate>)targer
{
    self = [self initWithFrame:frame style:tableViewStyle];
    
    if (self == nil) return nil;
    
    [self setDelegate:targer];
    
    return self;
}

#pragma mark - Get tableView in superview

+ (UITableView *)tableViewInView:(UIView *)superview withTag:(NSInteger)tag
{
    UITableView *tableView = (UITableView *)[superview viewWithTag:tag];
    
    if (![tableView isKindOfClass:[self class]]) {
#ifdef DEBUG
        
        NSLog(@"%s [%d] : TableView not found.", __func__, __LINE__);
        
#endif
        return nil;
    }
    
    return tableView;
}

@end
