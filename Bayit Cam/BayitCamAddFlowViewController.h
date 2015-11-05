//
//  BayitCamAddFlowViewController.h
//  P2PCamCEO
//
//  Created by limingru on 15/11/5.
//  Copyright © 2015年 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BayitCamAddFlowViewController : UIViewController

@property (retain, nonatomic) IBOutlet UILabel *firstLbl;
@property (retain, nonatomic) IBOutlet UITextView *firstTextView;
@property (retain, nonatomic) IBOutlet UIButton *firstBtn;
- (IBAction)firstAction:(id)sender;

@property (retain, nonatomic) IBOutlet UILabel *secondLbl;
@property (retain, nonatomic) IBOutlet UITextView *secondTextView;
@property (retain, nonatomic) IBOutlet UIButton *secondBtn;
- (IBAction)secondAction:(id)sender;

@end
