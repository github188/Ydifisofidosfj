//
//  NSDate+Date.m
//  DTTest
//
//  Created by Eden Li on 2013/12/23.
//  Copyright (c) 2013年 Darktt. All rights reserved.
//

#import "NSDate+Date.h"

@implementation NSDate (Date)

- (NSDate *)getPastDateWithDays:(NSInteger)days
{
    return [self getDateWithDays:-days];
}

- (NSDate *)getFutureDateWithDays:(NSInteger)days
{
    return [self getDateWithDays:days];
}

- (NSDate *)getDateWithDays:(NSInteger)days
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self];
    [dateComponents setYear:0];
    [dateComponents setMonth:0];
    [dateComponents setDay:days];
    
    NSDate *newDate = [calendar dateByAddingComponents:dateComponents toDate:self options:0];
    
    [calendar release];
//    [dateComponents release];
    
    return newDate;
}

@end
