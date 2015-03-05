//
//  AudioPickerContentController.h
//  IOTCamViewer
//
//  Created by tutk on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCamera.h"

typedef enum
{
	AUDIO_MODE_OFF          = 0,
	AUDIO_MODE_SPEAKER      = 1,
    AUDIO_MODE_MICROPHONE   = 2,
}ENUM_AUDIO_MODE;

@class Camera;
@protocol AudioPickerDelegate;

@interface AudioPickerContentController : UITableViewController {
    
    id<AudioPickerDelegate> delegate;
    MyCamera *camera;
    NSMutableArray *supportedAudioModes;
}

@property (nonatomic, retain) id<AudioPickerDelegate> delegate;
@property (nonatomic, retain) MyCamera *camera;
@property (nonatomic, retain) NSMutableArray *supportedAudioModes;
@property (nonatomic) ENUM_AUDIO_MODE selectedMode;

- (id) initWithStyle:(UITableViewStyle)style delegate:(id<AudioPickerDelegate>)delegate;
@end

@protocol AudioPickerDelegate
- (void)didAudioModeSelected:(ENUM_AUDIO_MODE)mode;
@end