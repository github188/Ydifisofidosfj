//
//  RecordingModeController.h
//  IOTCamViewer
//
//  Created by tutk on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCamera.h"

@protocol RecordingModeDelegate;

@interface RecordingModeController : UITableViewController <MyCameraDelegate> {
    
    MyCamera *camera;
    NSArray *labelItems;
    NSInteger origValue;
    NSInteger newValue;
    
    id<RecordingModeDelegate> delegate;
}

@property (nonatomic, retain) MyCamera *camera;
@property (nonatomic, retain) NSArray *labelItems;
@property (nonatomic) NSInteger origValue;
@property (nonatomic) NSInteger newValue;
@property (nonatomic, assign) id<RecordingModeDelegate> delegate;

- (id)initWithStyle:(UITableViewStyle)style delegate:(id<RecordingModeDelegate>)delegate;
- (IBAction)back:(id)sender;

@end

@protocol RecordingModeDelegate 

- (void)didSetRecordingMode:(NSInteger)value;

@end
