//
//  FormatSDCardController.h
//  p2pcam264
//
//  Created by tutk on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCamera.h"

@interface FormatSDCardController : UITableViewController <MyCameraDelegate, UIActionSheetDelegate> {
    
    MyCamera *camera;
}

@property (nonatomic, retain) MyCamera *camera;

- (IBAction)back:(id)sender;

@end
