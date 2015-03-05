//
//  UILabel+Label.m
//
//  Created by Darktt on 13/4/23.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import "UILabel+Label.h"

@implementation UILabel (Label)

+ (id)labelWithFrame:(CGRect)frame
{
    UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
    
    return label;
}

+ (id)labelWithFrame:(CGRect)frame textSize:(CGFloat)textSize
{
    UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
    [label setFont:[UIFont systemFontOfSize:textSize]];
    
    return label;
}

+ (id)labelWithFrame:(CGRect)frame text:(NSString *)text
{
    UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
    [label setText:text];
    
    return label;
}

+ (id)labelWithFrame:(CGRect)frame text:(NSString *)text textSize:(CGFloat)textSize
{
    UILabel *label = [[[UILabel alloc] initWithFrame:frame] autorelease];
    [label setText:text];
    [label setFont:[UIFont systemFontOfSize:textSize]];
    
    return label;
}

#pragma mark - Get label in superview

+ (UILabel *)labelInView:(UIView *)superview withTag:(NSInteger)tag
{
    UILabel *label = (UILabel *)[superview viewWithTag:tag];
    
    if (![label isKindOfClass:[self class]]) {
#ifdef DEBUG
        
        NSLog(@"%s [%d] : Label not found.", __func__, __LINE__);
        
#endif
        return nil;
    }
    
    return label;
}

@end
