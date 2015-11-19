//
//  BayitCamViewController.h
//  P2PCamCEO
//
//  Created by fourones on 11/9/15.
//  Copyright © 2015 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraMultiLiveViewController.h"
#import "UIMyWebView.h"

@interface BayitCamViewController : UIViewController
{
    UIMyWebView *webView;
}

- (IBAction)skip:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *skipBtn;


@property (retain, nonatomic) IBOutlet UILabel *attentionLbl;
@property (retain, nonatomic) IBOutlet UILabel *infoTextView;

@property(nonatomic) BOOL isFromFormUI;


@property (retain, nonatomic) IBOutlet UIButton *remeberBtn;
- (IBAction)remberClick:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *remberLbl;
@end
