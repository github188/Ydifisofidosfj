//
//  VideoQualityController.m
//  IOTCamViewer
//
//  Created by tutk on 12/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <IOTCamera/AVIOCTRLDEFs.h>
#import "VideoQualityController.h"

@implementation VideoQualityController

@synthesize quality_list;
@synthesize origValue;
@synthesize newValue;
@synthesize camera;
@synthesize delegate;


- (id)initWithStyle:(UITableViewStyle)style delegate:(id<VideoQualityDelegate>)delegate_ {
    
    self = [super initWithStyle:style];
    
    if (self) {
        
        self.delegate = delegate_;
    }
    
    return self;
}

- (IBAction)back:(id)sender {
    
    if (newValue != -1 && origValue != newValue) {
        
        SMsgAVIoctrlSetStreamCtrlReq *s = malloc(sizeof(SMsgAVIoctrlSetStreamCtrlReq));
        memset(s, 0, sizeof(SMsgAVIoctrlSetStreamCtrlReq));
        
        s->channel = 0;
        s->quality = newValue;
        
        [camera sendIOCtrlToChannel:0 
                               Type:IOTYPE_USER_IPCAM_SETSTREAMCTRL_REQ 
                               Data:(char *)s 
                           DataSize:sizeof(SMsgAVIoctrlSetStreamCtrlReq)];
         
        free(s);
        
        if (self.delegate) [self.delegate didSetVideoQuality:newValue];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    
    [camera release];
    [quality_list release];
    [super dealloc];
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    
    self.quality_list = [[[NSArray alloc] initWithObjects:
                         //NSLocalizedString(@"Unknown", @""), 
                         NSLocalizedString(@"Max", @""), 
                         NSLocalizedString(@"High", @""), 
                         NSLocalizedString(@"Medium", @""), 
                         NSLocalizedString(@"Low", @""), 
                         NSLocalizedString(@"Min", @""), nil] autorelease];
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:NSLocalizedString(@"Back", @"") style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    
    self.navigationItem.title = NSLocalizedString(@"Video Quality", @"");

    self.newValue = -1;

    [super viewDidLoad];
}

- (void)viewDidUnload {
        
    self.delegate = nil;
    self.camera = nil;
    self.quality_list = nil;
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
 
    return [quality_list count];
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
    
    cell.textLabel.text = [quality_list objectAtIndex:row];
    cell.accessoryType = (row == (self.origValue - 1)) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;    
}

#pragma mark - Table Delegate Methods
- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    for (UITableViewCell *cell in [self.tableView visibleCells])
        cell.accessoryType = UITableViewCellAccessoryNone;

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;

    self.newValue = [indexPath row] + 1;
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - CameraDelegate Delegate Methods
- (void)camera:(MyCamera *)camera_ _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size {
    
    if (camera_ == camera && type == IOTYPE_USER_IPCAM_GETSTREAMCTRL_RESP) {
        
        SMsgAVIoctrlGetStreamCtrlResp *s = (SMsgAVIoctrlGetStreamCtrlResp*) data;
        self.origValue = s->quality;        
        
        [self.tableView reloadData];
    }
}
@end
