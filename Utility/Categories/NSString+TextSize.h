//
//  NSString+TextSize.h
//  microcoordinate
//
//  Created by jacky on 15/9/18.
//  Copyright (c) 2015年 corpro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (TextSize)
-(CGSize)textSize:(UIFont*)font;
-(CGSize)textSize:(UIFont *)font withSize:(CGSize)size;
@end
