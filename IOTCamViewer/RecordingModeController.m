//
//  RecordingModeController.m
//  IOTCamViewer
//
//  Created by tutk on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <IOTCamera/AVIOCTRLDEFs.h>
#import "RecordingModeController.h"

@implementation RecordingModeController

@synthesize camera;
@synthesize labelItems;
@synthesize origValue;
@synthesize newValue;
@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style delegate:(id<RecordingModeDelegate>)delegate_ {
    
    self = [super initWithStyle:style];
    
    if (self) {
        
        self.delegate = delegate_;
    }
    
return self;
}

- (IBAction)back:(id)sender {
    
    if (newValue != -1 && origValue != newValue) {
        
        SMsgAVIoctrlSetRecordReq *structSetRecord = malloc(sizeof(SMsgAVIoctrlSetRecordReq));
        memset(structSetRecord, 0, sizeof(SMsgAVIoctrlSetRecordReq));
        
        structSetRecord->channel = 0;
        structSetRecord->recordType = newValue;
        
        [camera sendIOCtrlToChannel:0 
                               Type:IOTYPE_USER_IPCAM_SETRECORD_REQ 
                               Data:(char *)structSetRecord 
                           DataSize:sizeof(SMsgAVIoctrlSetStreamCtrlReq)];
        
        free(structSetRecord);
        
        if (self.delegate) [self.delegate didSetRecordingMode:newValue];
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
                  NSLocalizedString(@"Full Time", @""), 
                  NSLocalizedString(@"Alarm", @""), nil];
    
    self.navigationItem.title = NSLocalizedString(@"Recording Mode", @"");
    
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
    return (section == 0) ? [self.labelItems count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    NSUInteger row = [indexPath row];
    
    static NSString *RecordingModeTableIdentifier = @"RecordingModeTableIdentifier";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:RecordingModeTableIdentifier];
    
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RecordingModeTableIdentifier]
                autorelease];
    }
    
    cell.textLabel.text = [labelItems objectAtIndex:row]; 
    cell.accessoryType = (row == self.origValue) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    
    return cell;
}

#pragma mark - TableView Delegate Methods
- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    for (UITableViewCell *cell in [self.tableView visibleCells])
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    self.newValue = [indexPath row];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - MyCameraDelegate Methods
- (void)camera:(MyCamera *)camera_ _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size {
    
    if (camera_ == camera && type == IOTYPE_USER_IPCAM_GETRECORD_RESP) {
            
        SMsgAVIoctrlGetRecordResp *s = (SMsgAVIoctrlGetRecordResp*)data;
        memcpy(s, data, size);
        self.origValue = s->recordType;            
        
        [self.tableView reloadData];
    }     
}
@end
