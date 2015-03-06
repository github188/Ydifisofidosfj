//
//  AppGuidViewController.h
//  Aztech IPCam
//
//  Created by fourones on 15/3/6.
//  Copyright (c) 2015年 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppGuidViewController : UIViewController<UIScrollViewDelegate>


@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;

@property (retain, nonatomic) IBOutlet UIButton *skipBtn;
- (IBAction)skipBtnAction:(id)sender;
@property (retain, nonatomic) IBOutlet UIScrollView *scollerView;

@end
