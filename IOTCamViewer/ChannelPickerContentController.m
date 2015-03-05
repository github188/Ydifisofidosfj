//
//  ChannelPickerController.m
//  IOTCamViewer
//
//  Created by tutk on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <IOTCamera/Camera.h>
#import "ChannelPickerContentController.h"

@interface ChannelPickerContentController ()

@end

@implementation ChannelPickerContentController

@synthesize delegate;
@synthesize camera;
@synthesize selectedChannel;

- (id) initWithStyle:(UITableViewStyle)style delegate:(id<ChannelPickerDelegate>)delegate_ defaultContentSize:(CGSize*)psizeContent {
    
    self = [super initWithStyle:style];
    
    if (self) {
        self.delegate = delegate_;
		
		if( psizeContent == nil ) {
			self.contentSizeForViewInPopover = CGSizeMake(60.0, 135.0);
		}
		else {
			self.contentSizeForViewInPopover = *psizeContent;
		}
	}
    
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView  = nil;
    self.tableView.separatorColor = [UIColor whiteColor];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 5, 0, 5);
//    self.selectedChannel = 0;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.delegate = nil;    
    self.camera = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)dealloc {

    [camera release];
    [super dealloc];
}

#pragma mark - TableView DataSource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [camera.getSupportedStreams count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault 
                 reuseIdentifier:cellIdentifier] autorelease];
    }
    
    NSInteger row = [indexPath row];

    SubStream_t ch;
    NSValue *val = [[camera getSupportedStreams] objectAtIndex:row];
    
    if (strcmp([val objCType], @encode(SubStream_t)) == 0)
    {
        [val getValue:&ch];
        cell.textLabel.text = [NSString stringWithFormat:@"CH%d", ch.channel + 1];
    }
    else {
        cell.textLabel.text = [NSString stringWithFormat:@"CH0"];
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor colorWithRed:3.0/255.0 green:110.0/255.0 blue:184.0/255.0 alpha:0.8];
    //cell.accessoryType = row == selectedChannel ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - TableView Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SubStream_t ch;    
    NSValue *val = [[camera getSupportedStreams] objectAtIndex:[indexPath row]];
    
    if (strcmp([val objCType], @encode(SubStream_t)) == 0)
    {
        [val getValue:&ch];
    
        [self.delegate didChannelSelected:ch.channel];
    }
}

@end
