//
//  RecordFileViewController.h
//  IOTCamViewer
//
//  Created by TUTK_Yulun on 2014/8/22.
//  Copyright (c) 2014年 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "FMDatabase.h"
#import <IOTCamera/Camera.h>
#import "Categories.h"

extern FMDatabase *database;

@interface RecordFileViewController : UIViewController <UIScrollViewDelegate>{
    MPMoviePlayerController *moviePlayerController;
    IBOutlet UIView *portraitController;
    IBOutlet UISlider *timeSlider;
    IBOutlet UISlider *timeSlider_h;
    IBOutlet UIButton *playAndPauseBTN;
    IBOutlet UIButton *playAndPauseBTN_h;
//    IBOutlet UIButton *playBackBTN;
//    IBOutlet UIButton *playFowardBTN;
    IBOutlet UILabel *currentTimeLabel;
    IBOutlet UILabel *totalTimeLabel;
    IBOutlet UILabel *currentTimeLabel_h;
    IBOutlet UILabel *totalTimeLabel_h;
    NSTimer *playerDurationTimer;
    bool isPlaying;
    int totalSecond;
    int totalMinute;
    float floatSec;
    
    NSTimer *holdTimer;
    BOOL isTimerTicking;
    
    IBOutlet UIView *landscapeController;
    IBOutlet UIScrollView *scrollView;
    BOOL isLandscape;
    BOOL isPlayOver;
    
    NSMutableArray *videoArray;
    Camera *camera;
    int arrayIndex;
}

@property (nonatomic, retain) Camera *camera;

- (void)setPlayer:(NSString *)urlStr index:(int)arrayIndex_;
- (void)setVideoArray:(NSArray *)array videoPath:(NSString *)path;

//- (IBAction)touchDown_Back:(id)sender;
//- (IBAction)touchUp_Back:(id)sender;
//- (IBAction)touchUpOutside_Back:(id)sender;

@end
