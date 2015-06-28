//
//  CameraListForEventsController.m
//  IOTCamViewer
//
//  Created by tutk on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CameraListForEventsController.h"
#import "EventListController.h"
#import "DDBadgeViewCell.h"

@implementation CameraListForEventsController

@synthesize tableViewCell;

- (NSString *) pathForDocumentsResource:(NSString *) relativePath 
{    
    static NSString* documentsPath = nil;
    
    if (nil == documentsPath) {
        
        NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsPath = [[[dirs objectAtIndex:0] stringByAppendingPathComponent:NOTBACKUPDIR] retain];
    }
    
    return [documentsPath stringByAppendingPathComponent:relativePath];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark - View lifecycle

- (void)viewDidLoad 
{
    self.navigationController.navigationBar.translucent = NO;
    
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.opaque = YES;
    self.tableView.backgroundView = nil;    
    self.navigationItem.title = NSLocalizedString(@"Events", nil);
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    self.tableViewCell = nil;
}

- (void)dealloc
{
    [tableViewCell release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];

    for(MyCamera *camera in camera_list)
        camera.delegate2 = self;
    
    NSLog(@"CameraListForEventController - set camera delegate");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.tableView reloadData];
}

#pragma mark - Table Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return (section == 0) ? [camera_list count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString *CameraListCellIdentifier = @"CameraListCellIdentifier";
    DDBadgeViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CameraListCellIdentifier];
    
    if (cell == nil) {
        
        cell = [[[DDBadgeViewCell alloc]
                 initWithStyle:UITableViewCellStyleSubtitle 
                 reuseIdentifier:CameraListCellIdentifier] autorelease];
    }    
    
    // Configure the cell
    NSUInteger row = [indexPath row];
    
    MyCamera *camera = [camera_list objectAtIndex:row];   
    
    cell.textLabel.text = camera.name;
    cell.detailTextLabel.text = camera.uid;
    
    int cnt = camera.remoteNotifications;
    
    if (cnt > 0) {
        cell.badgeText = [NSString stringWithFormat:@"%d", cnt];   
        cell.badgeColor = [UIColor redColor];
        cell.badgeHighlightedColor = [UIColor lightGrayColor];
    }
    else {
        cell.badgeText = nil;
        cell.badgeColor = [UIColor clearColor];
        cell.badgeHighlightedColor = [UIColor clearColor];
    }
    
    if ([camera getEventListSupportOfChannel:0])
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;

    return cell;
}

#pragma mark - TableView Delegate Methods

- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSUInteger row = [indexPath row];
    MyCamera *camera = [camera_list objectAtIndex:row];
    
    if (camera != NULL && [camera getEventListSupportOfChannel:0]) {

        EventListController *controller = [[EventListController alloc] initWithStyle:UITableViewStylePlain];
        // EventListController *controller = [[EventListController alloc] initWithNibName:@"EventList" bundle:nil];
        
        controller.camera = [camera_list objectAtIndex:[indexPath row]];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
}

#pragma mark - MyCameraDelegate Methods
- (void)camera:(MyCamera *)camera _didReceiveRemoteNotification:(NSInteger)eventType EventTime:(long)eventTime
{
    self.tabBarItem.badgeValue = @"!";
}

- (void)camera:(MyCamera *)camera _didChangeChannelStatus:(NSInteger)channel ChannelStatus:(NSInteger)status
{
    if (!self.tableView.editing)
        [self.tableView reloadData];
}
@end