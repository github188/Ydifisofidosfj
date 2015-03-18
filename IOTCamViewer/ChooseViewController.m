//
//  ChooseViewController.m
//  IOTCamViewer
//
//  Created by Gavin Chang on 2013/12/10.
//  Copyright (c) 2013年 TUTK. All rights reserved.
//

#import "ChooseViewController.h"

@interface ChooseViewController ()

@end

@implementation ChooseViewController

@synthesize mTag;
@synthesize mSelIndex;
@synthesize marrItems;
@synthesize delegate;

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
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)init:(int)nTag delegate:(id<ChooseDelegate>)aDelegate selectedIndex:(int)nSel itemsArray:(NSArray*)arrItems
{
	self.mTag = nTag;
	self.delegate = aDelegate;
    
    switch (self.mTag) {
        case 695:
            if (nSel==0) {
                self.mSelIndex = 0;
            } else if (nSel>=1 && nSel<=35) {
                self.mSelIndex = 1;
            } else if (nSel>=36 && nSel<=65) {
                self.mSelIndex = 2;
            } else if (nSel>=66 && nSel<=95) {
                self.mSelIndex = 3;
            } else if (nSel>=96) {
                self.mSelIndex = 4;
            }
            break;
            
        case 1234:
            self.mSelIndex = nSel;
            detailItems = [[NSArray alloc] initWithObjects:
                                @"Midway Islands, Samoa",
                                @"Hawaii",
                                @"Alaska",
                                @"Pacific Time(USA & Canada)",
                                @"Mountain Time(USA & Canada)",
                                @"Central Time(USA & Canada)",
                                @"Eastern Time(USA & Canada)",
                                @"Atlantic Time(Canada)",
                                @"Brazilia, Buenos Aires",
                                @"Mid-Atlantic",
                                @"Azores, Cape Verde",
                                @"London, Iceland, Lisbon",
                                @"Paris, Rome, Berlin, Madrid",
                                @"Israel, Athens, Cairo, Jerusalem",
                                @"Moscow, Nairobi, Riyadh",
                                @"Baku, Tbilisi, Abu Dhabi, Mascot",
                                @"New Delhi, Islamabad, Karachi",
                                @"Dhakar, Alma Ata, Novosibirsk, Astana",
                                @"Bangkok, Hanoi, Jakarta",
                                @"Beijing, Singapore, Hongkong, Taipei",
                                @"Tokyo, Seoul, Yakutsk ",
                                @"Guam, Melbourne, Sydney",
                                @"Magadan, New Caledonia, Solomon Islands",
                                @"Wellington, Auckland, Fiji", nil];
            break;
        default:
            self.mSelIndex = nSel;
            break;
    }
	
	self.marrItems = arrItems;
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
    return [self.marrItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    static NSString *ChooseListCell = @"ChooseListCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ChooseListCell];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ChooseListCell] autorelease];
    }
	
	if( self.mSelIndex == row )
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;
	
	cell.textLabel.text = [marrItems objectAtIndex:row];
    
    cell.detailTextLabel.text = [detailItems objectAtIndex:row];
	
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark - TableView Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath section];
    NSInteger row = [indexPath row];
    
    if (section == 0) {
        if( row != self.mSelIndex ) {
            
            if (self.mTag==695) {
            
                switch (row) {
                    case 1:
                        [self.delegate didSelected:self.mTag selectedIndex:25 itemsArray:self.marrItems];
                        break;
                    case 2:
                        [self.delegate didSelected:self.mTag selectedIndex:50 itemsArray:self.marrItems];
                        break;
                    case 3:
                        [self.delegate didSelected:self.mTag selectedIndex:75 itemsArray:self.marrItems];
                        break;
                    case 4:
                        [self.delegate didSelected:self.mTag selectedIndex:100 itemsArray:self.marrItems];
                        break;
                    default:
                        [self.delegate didSelected:self.mTag selectedIndex:row itemsArray:self.marrItems];
                        break;
                }
            } else {
                [self.delegate didSelected:self.mTag selectedIndex:row itemsArray:self.marrItems];
            }
		}
		[self.navigationController popViewControllerAnimated:YES];
    }
}


@end
