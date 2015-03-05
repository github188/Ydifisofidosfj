//
//  TimeZoneListController.h
//  IOTCamViewer
//
//  Created by Gavin Chang on 13/6/13.
//  Copyright (c) 2013年 TUTK. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TimeZoneChangedDelegate <NSObject>
@required
- (void) onTimeZoneChanged:(NSString*)tszTimeZone tzGMTDiff_In_Mins:(int)nGMTDiff_In_Mins;

@end


typedef struct tagTimeZoneStore
{
	char szDesc[256];
	char szGMTDiff[32];
	int nGMTDiff_In_Mins;
} STTIMEZONESTORE, *LPSTTIMEZONESTORE;

typedef struct tagRegionStroe
{
	NSMutableArray* regionArray;
	NSString* strRegionString;
} SREGIONSTORE, *LPSREGIONSTORE;

@interface TimeZoneListController : UITableViewController {

	int mInitSelectedSection;
	int mInitSelectedRow;
	
	NSMutableArray* mTimeZoneArray;
	STTIMEZONESTORE mCurrentTimwZoneStore;
	
	id<TimeZoneChangedDelegate> mTimeZoneChangedDelegate;
}

@property (nonatomic,retain) NSMutableArray* mTimeZoneArray;
@property (nonatomic,assign) id<TimeZoneChangedDelegate> mTimeZoneChangedDelegate;

-(void)setCurrentTimeZone :(NSString*)szDesc tzGMTDiff_In_Mins:(int)nGMTDiff_In_Mins;

@end

