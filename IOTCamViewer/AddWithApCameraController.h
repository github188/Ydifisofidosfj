//
//  AddWithApCameraController.h
//  P2PCamCEO
//
//  Created by fourones on 15/3/22.
//  Copyright (c) 2015年 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddWithApCameraController : UIViewController

@property (retain, nonatomic) IBOutlet UILabel *wifiTips;
@property (retain, nonatomic) IBOutlet UILabel *wifitips2;
@property (retain, nonatomic) IBOutlet UILabel *otherTips;
@property (retain, nonatomic) IBOutlet UIButton *wifiNextBtn;
@property (retain, nonatomic) IBOutlet UIButton *otherNextBtn;


- (IBAction)wifiNextAction:(id)sender;
- (IBAction)otherNextAction:(id)sender;

@end
