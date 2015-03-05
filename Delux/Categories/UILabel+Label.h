//
//  UILabel+Label.h
//
//  Created by Darktt on 13/4/23.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import <UIKit/UIKit.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000

#define DTTextAlignmentLeft     NSTextAlignmentLeft
#define DTTextAlignmentCenter   NSTextAlignmentCenter
#define DTTextAlignmentRight    NSTextAlignmentRight

#else

#define DTTextAlignmentLeft     UITextAlignmentLeft
#define DTTextAlignmentCenter   UITextAlignmentCenter
#define DTTextAlignmentRight    UITextAlignmentRight

#endif

@interface UILabel (Label)

+ (id)labelWithFrame:(CGRect)frame;

+ (id)labelWithFrame:(CGRect)frame textSize:(CGFloat)textSize;

+ (id)labelWithFrame:(CGRect)frame text:(NSString *)text;

+ (id)labelWithFrame:(CGRect)frame text:(NSString *)text textSize:(CGFloat)textSize;

// Get label in superview
+ (UILabel *)labelInView:(UIView *)superview withTag:(NSInteger)tag;

@end
