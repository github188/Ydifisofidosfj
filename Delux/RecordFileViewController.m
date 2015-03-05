//
//  RecordFileViewController.m
//  IOTCamViewer
//
//  Created by TUTK_Yulun on 2014/8/22.
//  Copyright (c) 2014年 TUTK. All rights reserved.
//

#import "RecordFileViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface RecordFileViewController ()

@end

@implementation RecordFileViewController

@synthesize camera;

- (void) setVideoArray:(NSArray *)array videoPath:(NSString *)path {
    
    videoArray = [[NSMutableArray alloc] init];
    
    int i;
    
    for (i=0;i<[array count];i++) {
        NSString *urlStr = [NSString stringWithFormat:@"%@/%@",path,[[array objectAtIndex:i]stringByReplacingOccurrencesOfString:@"jpg" withString:@"mp4"]];
        [videoArray addObject:urlStr];
    }
}

- (IBAction)back:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)playOrPause {
    
    if (isPlaying) {
        
        [playAndPauseBTN setBackgroundImage:[UIImage imageNamed:@"ceo_rcplay"] forState:UIControlStateNormal];
        [playAndPauseBTN setBackgroundImage:[UIImage imageNamed:@"ceo_rcplay_click"] forState:UIControlStateHighlighted];
        [playAndPauseBTN_h setBackgroundImage:[UIImage imageNamed:@"ceo_rcplay_h"] forState:UIControlStateNormal];
        [playAndPauseBTN_h setBackgroundImage:[UIImage imageNamed:@"ceo_rcplay_click_h"] forState:UIControlStateHighlighted];
        [moviePlayerController pause];
        
        isPlaying = NO;
        [playerDurationTimer invalidate];

    } else {
        
        [playAndPauseBTN setBackgroundImage:[UIImage imageNamed:@"ceo_pause"] forState:UIControlStateNormal];
        [playAndPauseBTN setBackgroundImage:[UIImage imageNamed:@"ceo_pause_click"] forState:UIControlStateHighlighted];
        [playAndPauseBTN_h setBackgroundImage:[UIImage imageNamed:@"ceo_pause_h"] forState:UIControlStateNormal];
        [playAndPauseBTN_h setBackgroundImage:[UIImage imageNamed:@"ceo_pause_click_h"] forState:UIControlStateHighlighted];
        [moviePlayerController play];
        
        isPlaying = YES;
        playerDurationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
    }
}

- (IBAction)slide {
    
    if (isLandscape) {
        moviePlayerController.currentPlaybackTime = (totalMinute * 60 + totalSecond) * timeSlider_h.value;
    } else {
        moviePlayerController.currentPlaybackTime = (totalMinute * 60 + totalSecond) * timeSlider.value;
    }
    
    [moviePlayerController play];
    
    if (!isPlaying) {
        isPlaying = YES;
        playerDurationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
    }
}

//快轉與倒退
//- (IBAction)touchDown_Back:(id)sender {
//    holdTimer =[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(playBack) userInfo:nil repeats:YES];
//    [moviePlayerController pause];
//}
//
//- (IBAction)touchUp_Back:(id)sender {
//    [holdTimer invalidate];
//    holdTimer = nil;
//    [moviePlayerController play];
//}
//
//- (IBAction)touchUpOutside_Back:(id)sender {
//    [holdTimer invalidate];
//    holdTimer = nil;
//    [moviePlayerController play];
//}
//
//- (void)playFoward {
//    moviePlayerController.currentPlaybackTime += 1.0;
//}
//
//- (void)playBack {
//    moviePlayerController.currentPlaybackTime -= 1.0;
//}

- (void)updateTime:(NSTimer *)timer {
    
   int currentSecond = (int)moviePlayerController.currentPlaybackTime;
    
    int currentMinute = 0;
    if (currentSecond >= 60) {
        int index = currentSecond / 60;
        currentMinute = index;
        currentSecond = currentSecond - index*60;
    }
    
    if (currentSecond >= 10){
        [currentTimeLabel setText:[NSString stringWithFormat:@"%d:%d",currentMinute,currentSecond]];
        [currentTimeLabel_h setText:[NSString stringWithFormat:@"%d:%d",currentMinute,currentSecond]];
    } else {
        [currentTimeLabel setText:[NSString stringWithFormat:@"%d:0%d",currentMinute,currentSecond]];
        [currentTimeLabel_h setText:[NSString stringWithFormat:@"%d:0%d",currentMinute,currentSecond]];
    }

    timeSlider_h.value = moviePlayerController.currentPlaybackTime / floatSec;
    timeSlider.value = moviePlayerController.currentPlaybackTime / floatSec;
    
    if (isPlayOver) {
        timeSlider.value = 0;
        timeSlider_h.value = 0;
        [currentTimeLabel setText:@"0:00"];
        [currentTimeLabel_h setText:@"0:00"];
        [moviePlayerController play];
        [moviePlayerController pause];
        [playAndPauseBTN setBackgroundImage:[UIImage imageNamed:@"ceo_rcplay"] forState:UIControlStateNormal];
        [playAndPauseBTN setBackgroundImage:[UIImage imageNamed:@"ceo_rcplay_click"] forState:UIControlStateHighlighted];
        [playAndPauseBTN_h setBackgroundImage:[UIImage imageNamed:@"ceo_rcplay_h"] forState:UIControlStateNormal];
        [playAndPauseBTN_h setBackgroundImage:[UIImage imageNamed:@"ceo_rcplay_click_h"] forState:UIControlStateHighlighted];
        isPlaying = NO;
        isPlayOver = NO;
        [playerDurationTimer invalidate];
    } else if (timeSlider.value>=1) {
        isPlayOver = YES;
    }
}

- (void)setPlayer:(NSString *)urlStr index:(int)arrayIndex_{
    
    arrayIndex = arrayIndex_;
    
    NSURL *movieURL = [NSURL fileURLWithPath:urlStr];
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:movieURL options:opts];  // 初始化影片
    totalMinute = 0;
    totalSecond = 0;
    totalSecond = urlAsset.duration.value / urlAsset.duration.timescale; // 獲取影片長度（單位：秒）
    floatSec = (float)urlAsset.duration.value / (float)urlAsset.duration.timescale;

    if (totalSecond >= 60) {
        int index = totalSecond / 60;
        totalMinute = index;
        totalSecond = totalSecond - index*60;
    }

    //進入播放介面
    moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:urlStr]];
    
    //動態改變播放器view大小
//    CGSize size = [[[urlAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize];
//    if (size.width>320) {
//        //[moviePlayerController.view setFrame:CGRectMake(0,44+(44*(320/size.width)),320,size.height*(320/size.width))];
//        [moviePlayerController.view setFrame:CGRectMake(0,66,320,240)];
//    } else {
//        [moviePlayerController.view setFrame:CGRectMake(0,44,size.width,size.height)];
//    }
    
    [moviePlayerController.view setFrame:CGRectMake(0,66,320,240)];
    
    [self.view addSubview:moviePlayerController.view];
    
    moviePlayerController.controlStyle = MPMovieControlStyleNone;
    moviePlayerController.movieSourceType = MPMovieSourceTypeFile;
    moviePlayerController.shouldAutoplay = NO;
    [moviePlayerController prepareToPlay];
    
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    
	UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
	[scrollView addGestureRecognizer:singleFingerTap];
	[singleFingerTap release];

    UISwipeGestureRecognizer *leftRecognizer;
    leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [leftRecognizer setDirection: UISwipeGestureRecognizerDirectionLeft];
    [scrollView addGestureRecognizer:leftRecognizer];
    [leftRecognizer release];
    
    UISwipeGestureRecognizer *rightRecognizer;
    rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [rightRecognizer setDirection: UISwipeGestureRecognizerDirectionRight];
    [scrollView addGestureRecognizer:rightRecognizer];
    [rightRecognizer release];
    
    [self.view bringSubviewToFront:scrollView];
}

-(void)reSetPlayer {
    NSURL *movieURL = [NSURL fileURLWithPath:[videoArray objectAtIndex:arrayIndex]];
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:movieURL options:opts];  // 初始化影片
    totalMinute = 0;
    totalSecond = 0;
    totalSecond = urlAsset.duration.value / urlAsset.duration.timescale; // 獲取影片長度（單位：秒）
    floatSec = (float)urlAsset.duration.value / (float)urlAsset.duration.timescale;
    
    if (totalSecond >= 60) {
        int index = totalSecond / 60;
        totalMinute = index;
        totalSecond = totalSecond - index*60;
    }
    
    if (isPlaying) {
        [moviePlayerController pause];
    }
    
    if (totalSecond >= 10){
        [totalTimeLabel setText:[NSString stringWithFormat:@"%d:%d",totalMinute,totalSecond]];
        [totalTimeLabel_h setText:[NSString stringWithFormat:@"%d:%d",totalMinute,totalSecond]];
    } else {
        [totalTimeLabel setText:[NSString stringWithFormat:@"%d:0%d",totalMinute,totalSecond]];
        [totalTimeLabel_h setText:[NSString stringWithFormat:@"%d:0%d",totalMinute,totalSecond]];
    }
    
    [moviePlayerController setContentURL:[NSURL fileURLWithPath:[videoArray objectAtIndex:arrayIndex]]];
    [moviePlayerController play];
    
    [playAndPauseBTN setBackgroundImage:[UIImage imageNamed:@"ceo_pause"] forState:UIControlStateNormal];
    [playAndPauseBTN setBackgroundImage:[UIImage imageNamed:@"ceo_pause_click"] forState:UIControlStateHighlighted];
    [playAndPauseBTN_h setBackgroundImage:[UIImage imageNamed:@"ceo_pause_h"] forState:UIControlStateNormal];
    [playAndPauseBTN_h setBackgroundImage:[UIImage imageNamed:@"ceo_pause_click_h"] forState:UIControlStateHighlighted];
    
    if (isPlaying!=YES) {
        isPlaying = YES;
        playerDurationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
    }
}

-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    //下一部影片
    if ( recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        arrayIndex++;
        
        if (arrayIndex==[videoArray count]){
            arrayIndex = 0;
        }
        
        [self reSetPlayer];
    }
    //上一部影片
    else if ( recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        
        arrayIndex--;
        
        if (arrayIndex < 0){
            arrayIndex = [videoArray count]-1;
        }
        
        [self reSetPlayer];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (isPlaying) {
        [playerDurationTimer invalidate];
        [moviePlayerController stop];
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    isPlaying = NO;
    playerDurationTimer = [[NSTimer alloc] init];
    
    self.navigationItem.title = NSLocalizedString(@"Record Files", @"");
    
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
    
    [timeSlider setThumbImage:[UIImage imageNamed:@"ceo_rcplay_time"] forState:UIControlStateNormal];
    [timeSlider setMinimumTrackImage:[UIImage imageNamed:@"ceo_rcplay_line"] forState:UIControlStateNormal];
    [timeSlider setMaximumTrackImage:[UIImage imageNamed:@"ceo_rcplay_line_full"] forState:UIControlStateNormal];
    
    [timeSlider_h setThumbImage:[UIImage imageNamed:@"ceo_rcplay_time_h"] forState:UIControlStateNormal];
    [timeSlider_h setMinimumTrackImage:[UIImage imageNamed:@"ceo_rcplay_line_h"] forState:UIControlStateNormal];
    [timeSlider_h setMaximumTrackImage:[UIImage imageNamed:@"ceo_rcplay_line_full_h"] forState:UIControlStateNormal];
    
    if (totalSecond >= 10){
        [totalTimeLabel setText:[NSString stringWithFormat:@"%d:%d",totalMinute,totalSecond]];
        [totalTimeLabel_h setText:[NSString stringWithFormat:@"%d:%d",totalMinute,totalSecond]];
    } else {
        [totalTimeLabel setText:[NSString stringWithFormat:@"%d:0%d",totalMinute,totalSecond]];
        [totalTimeLabel_h setText:[NSString stringWithFormat:@"%d:0%d",totalMinute,totalSecond]];
    }
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (screenBounds.size.height == 480) {
        portraitController.y -= 82;
    }
}

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer
{
    if (isLandscape){
        BOOL hidden = landscapeController.hidden;
        landscapeController.hidden = !hidden;
    }
}

#pragma mark Rotate Delegate
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        //畫面傾置
        isLandscape = YES;
        self.navigationController.navigationBarHidden = YES;
        [moviePlayerController.view setFrame:CGRectMake(0, 0,568,320)];
        [self.view bringSubviewToFront:landscapeController];
        
        scrollView.y += 210;
        
        [self.view bringSubviewToFront:scrollView];
        
        // Hide status bar
        [UIApplication sharedApplication].statusBarHidden = YES;
    }
    
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        
        if (isLandscape) {
            //畫面直立
            isLandscape = NO;
            self.navigationController.navigationBarHidden = NO;
            [moviePlayerController.view setFrame:CGRectMake(0,66,320,240)];
            landscapeController.hidden = YES;
            
            scrollView.y -= 210;
            
            // SHow status bar
            [UIApplication sharedApplication].statusBarHidden = NO;
        }
    }
}

@end
