//
//  ChooseViewController.h
//  IOTCamViewer
//
//  Created by Gavin Chang on 2013/12/10.
//  Copyright (c) 2013年 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChooseDelegate <NSObject>

- (void)didSelected:(int)nTag selectedIndex:(int)nSel itemsArray:(NSArray*)arrItems;

@end

@interface ChooseViewController : UITableViewController {
	
	int mTag;
	int mSelIndex;
	NSArray* marrItems;
    NSArray* detailItems;
	
	id<ChooseDelegate> delegate;
}

@property (nonatomic, assign) int mTag;
@property (nonatomic, assign) int mSelIndex;
@property (nonatomic, retain) NSArray* marrItems;
@property (nonatomic, assign) id<ChooseDelegate> delegate;

- (void)init:(int)nTag delegate:(id<ChooseDelegate>)aDelegate selectedIndex:(int)nSel itemsArray:(NSArray*)arrItems;
@end
