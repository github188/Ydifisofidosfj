//
//  LANSearchController.m
//  IOTCamViewer
//
//  Created by tutk on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <IOTCamera/IOTCAPIs.h>
#import <IOTCamera/Camera.h>
#import "LANSearchController.h"
#import "LANSearchDevice.h"
#import "AddCameraDetailController.h"
#import "MBProgressHUD.h"

@class LANSearchDevice;

@implementation LANSearchController

@synthesize tableView;
@synthesize delegate;

- (void)search {
    
    int num, k;    
    
    [searchResult removeAllObjects];
    
    
    LanSearch_t *pLanSearchAll = [Camera LanSearch:&num timeout:2000];
	printf("num[%d]\n", num);
    
	for(k = 0; k < num; k++) {
    
        
		printf("UID[%s]\n", pLanSearchAll[k].UID);
		printf("IP[%s]\n", pLanSearchAll[k].IP);
		printf("PORT[%d]\n", pLanSearchAll[k].port);
        
        LANSearchDevice *dev = [[LANSearchDevice alloc] init];
        dev.uid = [NSString stringWithFormat:@"%s", pLanSearchAll[k].UID];
        dev.ip = [NSString stringWithFormat:@"%s", pLanSearchAll[k].IP];
        dev.port = pLanSearchAll[k].port;
        
        [searchResult addObject:dev];
        
        [dev release];        
	}
    
	if(pLanSearchAll != NULL) {
		free(pLanSearchAll);
	}
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil delegate:(id<LANSearchDelegate>)delegate_ {

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
   
    if (self) {
        
        [self setDelegate:delegate_];
    }
    
    return self;
}

- (IBAction)cancel:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)mySearch{
    [self search];
    [self.tableView reloadData];
}

- (IBAction)refresh:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self performSelector:@selector(mySearch) withObject:nil afterDelay:0];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}
-(void)easynpToolBar{
    self.toolBar.hidden=YES;
    if(isEasyNPLoaded) return;
    //动态构建界面
    NSInteger tipsH=38;

    
    self.tableView.frame=CGRectMake(0, 10, self.view.frame.size.width, self.view.frame.size.height-tipsH-20);
    
    
    UIButton *refreshBtn=[[UIButton alloc]initWithFrame:CGRectMake(10, self.tableView.frame.origin.y+self.tableView.frame.size.height, 38, 38)];
    [refreshBtn setBackgroundImage:[UIImage imageNamed:@"refresh_27_07.png"] forState:UIControlStateNormal];
    [refreshBtn setBackgroundImage:[UIImage imageNamed:@"refresh_27_07_1.png"] forState:UIControlStateHighlighted];
    [refreshBtn setBackgroundImage:[UIImage imageNamed:@"refresh_27_07_1.png"] forState:UIControlStateSelected];
    refreshBtn.adjustsImageWhenHighlighted=YES;
    
    refreshBtn.contentMode=UIViewContentModeScaleToFill;
    [refreshBtn addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:refreshBtn];
    
    UILabel *refreshLbl=[[UILabel alloc]initWithFrame:CGRectMake(58, self.tableView.frame.origin.y+self.tableView.frame.size.height, self.view.frame.size.width-68, tipsH)];
    refreshLbl.text=NSLocalizedString(@"LanSearchTips2","");
    refreshLbl.textAlignment=NSTextAlignmentLeft;
    refreshLbl.lineBreakMode=NSLineBreakByWordWrapping;
    refreshLbl.numberOfLines=0;
    refreshLbl.font=[UIFont systemFontOfSize:14.0f];
    [self.view addSubview:refreshLbl];
    [refreshLbl release];
    [refreshBtn release];
    
    isEasyNPLoaded=YES;
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    
    self.navigationItem.title = NSLocalizedString(@"LAN Search","");
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                     initWithTitle:NSLocalizedString(@"Cancel","")
                                     style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(cancel:)];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];    
    
    
    searchResult = [[NSMutableArray alloc] init];
    
    

    
    
    [super viewDidLoad];
}

- (void)viewDidUnload {

    searchResult = nil;
    tableView = nil;
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    
#if defined(EasynPTarget) || defined(BayitCam)
    [self easynpToolBar];
#endif
    
    [self refresh:nil];
    [super viewWillAppear:animated];
}

- (void)dealloc {
    
    [tableView release];
    [searchResult release];
    self.delegate=nil;
    [_toolBar release];
    [super dealloc];
}

#pragma mark - Table DataSource Methods
- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section {
    NSInteger cnt=[searchResult count];
#if defined(EasynPTarget) || defined(BayitCam)
    return cnt+1;
#else
    return cnt;
#endif
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CameraListCell = @"CameraListCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CameraListCell];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CameraListCell] autorelease];        
    }
    
    // Configure the cell
    NSUInteger row = [indexPath row];
#if defined(EasynPTarget) || defined(BayitCam)
    if(row>0){
        LANSearchDevice *dev = [searchResult objectAtIndex:row-1];
        
        cell.textLabel.text = dev.uid;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.text = dev.ip;
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.imageView.image = nil;
        cell.backgroundColor = [UIColor clearColor];
        cell.opaque = NO;
    }
    else{
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        for (UIView *v in [cell.contentView subviews]) {
            [v removeFromSuperview];
        }
        
        UIButton *tipsBtn=[[UIButton alloc]initWithFrame:CGRectMake(10, 3, 38, 38)];
        [tipsBtn setImage:[UIImage imageNamed:@"info_27_03.png"] forState:UIControlStateNormal];
        tipsBtn.contentMode=UIViewContentModeScaleToFill;
        [cell.contentView addSubview:tipsBtn];
        
        UILabel *tipsLbl=[[UILabel alloc]initWithFrame:CGRectMake(58, 3, cell.contentView.frame.size.width-58, 38)];
        tipsLbl.text=NSLocalizedString(@"LanSearchTips1","");
        tipsLbl.font=[UIFont systemFontOfSize:14.0f];
        tipsLbl.lineBreakMode=NSLineBreakByWordWrapping;
        tipsLbl.numberOfLines=0;
        tipsLbl.textAlignment=NSTextAlignmentLeft;
        [cell.contentView addSubview:tipsLbl];
        [tipsLbl release];
        [tipsBtn release];
    }
#else
    LANSearchDevice *dev = [searchResult objectAtIndex:row];
    
    cell.textLabel.text = dev.uid;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.text = dev.ip;
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.imageView.image = nil;
    cell.backgroundColor = [UIColor clearColor];
    cell.opaque = NO;
#endif
    
    
    UIImageView *bg =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bkg_articalList.png"]];
    cell.backgroundView = bg ;
    [bg release];
    
    return cell;
}

#pragma mark - Table View Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger row = [indexPath row];
    NSInteger index=row;
#if defined(EasynPTarget) || defined(BayitCam)
    index=row-1;
    if(row==0)
    {
        return;
    }
#endif

    LANSearchDevice *dev = [searchResult objectAtIndex:index];
    if(self.isFromAutoWifi){
        AddCameraDetailController *controller = [[AddCameraDetailController alloc] initWithNibName:@"AddCameraDetail" bundle:nil delegate:[[self.navigationController viewControllers] objectAtIndex:0]];
        controller.uid=dev.uid;
        //controller.isFromAutoWifi=self.isFromAutoWifi;
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
        [self.delegate didSelectUID:dev.uid];
    }
}

@end
