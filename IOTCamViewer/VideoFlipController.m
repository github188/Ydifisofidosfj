//
//  VideoClipController.m
//  p2pcam264
//
//  Created by tutk on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <IOTCamera/AVIOCTRLDEFs.h>
#import "VideoFlipController.h"

@implementation VideoFlipController
@synthesize flip_list;
@synthesize origValue;
@synthesize newValue;
@synthesize camera;
@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style delegate:(id<VideoFlipDelegate>)delegate_ {
    
    self = [super initWithStyle:style];
    
    if (self) {
        
        self.delegate = delegate_;
    }
    
    return self;
}

- (void)back:(id)sender {
    
    if (newValue != -1 && origValue != newValue) {
        
        SMsgAVIoctrlSetVideoModeReq *s = malloc(sizeof(SMsgAVIoctrlSetVideoModeReq));
        memset(s, 0, sizeof(SMsgAVIoctrlSetVideoModeReq));
        
        s->channel = 0;
        s->mode = newValue;
        
        [camera sendIOCtrlToChannel:0 
                               Type:IOTYPE_USER_IPCAM_SET_VIDEOMODE_REQ 
                               Data:(char *)s 
                           DataSize:sizeof(SMsgAVIoctrlSetVideoModeReq)];
        
        free(s);
        
        if (self.delegate) [self.delegate didSetVideoFlip:newValue];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    
    self.delegate = nil;
    [camera release];
    [flip_list release];
    [super dealloc];
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    
    self.flip_list = [[[NSArray alloc] initWithObjects:NSLocalizedString(@"Normal", @""),
                      NSLocalizedString(@"Vertical Flip", @""), 
                      NSLocalizedString(@"Horizontal Flip (Mirror)", @""), 
                      NSLocalizedString(@"Vertical and Horizontal Flip", @""), nil] autorelease];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
                                             initWithTitle:NSLocalizedString(@"Back", @"") style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    self.navigationItem.title = NSLocalizedString(@"Video Flip", @"");
    
    self.newValue = -1;
    
    [super viewDidLoad];
}

- (void)viewDidUnload {
    
    self.delegate = nil;
    self.camera = nil;
    self.flip_list = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.camera.delegate2 = self;
    [super viewWillAppear:animated];
}

#pragma mark - Table DataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section {
    
    return [flip_list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CheckMarkCellIdentifier = @"CheckMarkCellIdentifier";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CheckMarkCellIdentifier];
    
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CheckMarkCellIdentifier]
                autorelease];
    }
    
    NSUInteger row = [indexPath row];    
    
    cell.textLabel.text = [flip_list objectAtIndex:row];
    cell.accessoryType = (row == self.origValue) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;    
}

#pragma mark - Table Delegate Methods
- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    for (UITableViewCell *cell in [self.tableView visibleCells])
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    self.newValue = [indexPath row];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - MyCameraDelegate Delegate Methods
- (void)camera:(MyCamera *)camera_ _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size {
    
    if (camera_ == camera && type == IOTYPE_USER_IPCAM_GET_VIDEOMODE_RESP) {
        
        SMsgAVIoctrlGetVideoModeResp *s = (SMsgAVIoctrlGetVideoModeResp*)data;        
        self.origValue = s->mode;        
        
        [self.tableView reloadData];
    }
}
@end
