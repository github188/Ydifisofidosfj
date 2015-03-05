//
//  DetailViewController.h
//  IOTCamViewer
//
//  Created by TUTK_MacMini2 on 13/11/24.
//  Copyright (c) 2013年 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
