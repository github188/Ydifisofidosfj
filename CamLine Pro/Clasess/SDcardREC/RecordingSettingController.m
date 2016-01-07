//
//  RecordingSettingController.m
//  temptest
//
//  Created by apple  on 16/1/5.
//  Copyright © 2016年 jayzhou. All rights reserved.
//

#import <IOTCamera/AVIOCTRLDEFs.h>
#import "RecordingSettingController.h"
#import "DetailRECSettingController.h"
#import "iToast.h"
#import "MBProgressHUD+MJ.h"
@interface RecordingSettingController ()<UIActionSheetDelegate,MyCameraDelegate>

@property (nonatomic , retain) NSArray * itmes;

@property (nonatomic ,assign) NSInteger totalSize;
@property (nonatomic ,assign) NSInteger freeSize;
@end

@implementation RecordingSettingController
@synthesize camera;
//lazy loading
- (NSArray *)itmes
{
    if (!_itmes) {
        _itmes = [[NSArray alloc] initWithObjects:
                                 NSLocalizedString(@"Open/Close", @""),
                                 NSLocalizedString(@"Total Size", @""),
                                 NSLocalizedString(@"Free Size", @""),
                                 NSLocalizedString(@"Format SDCard", @""),
                                 nil];
    }
    return _itmes;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
    [self initData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    
  
    self.totalSize = 0;
    self.freeSize = 0;
    camera.delegate2 = self;
    
    SMsgAVIoctrlDeviceInfoReq *s = malloc(sizeof(SMsgAVIoctrlDeviceInfoReq));
    memset(s, 0, sizeof(SMsgAVIoctrlDeviceInfoReq));
    
    [camera sendIOCtrlToChannel:0
                           Type:IOTYPE_USER_IPCAM_DEVINFO_REQ
                           Data:(char *)s
                       DataSize:sizeof(SMsgAVIoctrlDeviceInfoReq)];
    free(s);
    
    [super viewWillAppear:animated];
}

- (void)setUI
{

}
- (void)initData
{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1 ;
            break;
        case 1:
            return 2 ;
            break;
        case 2:
            return 1 ;
            break;
        default:
            return 0;
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    tableView.tableFooterView = [[UIView alloc] init];
    NSUInteger row = [indexPath row];
    NSInteger section = [indexPath section];
    
    static NSString *TableIdentifier = @"TableIdentifier";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:TableIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TableIdentifier]
                autorelease];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (section == 1) {
        NSString * dTitle = [NSString stringWithFormat:@"%ldM",(long)(row == 0 ? self.totalSize : self.freeSize)];
        cell.detailTextLabel.text =dTitle;
       // return cell;
    }else if (section == 0 && row == 0){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    if (section == 2) {
        cell.textLabel.text = self.itmes[3];
        
    }else{
        cell.textLabel.text = [self.itmes objectAtIndex:row + section];}
    
    return cell;
}

#pragma mark - tableview delegate M
//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSInteger section = [indexPath section];
//    if (section == 1){
//        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//        cell.accessoryType = UITableViewCellAccessoryNone;
//        
//    }
//
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    NSUInteger row = [indexPath row];
    NSInteger section = [indexPath section];
    if (section == 0 && row == 0)
        {
           DetailRECSettingController *detailVC = [[DetailRECSettingController alloc] initWithStyle:UITableViewStyleGrouped];
            detailVC.navigationItem.title = [NSString stringWithFormat:NSLocalizedString(@"SDCard REC", @"")];
            detailVC.camera =self.camera;
            [self.navigationController pushViewController:detailVC animated:YES];
        }else if (section == 2 && row == 0)
                        {
            //formot sdcard
                            [self setUpFormatSheet];
                        }

  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Sheet Delegate M
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        
        if (camera != nil) {
            [MBProgressHUD showMessage:@"正在格式化,请耐心等待..."];
            double delayInSeconds = 0.55;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                SMsgAVIoctrlFormatExtStorageReq *s = malloc(sizeof(SMsgAVIoctrlFormatExtStorageReq));
                memset(s, 0, sizeof(SMsgAVIoctrlFormatExtStorageReq));
                s->storage = 0;
                
                [camera sendIOCtrlToChannel:0
                                       Type:IOTYPE_USER_IPCAM_FORMATEXTSTORAGE_REQ
                                       Data:(char *)s
                                   DataSize:sizeof(SMsgAVIoctrlFormatExtStorageReq)];
                free(s);
            });
        }
    }
}

#pragma mark - Other
- (void)setUpFormatSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:NSLocalizedString(@"Format command will ERASE all data of your SDCard", @"")
                                  delegate:self
                                  cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                  destructiveButtonTitle:NSLocalizedString(@"Format", @"")
                                  otherButtonTitles:nil];
    [actionSheet showInView:self.view];
    [actionSheet release];

}

#pragma mark - Camera delegate
- (void)camera:(MyCamera *)camera_ _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size {
    
    if (camera_ == camera && type == IOTYPE_USER_IPCAM_DEVINFO_RESP) {
        
        SMsgAVIoctrlDeviceInfoResp *structDevInfo = (SMsgAVIoctrlDeviceInfoResp*)data;
        
       
        self.totalSize = structDevInfo->total;
        self.freeSize = structDevInfo->free;
        
        [self.tableView reloadData];
    }else if (camera_ == camera && type == IOTYPE_USER_IPCAM_FORMATEXTSTORAGE_RESP) {
        
        SMsgAVIoctrlFormatExtStorageResp *s = (SMsgAVIoctrlFormatExtStorageResp *)data;
        
        if (s->result == 0)
            {
                [MBProgressHUD hideHUD];
                [[iToast makeText:NSLocalizedString(@"Format completed.", @"")] show];
                
            } else
                {
                    [MBProgressHUD hideHUD];
                    [[iToast makeText:NSLocalizedString(@"Format failed.", @"")] show];
                }
    }

}
- (void) dealloc
{
    [super dealloc];
    [self.itmes release];
}
@end
