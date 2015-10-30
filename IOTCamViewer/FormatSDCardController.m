//
//  FormatSDCardController.m
//  p2pcam264
//
//  Created by tutk on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <IOTCamera/AVIOCTRLDEFs.h>
#import "FormatSDCardController.h"
#import "iToast.h"

@interface FormatSDCardController ()

@end

@implementation FormatSDCardController

@synthesize camera;

- (IBAction)back:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    
    [camera release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.navigationItem.title = NSLocalizedString(@"Format SDCard", @"");
}

- (void)viewDidUnload
{
    self.camera = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.camera.delegate2 = self;
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil)         
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    
    cell.textLabel.text = NSLocalizedString(@"Format SDCard", @"");
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;    
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return NSLocalizedString(@"Format command will ERASE all data of your SDCard", @"");
}
#if defined(MAJESTICIPCAMP)
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UILabel *titleLbl=[[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)]autorelease];
    titleLbl.text=NSLocalizedString(@"Format command will ERASE all data of your SDCard", @"");
    titleLbl.lineBreakMode=NSLineBreakByWordWrapping;
    titleLbl.numberOfLines=0;
    titleLbl.font=[UIFont fontWithName:@"Courier" size:14];
    return titleLbl;
}
#endif
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
    NSInteger row = [indexPath row];

    if (row == 0) {
    
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:NSLocalizedString(@"Format SDCard", @"")
                                      delegate:self
                                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                      destructiveButtonTitle:NSLocalizedString(@"Continue", @"")
                                      otherButtonTitles:nil];
        [actionSheet showInView:self.view];
        [actionSheet release];
    }
}

#pragma  mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        
        if (camera != nil) {
            
            SMsgAVIoctrlFormatExtStorageReq *s = malloc(sizeof(SMsgAVIoctrlFormatExtStorageReq));
            memset(s, 0, sizeof(SMsgAVIoctrlFormatExtStorageReq));
            s->storage = 0;
            
            [camera sendIOCtrlToChannel:0 
                                   Type:IOTYPE_USER_IPCAM_FORMATEXTSTORAGE_REQ 
                                   Data:(char *)s 
                               DataSize:sizeof(SMsgAVIoctrlFormatExtStorageReq)];
            free(s);
        }
    }
}

#pragma mark - MyCameraDelegate Methods
- (void)camera:(MyCamera *)camera_ _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size {
    
    if (camera_ == camera && type == IOTYPE_USER_IPCAM_FORMATEXTSTORAGE_RESP) {
            
        SMsgAVIoctrlFormatExtStorageResp *s = (SMsgAVIoctrlFormatExtStorageResp *)data;
        
        if (s->result == 0)
            [[iToast makeText:NSLocalizedString(@"Format completed.", @"")] show];
        else
            [[iToast makeText:NSLocalizedString(@"Format failed.", @"")] show];
    }
}

@end
