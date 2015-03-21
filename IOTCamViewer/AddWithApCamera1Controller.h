//
//  AddWithApCamera1Controller.h
//  P2PCamCEO
//
//  Created by fourones on 15/3/22.
//  Copyright (c) 2015年 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "AddWithApCamera2Controller.h"

@interface AddWithApCamera1Controller : UIViewController
{
    BOOL isConnectionWIFI;
}
@property (retain, nonatomic) IBOutlet UIImageView *image;

@property (retain, nonatomic) IBOutlet UILabel *tipsLbl;
@property (retain, nonatomic) IBOutlet UIButton *nextBtn;
- (IBAction)next:(id)sender;

@end
