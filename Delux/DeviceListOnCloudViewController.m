//
//  DeviceListOnCloudViewController.m
//  IOTCamViewer
//
//  Created by TUTK_MacMini2 on 14/4/22.
//  Copyright (c) 2014年 TUTK. All rights reserved.
//

#import "DeviceListOnCloudViewController.h"
#import "DeviceListOnCloud.h"
#import "StartViewController.h"
#import "AddCameraDetailController.h"

@interface DeviceListOnCloudViewController ()

@end

@implementation DeviceListOnCloudViewController

@synthesize syncCameraList;

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    
    if (isGoLogin) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        if ([userDefaults objectForKey:@"cloudUserPassword"]) {
        
            NSString *userID = [[NSString alloc] initWithString:[userDefaults objectForKey:@"cloudUserID"]];
            NSString *userPWD = [[NSString alloc] initWithString:[userDefaults objectForKey:@"cloudUserPassword"]];
            [dloc downloadDeviceListID:userID PWD:userPWD];
        }
    }
    
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Add Device", @"");
    
    cautionLabel.text = NSLocalizedString(@"No device available", @"");

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
    
    cameraListTable.backgroundColor = [UIColor clearColor];
    
    cameraListTable.editing = YES;
    
    dloc = [[DeviceListOnCloud alloc] init];
    dloc.delegate = self;
    
    downloadCameraList = [[NSMutableArray alloc] init];
    cameraListTable.delegate = self;
    cameraListTable.dataSource = self;
    
    if (!isGoLogin) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        if ([[userDefaults objectForKey:@"cloudUserPassword"] isEqualToString:@""]||[userDefaults objectForKey:@"cloudUserPassword"]==nil){
            
            StartViewController *controller = [[StartViewController alloc] initWithNibName:@"StartView" bundle:nil];
            controller->isFromDOC = YES;
            isGoLogin = YES;
            [self.navigationController pushViewController:controller animated:YES];
            
        } else {
            NSString *userID = [[NSString alloc] initWithString:[userDefaults objectForKey:@"cloudUserID"]];
            NSString *userPWD = [[NSString alloc] initWithString:[userDefaults objectForKey:@"cloudUserPassword"]];
            [dloc downloadDeviceListID:userID PWD:userPWD];
        }
    }
}

-   (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData{
    NSError *error;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:theData options:NSJSONWritingPrettyPrinted error:&error];
    NSMutableArray *tempArray = [dictionary valueForKey:@"record"];
    
    if (tempArray){
        for (NSDictionary *tempDic in tempArray){
            NSString* cameraUID = [tempDic valueForKey:@"dev_uid"];
            NSString* cameraName = [tempDic valueForKey:@"dev_name"];
            NSString* cameraPWD = [tempDic valueForKey:@"dev_passwd"];
            
            isSameUID = NO;
            
            for (MyCamera *tempCam in camera_list) {
                if ([tempCam.uid isEqualToString:cameraUID]){
                    isSameUID = YES;
                }
            }
            
            if (!isSameUID) {
                MyCamera *camera = [[MyCamera alloc] initWithName:cameraName viewAccount:@"admin" viewPassword:cameraPWD];
                [camera setUID:cameraUID];
                
                [downloadCameraList addObject:camera];
            }
        }
    }
    
    if ([downloadCameraList count]==0) {
        cautionView.hidden = NO;
    }
    
    [cameraListTable reloadData];
}

#pragma mark - Table Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [downloadCameraList count];
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CameraListCellIdentifier = @"CameraListCellIdentifier";
    
    UITableViewCell *cell = [cameraListTable dequeueReusableCellWithIdentifier:CameraListCellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CameraListCellIdentifier];
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    NSInteger row = [indexPath row];
    MyCamera *camera = [[MyCamera alloc] init];
    camera = [downloadCameraList objectAtIndex:row];
    
    if (![camera.name isKindOfClass:[NSNull class]]) {
        cell.textLabel.text = camera.name;
    } else {
        cell.textLabel.text = NSLocalizedString(@"Camera", @"");
    }
    
    if (![camera.uid isKindOfClass:[NSNull class]]) {
        cell.detailTextLabel.text = camera.uid;
        [cell.detailTextLabel setTextColor:[UIColor lightGrayColor]];
    } else {
        cell.detailTextLabel.text = NSLocalizedString(@"", @"");
    }
    
    return cell;
}

#pragma mark - TableView Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSInteger row = [indexPath row];
    MyCamera *camera = [downloadCameraList objectAtIndex:row];
    
    AddCameraDetailController *controller = [[AddCameraDetailController alloc] initWithNibName:@"AddCameraDetail" bundle:nil delegate:[[self.navigationController viewControllers] objectAtIndex:1]];
    controller->isFromDOC = YES;
    
    if (![camera.name isKindOfClass:[NSNull class]]) {
        controller.name = camera.name;
    }
    if (![camera.uid isKindOfClass:[NSNull class]]) {
        controller.uid = camera.uid;
    }
    
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];

}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}


@end
