//
//  VideoClipController.h
//  p2pcam264
//
//  Created by tutk on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCamera.h"

@protocol VideoFlipDelegate;

@interface VideoFlipController : UITableViewController <MyCameraDelegate> {
    
    NSArray *flip_list;
    NSInteger origValue;
    NSInteger newValue;
    MyCamera *camera;
    id<VideoFlipDelegate> delegate;
}

@property (nonatomic, retain) NSArray *flip_list;
@property (nonatomic) NSInteger origValue;
@property (nonatomic) NSInteger newValue;
@property (nonatomic, retain) MyCamera *camera;
@property (nonatomic, assign) id<VideoFlipDelegate> delegate;

- (id)initWithStyle:(UITableViewStyle)style delegate:(id<VideoFlipDelegate>)delegate;
- (IBAction)back:(id)sender;

@end

@protocol VideoFlipDelegate

- (void)didSetVideoFlip:(NSInteger)value;

@end
