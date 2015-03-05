//
//  AudioPickerContentController.m
//  IOTCamViewer
//
//  Created by tutk on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AudioPickerContentController.h"

@interface AudioPickerContentController ()

@end

@implementation AudioPickerContentController

@synthesize delegate;
@synthesize camera;
@synthesize supportedAudioModes;
@synthesize selectedMode;

- (void)dealloc {
    
    [camera release];
    [supportedAudioModes release];
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style delegate:(id<AudioPickerDelegate>)delegate_ {
    
    self = [self initWithStyle:style];
    if ( self ){
        self.delegate = delegate_;
    }
   
    return self ;
    
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        camera = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(150.0, 140.0);    
    self.supportedAudioModes = [[[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:AUDIO_MODE_OFF], nil] autorelease];
    
    if (camera != nil && [camera getAudioInSupportOfChannel:0])
        [self.supportedAudioModes addObject:[NSNumber numberWithInt:AUDIO_MODE_SPEAKER]];
    
    if (camera != nil && [camera getAudioOutFormatOfChannel:0])
        [self.supportedAudioModes addObject:[NSNumber numberWithInt:AUDIO_MODE_MICROPHONE]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    delegate = nil;
    camera = nil;
    supportedAudioModes = nil;    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [supportedAudioModes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {        
        cell = [[[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault 
                 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSInteger row = [indexPath row];

    NSNumber *numMode = [supportedAudioModes objectAtIndex:row];
    int mode = [numMode intValue];
    
    switch (mode) {
        case AUDIO_MODE_OFF:
        default:
            cell.textLabel.text = NSLocalizedString(@"Audio Off", @"");
            break;
        case AUDIO_MODE_SPEAKER:
            cell.textLabel.text = NSLocalizedString(@"Speaker On", @"");
            break;
        case AUDIO_MODE_MICROPHONE:
            cell.textLabel.text = NSLocalizedString(@"Microphone On", @"");
            break;
    }    
    
    cell.accessoryType = row == selectedMode ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;    
        
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *numMode = [self.supportedAudioModes objectAtIndex:[indexPath row]];
    [self.delegate didAudioModeSelected:(ENUM_AUDIO_MODE)[numMode intValue]];    
}

@end
