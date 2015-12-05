//
//  MyAccountViewController.h
//  P2PCamCEO
//
//  Created by fourones on 15/12/5.
//  Copyright © 2015年 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyAccountViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (retain, nonatomic) IBOutlet UITableView *myTableView;
@end
