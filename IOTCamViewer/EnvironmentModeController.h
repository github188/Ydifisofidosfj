//
//  EnvironmentModeController.h
//  p2pcam264
//
//  Created by tutk on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCamera.h"

@protocol EnvironmentModeDelegate;

@interface EnvironmentModeController : UITableViewController<MyCameraDelegate> {
    
    NSArray *list;
    NSInteger origValue;
    NSInteger newValue;
    MyCamera *camera;
    id<EnvironmentModeDelegate> delegate;
}

@property (nonatomic, retain) NSArray *list;
@property (nonatomic) NSInteger origValue;
@property (nonatomic) NSInteger newValue;
@property (nonatomic, retain) MyCamera *camera;
@property (nonatomic, assign) id<EnvironmentModeDelegate> delegate;

- (id)initWithStyle:(UITableViewStyle)style delegate:(id<EnvironmentModeDelegate>)delegate;
- (IBAction)back:(id)sender;

@end

@protocol EnvironmentModeDelegate

- (void)didSetEnvironmentMode:(NSInteger)value;

@end