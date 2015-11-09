//
//  BayitCamViewController.h
//  P2PCamCEO
//
//  Created by fourones on 11/9/15.
//  Copyright © 2015 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraMultiLiveViewController.h"

@interface BayitCamViewController : UIViewController

- (IBAction)skip:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *skipBtn;


@property (retain, nonatomic) IBOutlet UILabel *attentionLbl;
@property (retain, nonatomic) IBOutlet UILabel *infoTextView;


@property (retain, nonatomic) IBOutlet UIButton *urlBtn;
- (IBAction)urlAction:(id)sender;
@end
