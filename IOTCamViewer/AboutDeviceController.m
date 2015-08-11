//
//  AboutDeviceController.m
//  IOTCamViewer
//
//  Created by tutk on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <IOTCamera/AVIOCTRLDEFs.h>
#import "AboutDeviceController.h"

@implementation AboutDeviceController

@synthesize camera;
@synthesize labelItems;
@synthesize model;
@synthesize version;
@synthesize vender;
@synthesize totalSize;
@synthesize freeSize;

@synthesize modelIndicator;
@synthesize versionIndicator;
@synthesize venderIndicator;
@synthesize totalIndicator;
@synthesize freeIndicator;

- (IBAction)back:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    
    labelItems = [[NSArray alloc] initWithObjects:
                  NSLocalizedString(@"Model", @""), 
                  NSLocalizedString(@"Version", @""), 
                  NSLocalizedString(@"Vender", @""), 
                  NSLocalizedString(@"Total Size", @""), 
                  NSLocalizedString(@"Free Size", @""), nil];
    
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
    
    self.navigationItem.title = NSLocalizedString(@"About Device", @"");
    
    self.modelIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    self.versionIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    self.venderIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    self.totalIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    self.freeIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];

    [super viewDidLoad];
}

- (void)viewDidUnload {
    
    self.modelIndicator = nil;
    self.versionIndicator = nil;
    self.venderIndicator = nil;
    self.totalIndicator = nil;
    self.freeIndicator = nil;

    self.model = nil;
    self.version = -1;
    self.vender = nil;
    self.totalSize = -1;
    self.freeSize = -1;
    self.labelItems = nil;
    self.camera = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.model = nil;
    self.version = -1;
    self.vender = nil;
    self.totalSize = -1;
    self.freeSize = -1;
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

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    camera.delegate2 = nil;
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    
    [modelIndicator release];
    [versionIndicator release];
    [venderIndicator release];
    [totalIndicator release];
    [freeIndicator release];
    
    [model release];
    [vender release];
    [labelItems release];
    [camera release];
    [super dealloc];
}

#pragma mark - TableView DataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger i=0;
#if defined(RemoveVendor)
    i++;
#endif
#if defined(RemoveModel) || defined(EasynPTarget)
    i++;
#endif
    
    return (section == 0) ? [self.labelItems count]-i : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    NSUInteger row = [indexPath row];
    
    static NSString *AboutDeviceTableIdentifier = @"AboutDeviceTableIdentifier";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:AboutDeviceTableIdentifier];
    
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:AboutDeviceTableIdentifier]
                autorelease];
    }
    
    NSInteger index=row;
    /*labelItems = [[NSArray alloc] initWithObjects:
                  NSLocalizedString(@"Model", @""),
                  NSLocalizedString(@"Version", @""),
                  NSLocalizedString(@"Vender", @""),
                  NSLocalizedString(@"Total Size", @""),
                  NSLocalizedString(@"Free Size", @""), nil];*/
    
    
    if(row==0){
#if defined(EasynPTarget) || defined(RemoveModel)
        index=row+1;
        row++;
#endif
    }
    else if(row==1){
#if defined(RemoveVendor) && (defined(EasynPTarget) || defined(RemoveModel))
        index=row+2;
        row=index;
#endif
    }
    else if(row==2){
#if defined(RemoveVendor) && (defined(EasynPTarget) || defined(RemoveModel))
        index=row+2;
        row=index;
#endif
    }
    
    cell.textLabel.text = [labelItems objectAtIndex:index];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (row == 0) {
        
        if (model == nil || [model length] == 0) {
            [cell addSubview:modelIndicator];
            [modelIndicator startAnimating];            
            modelIndicator.center = CGPointMake(280, 22);
        }
        else {
            [modelIndicator stopAnimating];
            [modelIndicator removeFromSuperview];
        }            
        
        cell.detailTextLabel.text = model;        
    }
    else if (row == 1) {
        
        if (version <= 0) {
            [cell addSubview:versionIndicator];
            [versionIndicator startAnimating];            
            versionIndicator.center = CGPointMake(280, 22);
        }
        else {
            [versionIndicator stopAnimating];
            [versionIndicator removeFromSuperview];
                
            unsigned char v[4] = {0};
        
            v[3] = (char)version;
            v[2] = (char)(version >> 8);
            v[1] = (char)(version >> 16);
            v[0] = (char)(version >> 24);
        
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d.%d.%d.%d", v[0], v[1], v[2], v[3]];
        }
    }
    else if (row == 2) {
#if defined(EasynPTarget)
        vender=@"EasyN";
#else
        vender=@"Aztech";
#endif
#if defined(BayitCam)
           vender=@"EN";
#endif
#if defined(MAJESTICIPCAMP)
        vender=@"Majestic";
#endif
        
        if (vender == nil || [vender length] == 0) {
            [cell addSubview:venderIndicator];
            [venderIndicator startAnimating];            
            venderIndicator.center = CGPointMake(280, 22);
        }
        else {
            [venderIndicator stopAnimating];
            [venderIndicator removeFromSuperview];
        } 
    
        cell.detailTextLabel.text = vender;
        
    }
    else if (row == 3) {
        
        if (totalSize < 0) {
            [cell addSubview:totalIndicator];
            [totalIndicator startAnimating];            
            totalIndicator.center = CGPointMake(280, 22);
        }
        else {
            [totalIndicator stopAnimating];
            [totalIndicator removeFromSuperview];
        }  
        
        cell.detailTextLabel.text = (totalSize >= 0) ? [NSString stringWithFormat:@"%d MB", totalSize] : nil;
    }
    else if (row == 4) {
        
        if (freeSize < 0) {
            [cell addSubview:freeIndicator];
            [freeIndicator startAnimating];            
            freeIndicator.center = CGPointMake(280, 22);
        }
        else {
            [freeIndicator stopAnimating];
            [freeIndicator removeFromSuperview];
        } 
        
        cell.detailTextLabel.text = (freeSize >= 0) ? [NSString stringWithFormat:@"%d MB", freeSize] : nil; 
    }
    
    return cell;
}


#pragma mark - CameraDelegate Methods

- (void)camera:(MyCamera *)camera_ _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size {
    
    if (camera_ == camera && type == IOTYPE_USER_IPCAM_DEVINFO_RESP) {
        
        SMsgAVIoctrlDeviceInfoResp *structDevInfo = (SMsgAVIoctrlDeviceInfoResp*)data;
        self.model = [NSString stringWithUTF8String:(char *)structDevInfo->model];
        self.vender = [NSString stringWithUTF8String:(char *)structDevInfo->vendor];
        self.version = structDevInfo->version;
        self.totalSize = structDevInfo->total;
        self.freeSize = structDevInfo->free;        
        
        [self.tableView reloadData];
    }
}

@end
