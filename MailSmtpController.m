//
//  MailSmtpController.m
//  IOTCamViewer
//
//  Created by tommy on 14-9-10.
//  Copyright (c) 2014年 TUTK. All rights reserved.
//

#import "MailSmtpController.h"

@interface MailSmtpController ()

@end

@implementation MailSmtpController
@synthesize camera;
@synthesize labelItems;
@synthesize newValue;
@synthesize origValue;
@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style delgate:(id<MailSmtpDelegate>)delegate_ {
    
    self = [super initWithStyle:style];
    
    if (self) {
        
        self.delegate = delegate_;
    }
    
    return self;
}
- (IBAction)back:(id)sender {
    
    if (newValue != -1 && origValue != newValue) {
        if (self.delegate) [self.delegate didSetMailSmtp:newValue];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
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
    
    NSString *path=[[NSBundle mainBundle] pathForResource:@"smtpServers" ofType:@"plist"];
    labelItems=[[NSArray alloc]initWithContentsOfFile:path];
    
    //labelItems = [[NSArray alloc] initWithObjects:@"smtp.gmail.com",
    //              "smtp.126.com","smtp.163.com","smtp.sina.com","smtp.sohu.com","smtp.yeah.com", nil];
    
    self.navigationItem.title = NSLocalizedString(@"Smtp Server", @"");
    
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [labelItems count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    
    static NSString *MailSmtpTableIdentifier = @"MailSmtpTableIdentifier";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:MailSmtpTableIdentifier];
    
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MailSmtpTableIdentifier]
                autorelease];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    
    int val = -1;
    
    if (newValue > 0)
        val = newValue;
    else
        val = origValue;
    
    /*
    if (val == 0 && row == 0)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else if (val > 1 && row == 1)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else if (val > 2 && row == 2)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else if (val > 3 && row == 3)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else if (val == 4 && row == 4)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    */
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
        newValue = 1;
    else if (row == 2)
        newValue = 2;
    else if (row == 3)
        newValue = 3;
    else if (row == 4)
        newValue = 4;
    
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - MyCameraDelegate Methods
- (void)camera:(MyCamera *)camera_ _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size {
  /*
    if (camera_ == camera && type == IOTYPE_USER_IPCAM_GETMOTIONDETECT_RESP) {
        
        SMsgAVIoctrlGetMotionDetectResp *s = (SMsgAVIoctrlGetMotionDetectResp*)data;
        self.origValue = s->sensitivity;
        
        [self.tableView reloadData];
    }*/
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
