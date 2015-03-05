//
//  CheckSSIDViewController.h
//  IOTCamViewer
//
//  Created by TUTK_MacMini2 on 14/5/13.
//  Copyright (c) 2014年 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckSSIDViewController : UIViewController {
    NSString *uid;
    IBOutlet UIImageView *bgImage;
    IBOutlet UIView *cautionView;
    IBOutlet UILabel *cautionLabel;
}

@property(nonatomic,retain) NSString *uid;

@end
