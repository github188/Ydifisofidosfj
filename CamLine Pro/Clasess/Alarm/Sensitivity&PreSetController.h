//
//  Sensitivity&PreSetController.h
//  temptest
//
//  Created by apple  on 16/1/4.
//  Copyright © 2016年 jayzhou. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    SENSTIVITY_TYPE,
    PRESET_TYPE
}ENUM_CONTROLLER_TYPE;

@protocol Sensitivity_PreSetControllerDelegate;

@interface Sensitivity_PreSetController : UITableViewController
@property(nonatomic ,strong) NSArray * items;
@property(nonatomic, assign)  NSInteger selectRow;
@property(nonatomic ,assign) ENUM_CONTROLLER_TYPE type;

@property(nonatomic , assign) id<Sensitivity_PreSetControllerDelegate> delegate;
@end

@protocol Sensitivity_PreSetControllerDelegate <NSObject>

@optional
- (void)didSelectSensitivityValue:(NSInteger)value;

- (void)didSelectPresetValue:(NSInteger)value;

@end