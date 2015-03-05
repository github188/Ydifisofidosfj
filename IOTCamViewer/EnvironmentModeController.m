//
//  EnvironmentModeController.m
//  p2pcam264
//
//  Created by tutk on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EnvironmentModeController.h"
#import <IOTCamera/AVIOCTRLDEFs.h>

@implementation EnvironmentModeController
@synthesize list;
@synthesize origValue;
@synthesize newValue;
@synthesize camera;
@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style delegate:(id<EnvironmentModeDelegate>)delegate_ {
    
    self = [super initWithStyle:style];
    
    if (self) {
        
        self.delegate = delegate_;
    }
    
    return self;
}

- (void)back:(id)sender {
    
    if (newValue != -1 && origValue != newValue) {
        
        SMsgAVIoctrlSetEnvironmentReq *s = malloc(sizeof(SMsgAVIoctrlSetEnvironmentReq));
        memset(s, 0, sizeof(SMsgAVIoctrlSetEnvironmentReq));
        
        s->channel = 0;
        s->mode = newValue;
        
        [camera sendIOCtrlToChannel:0 
                               Type:IOTYPE_USER_IPCAM_SET_ENVIRONMENT_REQ 
                               Data:(char *)s 
                           DataSize:sizeof(SMsgAVIoctrlSetEnvironmentReq)];
        
        free(s);
        
        if (self.delegate) [self.delegate didSetEnvironmentMode:newValue];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    
    self.delegate = nil;
    [camera release];
    [list release];
    [super dealloc];
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    
    self.list = [[[NSArray alloc] initWithObjects:NSLocalizedString(@"Indoor Mode(50Hz)", @""),
                 NSLocalizedString(@"Indoor Mode(60Hz)", @""), 
                 NSLocalizedString(@"Outdoor Mode", @""), 
                 NSLocalizedString(@"Night Mode", @""), nil] autorelease];
    
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
    
    self.navigationItem.title = NSLocalizedString(@"Environment Mode", @"");
    
    self.newValue = -1;
    
    [super viewDidLoad];
}

- (void)viewDidUnload {
    
    self.delegate = nil;
    self.camera = nil;
    self.list = nil;
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
    
    return [list count];
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
    
    cell.textLabel.text = [list objectAtIndex:row];
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
        
    if (camera_ == camera && type == IOTYPE_USER_IPCAM_GET_ENVIRONMENT_RESP) {
        
        SMsgAVIoctrlGetEnvironmentResp *s = (SMsgAVIoctrlGetEnvironmentResp*)data;        
        self.origValue = s->mode;        
        
        [self.tableView reloadData];
    }
}
@end
