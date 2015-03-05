//
//  DropboxSettingVC.m
//  IOTCamViewer
//
//  Created by Victor on 2013/12/17.
//  Copyright (c) 2013年 TUTK. All rights reserved.
//

#import "DropboxSettingVC.h"
#import "MyCamera.h"
#import "DDBadgeViewCell.h"
#import <IOTCamera/AVIOCTRLDEFs.h>


@implementation DropboxSettingVC

@synthesize tableView = _tableView;
@synthesize dropboxBtn = _dropboxBtn;
@synthesize cameras = _cameras;


- (IBAction)refreshCamera:(id)sender
{
    [self queryCameraStatus];
}

-(void) updateCameraList {
    
    [self.cameras removeAllObjects];
    
    for ( MyCamera *camera in camera_list ){
        if ( camera.isSupportDropbox) {
            [self.cameras addObject:camera];
        }
    }
}

- (void)backThisView {

    [self updateCameraList];
    [self updateButtons];
    [self.tableView reloadData];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    customButton.frame = CGRectMake(0, 0, 44, 44);
    [customButton setBackgroundImage:[UIImage imageNamed:@"cam_back" ] forState:UIControlStateNormal];
    [customButton setBackgroundImage:[UIImage imageNamed:@"cam_back_clicked"] forState:UIControlStateHighlighted];
    [customButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:customButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -16;
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, backButton, nil];
    [backButton release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backThisView) name:@"Agree" object:nil];

    NSString *title = [[NSString alloc] initWithString:NSLocalizedString(@"Dropbox Setting", @"")];
    self.navigationItem.title = title;
    [title release];
    
    self.cameras = [[[NSMutableArray alloc] initWithCapacity:[camera_list count]] autorelease];
    
    [self.tableView setAllowsSelection:NO];
    
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    float ver = [[UIDevice currentDevice].systemVersion floatValue];
    if ( ver >= 7.0f){
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
#endif
    
    [self updateButtons];
    
    if ([[DBSession sharedSession] isLinked]) {
        [self updateCameraList];
        
        SMsgAVIoctrlGetDropbox dummy ={0};

        for (MyCamera *camera in self.cameras ){
            camera.delegate2 = self;
            
            [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GET_SAVE_DROPBOX_REQ Data:(char *)&dummy DataSize:sizeof(dummy)];
        }
    }
    
    else {
        [self.cameras removeAllObjects];
    }

    [self.tableView reloadData];
    
    self.navigationController.navigationBar.translucent = NO;
}

-(void)viewWillDisappear:(BOOL)animated {
    
    for ( MyCamera *camera in self.cameras){
        camera.delegate2 = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_dropboxBtn release];
    [_tableView release];
    [_cameras release];
    [super dealloc];
}

- (void)viewDidUnload {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Agree" object:nil];
    
    [self setDropboxBtn:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}

- (IBAction)onDrobpxClick:(id)sender {
    if (![[DBSession sharedSession] isLinked]) {
		[[DBSession sharedSession] linkFromController:self];
    }
    
    else {
        
        [[DBSession sharedSession] unlinkAll];
        [[[[UIAlertView alloc]
           initWithTitle:NSLocalizedString(@"Account Unlinked!", @"") message:NSLocalizedString(@"Your dropbox account has been unlinked", @"")
           delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil]
          autorelease]
         show];
        
        //對所有cam送unlink的cmd
        //[self unlinkAllCamera];
        [self.cameras removeAllObjects];
        
        [self updateButtons];
        [self.tableView reloadData];
        
        UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] init];
        self.navigationItem.rightBarButtonItem = refreshButton;
        
    }
}

- (IBAction)onTestClick:(id)sender {

    for ( MyCamera *camera in self.cameras ){

        [self camera:camera LinkDropbox:NO];
    }
}

- (void)updateButtons {
    UIImage *bgImage = [[DBSession sharedSession] isLinked] ? [UIImage imageNamed:@"drop_unlink"] : [UIImage imageNamed:@"drop_link"];
    UIImage *bgImageClicked = [[DBSession sharedSession] isLinked] ? [UIImage imageNamed:@"drop_unlink_clicked"] : [UIImage imageNamed:@"drop_link_clicked"];
    [self.dropboxBtn setBackgroundImage:bgImage forState:UIControlStateNormal];
    [self.dropboxBtn setBackgroundImage:bgImageClicked forState:UIControlStateHighlighted];
    
    
    if ([[DBSession sharedSession] isLinked]){
        UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
        customButton.frame = CGRectMake(0, 0, 44, 44);
        [customButton setBackgroundImage:[UIImage imageNamed:@"drop_refresh" ] forState:UIControlStateNormal];
        [customButton setBackgroundImage:[UIImage imageNamed:@"drop_refresh_clicked"] forState:UIControlStateHighlighted];
        
        [customButton addTarget:self action:@selector(refreshCamera:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithCustomView:customButton];
        self.navigationItem.rightBarButtonItem = refreshButton;
        [refreshButton release];
    }
}


-(void)queryCameraStatus{
    
    SMsgAVIoctrlGetDropbox dummy ={0};
    for ( MyCamera *camera in self.cameras ){
        [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GET_SAVE_DROPBOX_REQ Data:(char *)&dummy DataSize:sizeof(dummy)];
    }
}

-(void)unlinkAllCamera{
    
    for (MyCamera *camera in self.cameras){
        if ( camera.isLinkDropbox ){
            [self camera:camera LinkDropbox:NO];
        }
    }
}

-(void)camera:(MyCamera*)camera LinkDropbox:(BOOL) isLink {
    
    SMsgAVIoctrlSetDropbox setDropbox = {0};
    NSString *uuid = [[[ UIDevice currentDevice] identifierForVendor] UUIDString];
    
    if ( isLink ){
        setDropbox.nLinked = 1 ;
        
        strcpy(setDropbox.szLinkUDID, [uuid UTF8String]);
        
        NSArray *ids = [[DBSession sharedSession] userIds];
        if ( ids.count < 1 ){
            return ;
        }
            
        MPOAuthCredentialConcreteStore *ca ;
        ca = [[DBSession sharedSession] credentialStoreForUserId:[ids objectAtIndex:0]];
        
        strcpy( setDropbox.szAccessToken , [ca.accessToken UTF8String]);
        strcpy( setDropbox.szAccessTokenSecret , [ca.accessTokenSecret UTF8String]);
        strcpy( setDropbox.szAppKey , [@"zo6kr8w12onxr8c" UTF8String]);
        strcpy( setDropbox.szSecret , [@"0xjdiq7mrprnsat" UTF8String]);

    } else {
        setDropbox.nLinked = 0 ;
        strcpy(setDropbox.szLinkUDID, [uuid UTF8String]);
    }
    
    [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_SET_SAVE_DROPBOX_REQ Data:(char *)&setDropbox DataSize:sizeof(setDropbox)];
}


// need <UITableViewDelegate,UITableViewDataSource>
#pragma mark - Table view data source

#if 0
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}
#endif

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.cameras count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CameraListCellIdentifier = @"CameraListCellIdentifier";
    DDBadgeViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CameraListCellIdentifier];
    UISwitch *check = nil;
    NSUInteger row = [indexPath row];
    MyCamera *camera = [self.cameras objectAtIndex:row];
    
    if (cell == nil) {
        
        cell = [[[DDBadgeViewCell alloc]
                 initWithStyle:UITableViewCellStyleSubtitle
                 reuseIdentifier:CameraListCellIdentifier] autorelease];
        
        CGFloat with = 80 ;
        CGFloat height = cell.frame.size.height -5;
        CGFloat x = cell.frame.size.width - with -5;
        CGFloat y = 15 ;
        
        check = [[UISwitch alloc] initWithFrame:CGRectMake( x, y, with, height)];
        check.tag = row;
        cell.accessoryView = check;
        [check addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];

    }
    
    NSLog(@"CELL:%@",cell.contentView.subviews[0]);
    
    if (check==nil) {

        check = (UISwitch *)cell.accessoryView;
    }
    
    [check setOn:camera.isLinkDropbox ? YES : NO];
    
    // Configure the cell
    
    cell.textLabel.text = camera.name;
    cell.detailTextLabel.text = camera.uid;
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.badgeText = nil;
    cell.badgeColor = [UIColor clearColor];
    cell.badgeHighlightedColor = [UIColor clearColor];

    return cell;

}

-(void) switchChanged:(id)sender {
    
    UISwitch *check = (UISwitch*)sender;
    int idx = check.tag;
    NSLog(@"idx = %d, %d", idx, check.isOn);
    
    MyCamera *camera = [self.cameras objectAtIndex:idx];
    
    if ( check.isOn ) {
        camera.isLinkDropbox = YES;
    }
    else {
        camera.isLinkDropbox = NO;
    }
    
    [self camera:camera LinkDropbox:check.isOn];
}

#pragma mark - CameraDelegate
- (void)camera:(MyCamera *)camera_ _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char*)data DataSize:(NSInteger)size {
    
    switch (type) {
        case IOTYPE_USER_IPCAM_GET_SAVE_DROPBOX_RESP:
        {
            SMsgAVIoctrlGetDropbox *s = (SMsgAVIoctrlGetDropbox *)data;
            
            camera_.isLinkDropbox = NO;
            if (s->nLinked == 1) {
                
                NSString *uuid = [[[ UIDevice currentDevice] identifierForVendor] UUIDString];
                if ( [uuid isEqualToString:[ NSString stringWithUTF8String:s->szLinkUDID]]){
                    camera_.isLinkDropbox = YES;
                } else {
                    camera_.isLinkDropbox = NO;
                }
            }
            
            for (int i=0;i<[self.cameras count];i++) {
                MyCamera* tempCamera = [self.cameras objectAtIndex:i];
                if ([tempCamera.uid isEqualToString:camera_.uid]){
                    [self.cameras replaceObjectAtIndex:i withObject:camera_];
                }
            }
            
            [self.tableView reloadData];
        }
            
            break;
            
        case IOTYPE_USER_IPCAM_SET_SAVE_DROPBOX_RESP:
            NSLog(@"IOTYPE_USER_IPCAM_SET_SAVE_DROPBOX_RESP\n");
            break;
            
        default:
            break;
    }
}


@end
