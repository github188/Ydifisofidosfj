//
//  VideoQualityController.h
//  IOTCamViewer
//
//  Created by tutk on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCamera.h"

@protocol VideoQualityDelegate;

@interface VideoQualityController : UITableViewController <MyCameraDelegate> {
    
    NSArray *quality_list;
    NSInteger origValue;
    NSInteger newValue;
    MyCamera *camera;
    id<VideoQualityDelegate> delegate;
}

@property (nonatomic, retain) NSArray *quality_list;
@property (nonatomic) NSInteger origValue;
@property (nonatomic) NSInteger newValue;
@property (nonatomic, retain) MyCamera *camera;
@property (nonatomic, assign) id<VideoQualityDelegate> delegate;

- (id)initWithStyle:(UITableViewStyle)style delegate:(id<VideoQualityDelegate>)delegate;
- (IBAction)back:(id)sender;

@end

@protocol VideoQualityDelegate

- (void)didSetVideoQuality:(NSInteger)value;

@end
