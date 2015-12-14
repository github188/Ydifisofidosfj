//
//  UIFont+CustomFont.h
//  microcoordinate
//
//  Created by jacky on 15/10/15.
//  Copyright © 2015年 corpro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface UIFont (CustomFont)
+(UIFont*)customFontWithPath:(NSString*)path size:(CGFloat)size;
@end
