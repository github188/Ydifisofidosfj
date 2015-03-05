//
//  MotionDetectionController.h
//  IOTCamViewer
//
//  Created by tutk on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCamera.h"

@protocol MotionDetectionDelegate;

@interface MotionDetectionController : UITableViewController <MyCameraDelegate> {
    
    MyCamera *camera;
    NSArray *labelItems;
    NSInteger origValue;
    NSInteger newValue;
    id<MotionDetectionDelegate> delegate;
}

@property (nonatomic, retain) MyCamera *camera;
@property (nonatomic, retain) NSArray *labelItems;
@property (nonatomic) NSInteger origValue;
@property (nonatomic) NSInteger newValue;
@property (nonatomic, assign) id<MotionDetectionDelegate> delegate;

- (id)initWithStyle:(UITableViewStyle)style delgate:(id<MotionDetectionDelegate>)delegate;
- (IBAction)back:(id)sender;

@end

@protocol MotionDetectionDelegate

- (void)didSetMotionDetection:(NSInteger)value;

@end
