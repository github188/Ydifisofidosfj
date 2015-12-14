//
//  NSString+TextSize.m
//  microcoordinate
//
//  Created by jacky on 15/9/18.
//  Copyright (c) 2015年 corpro. All rights reserved.
//

#import "NSString+TextSize.h"

@implementation NSString (TextSize)
-(CGSize)textSize:(UIFont *)font{
    NSDictionary *dic=[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    CGSize size=[self sizeWithAttributes:dic];
    return size;
}
-(CGSize)textSize:(UIFont *)font withSize:(CGSize)size{
    NSDictionary *dic=[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    CGRect actualRect=[self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil];
    return actualRect.size;
}
@end
