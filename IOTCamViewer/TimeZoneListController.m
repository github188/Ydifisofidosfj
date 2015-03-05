//
//  TimeZoneListController.m
//  IOTCamViewer
//
//  Created by Gavin Chang on 13/6/13.
//  Copyright (c) 2013年 TUTK. All rights reserved.
//

#import "TimeZoneListController.h"

@interface TimeZoneListController ()

@end

@implementation TimeZoneListController

@synthesize mTimeZoneArray;
@synthesize mTimeZoneChangedDelegate;

-(void)setCurrentTimeZone :(NSString*)szDesc tzGMTDiff_In_Mins:(int)nGMTDiff_In_Mins
{
	if( szDesc != nil )
		strcpy( mCurrentTimwZoneStore.szDesc, [szDesc UTF8String] );
	else
		memset( mCurrentTimwZoneStore.szDesc, 0, sizeof(mCurrentTimwZoneStore.szDesc) );
	mCurrentTimwZoneStore.nGMTDiff_In_Mins = nGMTDiff_In_Mins;
}

- (void)removeTimeZoneArray
{
	for( NSValue* currentRegionStoreValue in mTimeZoneArray ) {
		SREGIONSTORE currentRegionStore = {0};
		[currentRegionStoreValue getValue:&currentRegionStore];
		[currentRegionStore.regionArray removeAllObjects];
		[currentRegionStore.regionArray release];
		[currentRegionStore.strRegionString release];
	}
	[mTimeZoneArray removeAllObjects];
}

- (void)fillTimeArray
{
	[self removeTimeZoneArray];

	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray* tableArray = [NSArray arrayWithObjects:@"asia",@"europe",@"america",@"oceania",@"africa",nil];
	
	BOOL bBingo = FALSE;
	int nRegionIdx = 0;
	for (NSString* tableFileName in tableArray) {
		NSString *tableFilePath = [[NSBundle mainBundle] pathForResource:tableFileName ofType:@"csv"];
//		NSLog( @"---- load table: %@", tableFilePath );6
				
		if( [fileManager fileExistsAtPath:tableFilePath] ) {
			
			SREGIONSTORE regionStore;
			regionStore.regionArray = [[NSMutableArray alloc] init];
			regionStore.strRegionString = [NSLocalizedString(tableFileName, @"") copy];
			NSValue* regionStoreValue = [NSValue value:&regionStore withObjCType:@encode(SREGIONSTORE)];
			
			[mTimeZoneArray addObject:regionStoreValue];
			NSValue* currentRegionStoreValue = [mTimeZoneArray objectAtIndex:nRegionIdx++];
			SREGIONSTORE currentRegionStore = {0};
			[currentRegionStoreValue getValue:&currentRegionStore];
			
			// read everything from text
			NSString* fileContents = [NSString stringWithContentsOfFile:tableFilePath encoding:NSASCIIStringEncoding error:nil];
			
			// first, separate by new line
			NSArray* allLinedStrings = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
			
			int nLineIdx = 0;
			for( NSString* lineString in allLinedStrings ) {
				if( nLineIdx >= 1 ) {
					
					NSArray* singleStrs = [lineString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
					
					NSString* strTimeZoneString = [singleStrs objectAtIndex:1];
					NSString* strGMTDiffString = [[singleStrs objectAtIndex:2] substringFromIndex:4];
					NSArray* timeStrings = [strGMTDiffString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
					NSInteger nDiff_Hours = [[timeStrings objectAtIndex:0] integerValue];
					NSInteger nDiff_Minutes = [[timeStrings objectAtIndex:1] integerValue];
					
					STTIMEZONESTORE store;
					store.nGMTDiff_In_Mins = nDiff_Hours*60 + nDiff_Minutes;
					strcpy( store.szDesc, [strTimeZoneString UTF8String] );
					strcpy( store.szGMTDiff, [strGMTDiffString UTF8String] );
					NSValue* storeValue2 = [NSValue value:&store withObjCType:@encode(STTIMEZONESTORE)];
					[currentRegionStore.regionArray addObject:storeValue2];
					
//					NSLog( @"%@\t\t\t%@\t%d:%d", strTimeZoneString, strGMTDiffString, nDiff_Hours, nDiff_Minutes );
					
					if( !bBingo && NSOrderedSame == [strTimeZoneString compare:[NSString stringWithFormat:@"%s", mCurrentTimwZoneStore.szDesc] options:NSCaseInsensitiveSearch] ) {
						mInitSelectedRow = nLineIdx - 1;
						mInitSelectedSection = nRegionIdx - 1;
						bBingo = TRUE;
					}
				}
				nLineIdx++;
			}			
//			NSLog( @"----" );
		}
		
	}
	
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
		self.title = NSLocalizedString(@"Time Zones", @"");
		//self.tableView.rowHeight = ROW_HEIGHT;
    }
    return self;
}

- (IBAction)back:(id)sender
{
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
    
    [super viewDidLoad];

	mTimeZoneArray = [[NSMutableArray alloc] init];
	
	dispatch_async( dispatch_get_main_queue(), ^{
		
		mInitSelectedRow = -1;
		mInitSelectedSection = -1;
		
		[self fillTimeArray];
		[self.tableView reloadData];
		
		if( mInitSelectedRow != -1 && mInitSelectedSection != -1 ) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:mInitSelectedRow inSection:mInitSelectedSection];
			[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
		}
	});
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

- (void)dealloc {
    
    [self removeTimeZoneArray];
	[mTimeZoneArray release];
    [super dealloc];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	int sections = [mTimeZoneArray count];
	NSLog( @"sections:%d", sections );
	return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	SREGIONSTORE currentRegionStore = {0};
	NSValue* currentRegionStoreValue = [mTimeZoneArray objectAtIndex:section];
	[currentRegionStoreValue getValue:&currentRegionStore];
	int rows = [currentRegionStore.regionArray count];
	
	NSLog( @"section[%d] rows:%d", section, rows );
	return rows;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
	// Section title is the region name
	NSValue* currentRegionStoreValue = [mTimeZoneArray objectAtIndex:section];
	SREGIONSTORE currentRegionStore={0};
	[currentRegionStoreValue getValue:&currentRegionStore];
	
	return currentRegionStore.strRegionString;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;

	NSValue* currentRegionStoreValue = [mTimeZoneArray objectAtIndex:section];
	SREGIONSTORE currentRegionStore={0};
	[currentRegionStoreValue getValue:&currentRegionStore];
	NSValue* currentTimeZoneStoreValue = [currentRegionStore.regionArray objectAtIndex:row];
	STTIMEZONESTORE currentTimeZoneStore={0};
	[currentTimeZoneStoreValue getValue:&currentTimeZoneStore];
	
    cell.textLabel.text = [NSString stringWithFormat:@"%s", currentTimeZoneStore.szDesc];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"GMT %s", currentTimeZoneStore.szGMTDiff];
    
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
	NSInteger section = indexPath.section;
	NSInteger row = indexPath.row;
	
	NSValue* currentRegionStoreValue = [mTimeZoneArray objectAtIndex:section];
	SREGIONSTORE currentRegionStore={0};
	[currentRegionStoreValue getValue:&currentRegionStore];
	NSValue* currentTimeZoneStoreValue = [currentRegionStore.regionArray objectAtIndex:row];
	STTIMEZONESTORE currentTimeZoneStore={0};
	[currentTimeZoneStoreValue getValue:&currentTimeZoneStore];

	[mTimeZoneChangedDelegate onTimeZoneChanged:[NSString stringWithFormat:@"%s", currentTimeZoneStore.szDesc] tzGMTDiff_In_Mins:currentTimeZoneStore.nGMTDiff_In_Mins];
	
	[self.navigationController popViewControllerAnimated:YES];
}

@end
