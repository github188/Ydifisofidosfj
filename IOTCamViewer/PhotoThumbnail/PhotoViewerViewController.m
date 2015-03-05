//
//  PhotoViewerViewController.m
//  MyAlbum
//
//  Created by ZINWELL on 2012/1/13.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoViewerViewController.h"
#import <QuartzCore/QuartzCore.h>


#define SHARE_ACTION_SHEET_TAG  1
#define DELETE_ACTION_SHEET_TAG 2
@interface PhotoViewerViewController()

@property (nonatomic, retain)IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain)NSMutableArray *photoArray;
@property (nonatomic)NSInteger currentPage;
@property (nonatomic, retain)NSTimer *hideNavigationBarTimer;
@property (nonatomic, retain)UIImageView *mainImageView;
@end

@implementation PhotoViewerViewController
@synthesize mainImageView;
@synthesize albumPath,photoFileName;
@synthesize scrollView;
@synthesize photoArray;
@synthesize currentPage;
@synthesize hideNavigationBarTimer;
@synthesize camera;

- (void)filterImage:(int)channel {
    cameraChannel = channel;
}

- (NSMutableArray *) photoArray {
	if (!photoArray) {
        
        photoArray = [[NSMutableArray alloc] init];
        FMResultSet *rs = [database executeQuery:@"SELECT * FROM snapshot WHERE dev_uid=?", camera.uid];
        
        while([rs next]) {
            
            NSString *filePath = [rs stringForColumn:@"file_path"];            
            NSLog(@"%@", filePath);
            
            if ([filePath rangeOfString:[NSString stringWithFormat:@"CH%d",cameraChannel]].location != NSNotFound) {
                [photoArray addObject:[NSString stringWithFormat:@"%@", filePath]];
            }
        }
        [rs close];

        /*
        NSFileManager *fileManager = [NSFileManager defaultManager];
		if ([fileManager fileExistsAtPath:self.albumPath] == YES) {
			NSMutableArray *photoFileNameArray = nil;
            for (NSString *fileName in [fileManager contentsOfDirectoryAtPath:self.albumPath error:nil]) {
                if (fileName.length <= 18) {
                    if (!photoFileNameArray) {
                        photoFileNameArray = [[[NSMutableArray alloc] init] autorelease];
                    }
                    [photoFileNameArray addObject:fileName];
                }
            }
            photoArray = [[NSMutableArray alloc] initWithArray:photoFileNameArray];
        }
        */
	}
	return photoArray;
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

- (void)adjustTabBarWithOrientation:(UIInterfaceOrientation)orientation hide:(BOOL)yesOrNo
{
    UIView *transView = [self.tabBarController.view.subviews objectAtIndex:0];
    UIView *tabBar = [self.tabBarController.view.subviews objectAtIndex:1];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    // tabBar.hidden = yesOrNo;
    if (tabBar.hidden == YES) {
        if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
            if (screenBounds.size.height == 568) {
                transView.frame = CGRectMake(0, 0, 568, 320);
            } else if(screenBounds.size.height == 480) {
                transView.frame = CGRectMake(0, 0, 480, 320);
            }
        }
        else {
            if (screenBounds.size.height == 568) {
                transView.frame = CGRectMake(0, 0, 320, 568);
            } else if(screenBounds.size.height == 480) {
                transView.frame = CGRectMake(0, 0, 320, 480);
            }
        }
    }else {
        if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
            if (screenBounds.size.height == 568) {
                transView.frame = CGRectMake(0, 0, 568, 320-49+49);
            } else if(screenBounds.size.height == 480) {
                transView.frame = CGRectMake(0, 0, 480, 320-49+49);
            }
        }
        else {
            if (screenBounds.size.height == 568) {
                transView.frame = CGRectMake(0, 0, 320, 568-49+49);
            } else if(screenBounds.size.height == 480) {
                transView.frame = CGRectMake(0, 0, 320, 480-49+49);
            }
        }
    }
}
#define HIDE_NAVIGATION_BAR_TIME_OUT	5

- (void)hideNavigationBarAndToolBar {
	if (NO == self.navigationController.navigationBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
		[self.navigationController setNavigationBarHidden:YES animated:YES];
        [self adjustTabBarWithOrientation:[UIApplication sharedApplication].statusBarOrientation hide:YES];
	}
}

- (NSTimer *)setupHideNavigationBarTimer {
	return [NSTimer scheduledTimerWithTimeInterval:HIDE_NAVIGATION_BAR_TIME_OUT target:self selector:@selector(hideNavigationBarAndToolBar) userInfo:nil repeats:NO];
}

#define NAVIGATION_BAR_HEIGHT_PORTRAIT	44
#define NAVIGATION_BAR_HEIGHT_LANDSCAPE	32
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)aScrollView {
    if (aScrollView.tag == 1) {
        return self.mainImageView;
    }
    return nil;

}

- (void)viewPhotoWithFileName:(NSString *)filename
{
	self.photoFileName = filename;

	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	CGRect imageRect = CGRectZero;
	NSInteger mainIndex = [self.photoArray indexOfObject:self.photoFileName];
	NSNumber *index = nil;

	//self.title = nil;
	CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && UIInterfaceOrientationIsLandscape(orientation) ) {
		CGFloat fTmp = screenBounds.size.height;
		screenBounds.size.height = screenBounds.size.width;
		screenBounds.size.width = fTmp;
	}
    
    NSString *iOSVersion = [[UIDevice currentDevice] systemVersion];
    NSComparisonResult orderResult = [iOSVersion compare:@"7.0" options:NSNumericSearch];
    
    CGFloat offset = (orderResult == NSOrderedAscending) ? 20.0f : 0.0f;
    
	if (UIInterfaceOrientationIsLandscape(orientation)) {
        imageRect = CGRectMake(0, 0, CGRectGetHeight(screenBounds), CGRectGetWidth(screenBounds) - offset);
	}else {
        imageRect = CGRectMake(0, 0, CGRectGetWidth(screenBounds), CGRectGetHeight(screenBounds) - offset);
	}
	
	if (mainIndex<0) {
		return;
	}
    
	if (self.photoArray.count<=0) {
		self.scrollView.contentSize = CGSizeMake(imageRect.origin.x+imageRect.size.width, imageRect.size.height - 44 /* -49 *49 is the height of tab bar*/);
		UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(imageRect.origin.x, imageRect.origin.y, imageRect.size.width, imageRect.size.height)];
		imgView.image = [UIImage imageNamed:@"NoPhotoAvailable.png"];
		//imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.scrollView addSubview:imgView];
		[imgView release];
		//imageRect.origin.x += imageRect.size.width;
		return;
	}
	
	//self.title = [NSString stringWithFormat:@"%3d/%3d",mainIndex+1,self.photoArray.count];
	
	NSMutableArray *indexArray = [[NSMutableArray alloc] init];
	
	for (NSInteger i=0; i<3; i++) {
		if (1==i) {
			index = [NSNumber numberWithInt:mainIndex];
		}else if (self.photoArray.count>1)
		{
			index = [NSNumber numberWithInt:(mainIndex + self.photoArray.count + i-1)%self.photoArray.count];
		}else {
			index = [NSNumber numberWithInt:-1];
		}
		
		[indexArray addObject:index];
	}
	
	for (UIView *subview in [self.scrollView subviews]) {
		[subview removeFromSuperview];
	}
	
    int page=0;
    
	for (index in indexArray) {
		if ([index intValue]<0) {
			continue;
		}
        
        CGRect scrollRect = CGRectMake(imageRect.size.width * page, imageRect.origin.y, imageRect.size.width, imageRect.size.height);
        
        UIScrollView *subScrollView = [[[UIScrollView alloc] initWithFrame:scrollRect] autorelease];
        
        subScrollView.backgroundColor = [UIColor clearColor];//[[UIColor whiteColor] colorWithAlphaComponent:0.5f];
        
        /*
        if ([index intValue]==mainIndex) {
            subScrollView.backgroundColor = [UIColor blackColor];
        }else {
            subScrollView.backgroundColor = [UIColor blackColor];
        }
         */
        
        CGRect imageViewRect = CGRectMake(imageRect.origin.x + 10, imageRect.origin.y, imageRect.size.width - 10*2, imageRect.size.height);
        
        UIImageView *imgView = [[[UIImageView alloc] initWithFrame:imageViewRect] autorelease];
		
		imgView.image = [UIImage imageWithContentsOfFile:[self.albumPath stringByAppendingPathComponent:[self.photoArray objectAtIndex:[index intValue]]]];
        //imgView.layer.borderColor = [UIColor blackColor].CGColor;
        //imgView.layer.borderWidth = 1.0;
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        
        if ([index intValue]==mainIndex) {
            self.mainImageView = imgView;
            subScrollView.tag = 1;
            subScrollView.contentSize = imageRect.size;
            subScrollView.maximumZoomScale = 4.0;
            subScrollView.minimumZoomScale = 1.0;
            subScrollView.clipsToBounds = YES;
            subScrollView.scrollEnabled = YES;
            subScrollView.showsVerticalScrollIndicator = NO;
            subScrollView.showsHorizontalScrollIndicator = NO;
            //subScrollView.indicatorStyle = UIScrollViewIndicatorStyleDefault;
//            subScrollView.delegate = self;
        }
        
        
        [subScrollView addSubview:imgView];
        
        [self.scrollView addSubview:subScrollView];
        page++;
	}
    
	self.scrollView.contentSize = CGSizeMake(imageRect.size.width * page, imageRect.size.height - 44/* - 49*/);
	[indexArray release];
	
	self.scrollView.delegate = self;
	self.scrollView.pagingEnabled = YES;
    self.currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
    
	if( page < 3 ) {
		CGRect visibleRect = CGRectMake(0, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, CGRectGetHeight(screenBounds));
		
		NSLog(@"visibleRect: %@", NSStringFromCGRect(visibleRect));
		
		[self.scrollView setContentOffset:visibleRect.origin animated:NO];
	}
	else {
		CGRect visibleRect = CGRectMake(imageRect.size.width, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, CGRectGetHeight(screenBounds));
		
		NSLog(@"visibleRect: %@", NSStringFromCGRect(visibleRect));
		
		[self.scrollView setContentOffset:visibleRect.origin animated:NO];
	}
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self handleSingleTap:nil];
	});
}

- (void)viewNextPhoto {
	//NSLog(@"viewNextPhoto");
	[self.hideNavigationBarTimer invalidate];
	self.hideNavigationBarTimer = nil;
	
	if (self.photoArray.count>1) {
		NSInteger index = [self.photoArray indexOfObject:self.photoFileName];
	
		NSString *nextFileName = [self.photoArray objectAtIndex:(index+1)%self.photoArray.count];
		if ([nextFileName isEqualToString:self.photoFileName]) {
			nextFileName = nil;
		}
		[self viewPhotoWithFileName:nextFileName];
	}
	
	//self.hideNavigationBarTimer = [self setupHideNavigationBarTimer];
}

- (void)viewPreviousPhoto {
	//NSLog(@"viewPreviousPhoto");
	[self.hideNavigationBarTimer invalidate];
	self.hideNavigationBarTimer = nil;
	
	if (self.photoArray.count>1) {
		NSInteger index = [self.photoArray indexOfObject:self.photoFileName];
		
		NSString *nextFileName = [self.photoArray objectAtIndex:(index+self.photoArray.count-1)%self.photoArray.count];
		if ([nextFileName isEqualToString:self.photoFileName]) {
			nextFileName = nil;
		}
		[self viewPhotoWithFileName:nextFileName];	
	}
	
	//self.hideNavigationBarTimer = [self setupHideNavigationBarTimer];
}
// MFMailComposeViewControllerDelegate Begin
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	switch (result)
	{
		case MFMailComposeResultCancelled:
			NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued");
			break;
		case MFMailComposeResultSaved:
			NSLog(@"Mail saved: you saved the email message in the Drafts folder");
			break;
		case MFMailComposeResultSent:
			NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send the next time the user connects to email");
			break;
		case MFMailComposeResultFailed:
			NSLog(@"Mail failed: the email message was nog saved or queued, possibly due to an error");
			break;
		default:
			NSLog(@"Mail not sent");
			break;
	}
    
	[self dismissModalViewControllerAnimated:YES];
}
// MFMailComposeViewControllerDelegate End

- (void)emailPhoto {
	if ([MFMailComposeViewController canSendMail]) {
		NSString *extension = [[[self.photoFileName componentsSeparatedByString:@"."] lastObject] lowercaseString];
		MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
		mailer.mailComposeDelegate = self;
		NSData *attachmentData = nil;
		[mailer setSubject:[NSString stringWithFormat:@"Photo - %@",self.photoFileName]];
		if ([extension isEqualToString:@"png"]) {
			attachmentData = UIImagePNGRepresentation([UIImage imageWithContentsOfFile:[self.albumPath stringByAppendingPathComponent:self.photoFileName]]);
		}else {
			attachmentData = UIImageJPEGRepresentation([UIImage imageWithContentsOfFile:[self.albumPath stringByAppendingPathComponent:self.photoFileName]], 1.0);
		}
		
		[mailer addAttachmentData:attachmentData mimeType:[NSString stringWithFormat:@"image/%@",extension] fileName:self.photoFileName];
		[mailer setMessageBody:[NSString stringWithString:[NSString stringWithFormat:@"Photo - %@",self.photoFileName]] isHTML:NO];
		[self presentModalViewController:mailer animated:YES];
		[mailer release];
	}else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Your email account is disabled or removed, please check your email account.",nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
		alert.tag = 1;
		alert.delegate = self;
		[alert show];
		[alert release];
	}
	
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error 
  contextInfo:(void *)contextInfo
{
    // Was there an error?
    if (error != NULL)
    {
        // Show error message...
        //NSLog(@"SAVE FAILED");
        /*
         UIAlertView * resultAlert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed to save photo to camera roll.", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil] autorelease];
         resultAlert.tag = 1;
         [resultAlert show];
         */
    }
    else  // No errors
    {
        // Show message image successfully saved
        //NSLog(@"SAVE SUCCEEDED");
        /*
         UIAlertView * resultAlert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Succeeded to save photo to camera roll.", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil] autorelease];
         resultAlert.tag = 1;
         [resultAlert show];
         */
        
    }
}

- (NSString *) pathForDocumentsResource:(NSString *) relativePath {
    
    static NSString* documentsPath = nil;
    
    if (nil == documentsPath) {
        
        NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsPath = [[dirs objectAtIndex:0] retain];
    }
    
    return [documentsPath stringByAppendingPathComponent:relativePath];
}

- (void)deleteSnapshotRecords:(NSString *)fileName {
    
    if (database != NULL) {
        
        FMResultSet *rs = [database executeQuery:@"SELECT * FROM snapshot WHERE file_path=?", fileName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        while([rs next]) {
            
            NSString *filePath = [rs stringForColumn:@"file_path"];
            [fileManager removeItemAtPath:[self pathForDocumentsResource: filePath] error:NULL];
            NSLog(@"camera(%@) snapshot removed", filePath);
        }
        
        [rs close];
        
        [database executeUpdate:@"DELETE FROM snapshot WHERE file_path=?", fileName];
    }
}

- (void)savePhotoToCameraRoll {
    NSString * filePath = [self.albumPath stringByAppendingPathComponent:self.photoFileName];
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    UIImageWriteToSavedPhotosAlbum(image, self, 
                                   @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)deletePhoto {

    NSInteger index = [self.photoArray indexOfObject:self.photoFileName];
    
    NSString *nextFileName = [self.photoArray objectAtIndex:(index+1)%self.photoArray.count];
    
    if ([nextFileName isEqualToString:self.photoFileName]) {
        nextFileName = nil;
    }
    
    [self deleteSnapshotRecords:self.photoFileName];
    [self.photoArray removeObjectAtIndex:index];
    
    // [[NSFileManager defaultManager] removeItemAtPath:[self.albumPath stringByAppendingPathComponent:self.photoFileName] error:NULL];
    
    if ([self.photoArray count] > 0)
        [self viewPhotoWithFileName:nextFileName];
    else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:
			if (alertView.tag == 0) {
				// delete this photo
				[self deletePhoto];
			}
			break;
		default:
			break;
	}
}
- (void) showDeleteAlert {
	UIAlertView *alert = nil;
	if (self.photoArray.count<=0) {
		alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Photo Available",nil) message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK",nil),nil];
		alert.tag = 1;
	}else {
		alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete?",nil) message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK",nil),NSLocalizedString(@"Cancel",nil),nil];
		alert.tag = 0;
	}

	
	alert.delegate = self;
	[alert show];
	[alert release];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (SHARE_ACTION_SHEET_TAG == actionSheet.tag) {
        switch (buttonIndex) {
            case 0:
                [self showDeleteAlert];
                break;
            case 1:
                [self emailPhoto];
                break;
            case 2:
                [self savePhotoToCameraRoll];
                break;
            default:
                break;
        }

    }else if (DELETE_ACTION_SHEET_TAG == actionSheet.tag) {
        switch (buttonIndex) {
            case 0:
                [self showDeleteAlert];
                break;
                
            default:
                break;
        }
    }
}
- (void)showActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"Delete Photo",nil),
                                  NSLocalizedString(@"Email Photo",nil),
                                  NSLocalizedString(@"Save Photo", nil), nil];
    
	actionSheet.tag = SHARE_ACTION_SHEET_TAG;
	actionSheet.delegate = self;
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	actionSheet.destructiveButtonIndex = 0;	// make the 1st button red (destructive)
	//[actionSheet showInView:self.view]; // show from our table view (pops up in the middle of the table)
	//[actionSheet showFromToolbar:self.navigationController.toolbar];
	[actionSheet showInView:self.view];
    [actionSheet release];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView
{
    if (aScrollView.tag == 1) {
        return;
    }
    
    if (!aScrollView.scrollEnabled) {
        return;
    }
    
	[self hideNavigationBarAndToolBar];
    
	NSInteger pageMargin = aScrollView.contentOffset.x / aScrollView.frame.size.width - self.currentPage;
    
	if (pageMargin >= 0) {
        NSUInteger index = ( [self.photoArray indexOfObject:self.photoFileName] + self.photoArray.count + 1 ) % self.photoArray.count;
        
		[self viewPhotoWithFileName:self.photoArray[index]];
	}else if (pageMargin < 0) {
        NSUInteger index = ( [self.photoArray indexOfObject:self.photoFileName] + self.photoArray.count - 1 ) % self.photoArray.count;
        
		[self viewPhotoWithFileName:self.photoArray[index]];
	}
}

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer
{
    // Disable scroll
    [self.scrollView setScrollEnabled:NO];
    
    // Re-enable scroll after navigation hidden.
    double delayInSeconds = UINavigationControllerHideShowBarDuration;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.scrollView setScrollEnabled:YES];
    });
    
    [self.hideNavigationBarTimer invalidate];
    self.hideNavigationBarTimer = nil;
    
    BOOL hidden = self.navigationController.navigationBarHidden;
    
    [[UIApplication sharedApplication] setStatusBarHidden:!hidden withAnimation:UIStatusBarAnimationFade];
    
    [self.navigationController setNavigationBarHidden:!hidden animated:YES];
    
    [self adjustTabBarWithOrientation:[UIApplication sharedApplication].statusBarOrientation hide:!hidden];
    
	if (hidden) {
		self.hideNavigationBarTimer = [self setupHideNavigationBarTimer];
	}
    
    NSString *iOSVersion = [[UIDevice currentDevice] systemVersion];
    
    // Hide status bar
    if ([iOSVersion compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void) backToPreviousView {
    [self.hideNavigationBarTimer invalidate];
	self.hideNavigationBarTimer = nil;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ) {
		CGFloat fTmp = screenRect.size.height;
		screenRect.size.height = screenRect.size.width;
		screenRect.size.width = fTmp;
	}
    
    CGRect scrollRect = self.scrollView.frame;
    scrollRect.size = screenRect.size;
    
    [self.scrollView setFrame:scrollRect];
    self.scrollView.backgroundColor = [UIColor blackColor];//[UIColor orangeColor];
    
//    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back",nil) style:UIBarButtonItemStyleBordered target:self action:@selector(backToPreviousView)];
//	self.navigationItem.leftBarButtonItem = leftBarButtonItem;
//	[leftBarButtonItem release];
    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    customButton.frame = CGRectMake(0, 0, 44, 44);
    [customButton setBackgroundImage:[UIImage imageNamed:@"cam_back" ] forState:UIControlStateNormal];
    [customButton setBackgroundImage:[UIImage imageNamed:@"cam_back_clicked"] forState:UIControlStateHighlighted];
    [customButton addTarget:self action:@selector(backToPreviousView) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:customButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -16;
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, backButton, nil];
    [backButton release];
	
	UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	[self.scrollView addGestureRecognizer:singleFingerTap];
	[singleFingerTap release];
    
#if 0
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(showDeleteAlert)] autorelease];
#else
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSheet)] autorelease];
#endif	
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self viewPhotoWithFileName:self.photoFileName];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    self.hideNavigationBarTimer = [self setupHideNavigationBarTimer];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.translucent = NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationFade;
}

- (BOOL)prefersStatusBarHidden
{
    return self.navigationController.navigationBarHidden;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	//[self viewPhotoWithFileName:self.photoFileName];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self viewPhotoWithFileName:self.photoFileName];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.scrollView = nil;
    self.camera = nil;
}

- (void)dealloc {
    [mainImageView release];
	[hideNavigationBarTimer release];
	[scrollView release];
	[albumPath release];
	[photoFileName release];
	[photoArray release];
    [camera release];
    [super dealloc];
}

@end
