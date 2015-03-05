//
//  MotionDetectionController.m
//  IOTCamViewer
//
//  Created by tutk on 12/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <IOTCamera/AVIOCTRLDEFs.h>
#import "MotionDetectionController.h"

@implementation MotionDetectionController

@synthesize camera;
@synthesize labelItems;
@synthesize newValue;
@synthesize origValue;
@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style delgate:(id<MotionDetectionDelegate>)delegate_ {
    
    self = [super initWithStyle:style];
    
    if (self) {
        
        self.delegate = delegate_;
    }
    
    return self;
}

- (IBAction)back:(id)sender {
 
    if (newValue != -1 && origValue != newValue) {
        
        SMsgAVIoctrlSetMotionDetectReq *structSetMotionDetection = malloc(sizeof(SMsgAVIoctrlSetMotionDetectReq));
        memset(structSetMotionDetection, 0, sizeof(SMsgAVIoctrlSetMotionDetectReq));
        
        structSetMotionDetection->channel = 0;
        structSetMotionDetection->sensitivity = newValue;
        
        [camera sendIOCtrlToChannel:0 
                               Type:IOTYPE_USER_IPCAM_SETMOTIONDETECT_REQ 
                               Data:(char *)structSetMotionDetection 
                           DataSize:sizeof(SMsgAVIoctrlSetMotionDetectReq)];
        
        free(structSetMotionDetection);
        
        if (self.delegate) [self.delegate didSetMotionDetection:newValue];
    }
    
    [self.navigationController popViewControllerAnimated:YES];  
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
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
    
    labelItems = [[NSArray alloc] initWithObjects:NSLocalizedString(@"Off", @""), 
                  NSLocalizedString(@"Low", @""), 
                  NSLocalizedString(@"Medium", @""), 
                  NSLocalizedString(@"High", @""), 
                  NSLocalizedString(@"Max", @""), nil];
    
    self.navigationItem.title = NSLocalizedString(@"Motion Detection", @"");

    self.newValue = -1;    

    [super viewDidLoad];
}

- (void)viewDidUnload {
    
    self.delegate = nil;
    self.labelItems = nil;
    self.camera = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.camera.delegate2 = self;
    [super viewWillAppear:animated];
}

- (void)dealloc {
    
    self.delegate = nil;
    [labelItems release];
    [camera release];
    [super dealloc];
}

#pragma mark - TableView DataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? 5 : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger row = [indexPath row];
    
    static NSString *MotionDetectionTableIdentifier = @"MotionDetectionTableIdentifier";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:MotionDetectionTableIdentifier];
    
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MotionDetectionTableIdentifier]
                autorelease];
    }

    cell.accessoryType = UITableViewCellAccessoryNone;

    
    int val = -1;    
    
    if (newValue > 0) 
        val = newValue;
    else
        val = origValue;    
    
    
    if (val == 0 && row == 0)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else if (val > 0 && val <= 25 && row == 1)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else if (val > 25 && val <= 50 && row == 2)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else if (val > 50 && val <= 75 && row == 3)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else if (val == 100 && row == 4)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;    
    
    cell.textLabel.text = [labelItems objectAtIndex:row];         
        
    return cell;
}

#pragma mark - TableView Delegate Methods
- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    for (UITableViewCell *cell in [self.tableView visibleCells])
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    NSInteger row = [indexPath row];
    
    if (row == 0)
        newValue = 0;
    else if (row == 1) 
        newValue = 25;
    else if (row == 2)
        newValue = 50;
    else if (row == 3)
        newValue = 75;
    else if (row == 4)
        newValue = 100;
    
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - MyCameraDelegate Methods
- (void)camera:(MyCamera *)camera_ _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size {
    
    if (camera_ == camera && type == IOTYPE_USER_IPCAM_GETMOTIONDETECT_RESP) {
            
        SMsgAVIoctrlGetMotionDetectResp *s = (SMsgAVIoctrlGetMotionDetectResp*)data;
        self.origValue = s->sensitivity;            
        
        [self.tableView reloadData];
    } 
}

@end
