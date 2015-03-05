//
//  UIButton+Bootstrap.h
//
//  Created by Darktt on 13/10/14.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DTInstancetype.h"

typedef NS_ENUM(NSInteger, DTBootstrapStyle) {
    DTBootstrapStyleDefault = 0,
    DTBootstrapStylePrimary,
    DTBootstrapStyleSuccess,
    DTBootstrapStyleInfo,
    DTBootstrapStyleWarning,
    DTBootstrapStyleDanger
};

@interface UIButton (Bootstrap)

+ (DTInstancetype)bootstrapButtonWithFrame:(CGRect)frame style:(DTBootstrapStyle)style;
- (DTInstancetype)initWithFrame:(CGRect)frame style:(DTBootstrapStyle)style;

@end
