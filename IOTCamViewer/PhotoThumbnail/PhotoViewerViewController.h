//
//  PhotoViewerViewController.h
//  MyAlbum
//
//  Created by ZINWELL on 2012/1/13.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <IOTCamera/Camera.h>
#import "FMDatabase.h"

extern FMDatabase *database;

@class RootViewController;
@interface PhotoViewerViewController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate> {
	IBOutlet UIScrollView *scrollView;
	NSString *albumPath;
	NSString *photoFileName;
	NSMutableArray *photoArray;
	NSInteger currentPage;
	NSTimer *hideNavigationBarTimer;
    RootViewController *rootView;
    UIImageView *mainImageView;
    Camera *camera;
    
    int cameraChannel;
}
@property (nonatomic,retain) NSString *albumPath;
@property (nonatomic,retain) NSString *photoFileName;
@property (nonatomic, retain) Camera *camera;

- (void)filterImage:(int)channel;

@end