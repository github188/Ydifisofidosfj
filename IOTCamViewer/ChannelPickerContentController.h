//
//  ChannelPickerController.h
//  IOTCamViewer
//
//  Created by tutk on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCamera.h"

@protocol ChannelPickerDelegate;

@interface ChannelPickerContentController : UITableViewController {
    
    id<ChannelPickerDelegate> delegate;
    MyCamera *camera;
    NSInteger selectedChannel;
}

@property (nonatomic, retain) id<ChannelPickerDelegate> delegate;
@property (nonatomic, retain) MyCamera *camera;
@property (nonatomic) NSInteger selectedChannel;

- (id) initWithStyle:(UITableViewStyle)style delegate:(id<ChannelPickerDelegate>)delegate defaultContentSize:(CGSize*)psizeContent;

@end

@protocol ChannelPickerDelegate
- (void)didChannelSelected:(NSInteger)channelIndex;
@end
