//
//  LANSearchController.h
//  IOTCamViewer
//
//  Created by tutk on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LANSearchDelegate;

@interface LANSearchController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    
    id<LANSearchDelegate> delegate;
    UITableView *tableView;
    
    NSMutableArray *searchResult;
    
    BOOL isEasyNPLoaded;
}

@property (nonatomic, retain) id<LANSearchDelegate> delegate;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property(nonatomic) BOOL isFromAutoWifi;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id<LANSearchDelegate>)delegate;
- (IBAction)refresh:(id)sender;
- (IBAction)cancel:(id)sender;
- (void)search;
@property (retain, nonatomic) IBOutlet UIToolbar *toolBar;


@end

@protocol LANSearchDelegate

@optional
- (void) lanSearchController:(LANSearchController *)controller
               didSearchResult:(NSString *)uid
                          ip:(NSString *)ip
                        port:(NSInteger)port;

- (void) didSelectUID:(NSString *)selectedUid;

@end