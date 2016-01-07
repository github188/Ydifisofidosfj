//
//  FullTimeRECViewController.h
//  temptest
//
//  Created by apple  on 16/1/6.
//  Copyright © 2016年 jayzhou. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FullTimeRECViewController;

@protocol FullTimeRECViewControllerDelegate <NSObject>
@optional
- (void)fullTimeRECViewController:(FullTimeRECViewController *)fullTimeVC scheduleFullTimeFrom:(NSInteger)strat to:(NSInteger)end withRECTime:timeLenght;
@end
@interface FullTimeRECViewController : UIViewController
@property (nonatomic ,assign) int RECLength;
@property (nonatomic, assign) id<FullTimeRECViewControllerDelegate> delegate;

@end
