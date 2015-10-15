//
//  YDate.m
// 
//
//  Created by Gang.Wang on 11-10-11.
//  Copyright 2011年  All rights reserved.
//

#import "NSDate+Extension.h"


@implementation NSDate (NSDateExtension)


+(NSString*) formatCommentDateTime:(NSTimeInterval)time // "yyyy-MM-dd kk:mm:ss"
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd kk:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate: [NSDate dateWithTimeIntervalSince1970:time]];
    [dateFormatter release];
    return strDate;
}
+(NSString*) formatCommonDateTime_noyear:(NSTimeInterval)time // "MM月dd日 kk:mm"
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM月dd日 kk:mm"];
    NSString *strDate = [dateFormatter stringFromDate: [NSDate dateWithTimeIntervalSince1970:time]];
    [dateFormatter release];
    return strDate;
}
+(NSString*) formatCommonDateTime_monthday:(NSTimeInterval)time // "MM月dd日"
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM月dd日"];
    NSString *strDate = [dateFormatter stringFromDate: [NSDate dateWithTimeIntervalSince1970:time]];
    [dateFormatter release];
    return strDate;
}
+(NSString*) formatCommonDateTime_hourminute:(NSTimeInterval)time // "kk:mm"
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"kk:mm"];
    NSString *strDate = [dateFormatter stringFromDate: [NSDate dateWithTimeIntervalSince1970:time]];
    [dateFormatter release];
    return strDate;
}

+(NSString*) formatDateLeft:(NSTimeInterval)_time
{
    long long date = _time;
    NSMutableString* str = [NSMutableString string];
    if (date >= DATE_DAY || str.length > 0) {
        [str appendFormat:@"%lld天", date/DATE_DAY];
        date %= DATE_DAY;
    }
    if (date >= DATE_HOUR || str.length > 0) {
        [str appendFormat:@"%lld时", date/DATE_HOUR];
        date %= DATE_HOUR;
    }
    if (date >= DATE_MINUTE || str.length > 0) {
        [str appendFormat:@"%lld分", date/DATE_MINUTE];
        date %= DATE_MINUTE;
    }
    if (str.length > 0) {
        if (date > 0) {
            [str appendFormat:@"%lld秒", date];
        } else {
            [str appendString: @"已截止"];
        }
    }
    return str;
}
+(NSString*) formatStringDisplay_timego:(NSTimeInterval)time
{
    long long nowTime = [[NSDate date] timeIntervalSince1970];
    long quot = nowTime - time;
    
    if (quot <= 0) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM月dd日 kk:mm"];
        NSString *strDate = [dateFormatter stringFromDate: [NSDate dateWithTimeIntervalSince1970:time]];
        [dateFormatter release];
        return strDate;
    }
    if ([self isYkTimeToday:time]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"今天 kk:mm"];
        NSString *strDate = [dateFormatter stringFromDate: [NSDate dateWithTimeIntervalSince1970:time]];
        [dateFormatter release];
        return strDate;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM月dd日 kk:mm"];
    NSString *strDate = [dateFormatter stringFromDate: [NSDate dateWithTimeIntervalSince1970:time]];
    [dateFormatter release];
    return strDate;
}
+(long) getDayOfMultiplyYearToday // return a + b * 367;
{
    long current = [[NSDate date] timeIntervalSince1970] / DATE_DAY;
    return current;
}
+(long) getDayOfMultiplyYear:(NSTimeInterval)time // return a + b * 367;
{
    long xxx = time / DATE_DAY;
    return xxx;
}
+(BOOL) isYkTimeToday:(NSTimeInterval)time
{
    return [self getDayOfMultiplyYear:time] == [self getDayOfMultiplyYearToday];
}




+ (NSString *) currectDay
{  
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    //NSLog(@"%@", strDate);
    [dateFormatter release];
    return strDate;
}

+ (NSString *) date2string:(NSDate *) _date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:_date];
    [dateFormatter release];
    return strDate;
}

+ (NSDate *) string2date:(NSString *) _string
{
    if ([NSString isNilOrEmpty:_string]) 
    {
        return nil;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:_string];
    [dateFormatter release];
    
    return date;
}

/*
 返回当前周的开始日期
 */

- (NSDate *)beginOfWeek {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];    
    
    NSDateComponents *weekdayComponents = [calendar components:NSWeekdayCalendarUnit fromDate:self];
    
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];    
    // to get the end of week for a particular date, add ( -weekday) days
    
    [componentsToAdd setDay:( -[weekdayComponents weekday])];    
    NSDate *beginOfWeek = [calendar dateByAddingComponents:componentsToAdd toDate:self options:0];
    
    [componentsToAdd release];
    
    return beginOfWeek;    
}

/*
    返回当前周的周末
 */

- (NSDate *)endOfWeek {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];    
    
    NSDateComponents *weekdayComponents = [calendar components:NSWeekdayCalendarUnit fromDate:self];
    
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];    
    // to get the end of week for a particular date, add (7 - weekday) days
    
    [componentsToAdd setDay:(7 - [weekdayComponents weekday])];    
    NSDate *endOfWeek = [calendar dateByAddingComponents:componentsToAdd toDate:self options:0];
    
    [componentsToAdd release];
        
    return endOfWeek;    
}

- (NSUInteger)getSecond
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *dayComponents = [calendar components:(kCFCalendarUnitSecond) fromDate:self];
    
    return [dayComponents second];
}

- (NSUInteger)getMin
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *dayComponents = [calendar components:(kCFCalendarUnitMinute) fromDate:self];
    
    return [dayComponents minute];
}

- (NSUInteger)getHour
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *dayComponents = [calendar components:(kCFCalendarUnitHour) fromDate:self];
    
    return [dayComponents hour];
}

- (NSUInteger)getDay{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *dayComponents = [calendar components:(NSDayCalendarUnit) fromDate:self];
    
    return [dayComponents day];    
}

//获取月

- (NSUInteger)getMonth
{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];    
    NSDateComponents *dayComponents = [calendar components:(NSMonthCalendarUnit) fromDate:self];
    
    return [dayComponents month];    
}

//获取年
- (NSUInteger)getYear
{    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *dayComponents = [calendar components:(NSYearCalendarUnit) fromDate:self];    
    return [dayComponents year];    
}


/*
    month个月后的日期
 */

- (NSDate *)dateafterMonth:(int)month
{    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    
    [componentsToAdd setMonth:month];
    
    NSDate *dateAfterMonth = [calendar dateByAddingComponents:componentsToAdd toDate:self options:0];
    
    [componentsToAdd release];
    return dateAfterMonth;    
}


- (NSDate *)dateAfterSecond:(int)second
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    
    // to get the end of week for a particular date, add (7 - weekday) days
    
    [componentsToAdd setSecond:second];
    
    NSDate *dateAfterDay = [calendar dateByAddingComponents:componentsToAdd toDate:self options:0];
    
    [componentsToAdd release];    
    return dateAfterDay;
}

/*
 返回hour 小时后的日期(若hour为负数,则为|hour|小时前的日期)
 */
- (NSDate *)dateAfterHour:(int)hour
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    
    // to get the end of week for a particular date, add (7 - weekday) days
    
    [componentsToAdd setHour:hour];
    
    NSDate *dateAfterDay = [calendar dateByAddingComponents:componentsToAdd toDate:self options:0];
    
    [componentsToAdd release];    
    return dateAfterDay;

}

/*
    返回day天后的日期(若day为负数,则为|day|天前的日期)
 */

- (NSDate *)dateAfterDay:(int)day
{    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    
    // to get the end of week for a particular date, add (7 - weekday) days
    
    [componentsToAdd setDay:day];
    
    NSDate *dateAfterDay = [calendar dateByAddingComponents:componentsToAdd toDate:self options:0];
    
    [componentsToAdd release];    
    return dateAfterDay;
    
}

/*
    该月的第一天
 */
- (NSDate *)beginningOfMonth
{    
    return [self dateAfterDay:(int)(-[self getDay]) + 1];
}


/*
    该月的最后一天
 */
- (NSDate *)endOfMonth
{    
    return [[[self beginningOfMonth] dateafterMonth:1] dateAfterDay:-1];    
}

//该日期是该年的第几周
- (int )getWeekOfYear
{    
    int i = 0;
    
    int year = (int)[self getYear];
    
    NSDate *date = [self endOfWeek];
    
    for (i = 1;[[date dateAfterDay:-7 * i] getYear] == year;i++) 
        
    {
        
    }    
    return i;    
}

- (int)getDayOfYear
{
    int i = 0;
    
    int year = (int)[self getYear];
    for (i = 1;[[self dateAfterDay:i] getYear] == year;i++)
        
    {
        
    }
    
    return 366 - i;
}


- (int) compareDate:(NSDate *)other
{
    if( [self compare:other] == NSOrderedAscending)
    {
        return 1;
    }
    
    if( [self compare:other] == NSOrderedDescending)
    {
        return -1;
    }
    
    return 0;
}



+ (NSString*)timestampDistanceDisplay:(NSTimeInterval)createdAt
{
	NSString *_timestamp;
    // Calculate distance time string
    //
    time_t now;
    time(&now);
    
    int distance = (int)difftime(now, createdAt);
    if (distance < 0) distance = 0;
    
    if (distance < 60) {
        _timestamp = [NSString stringWithFormat:@"%d %@", distance, (distance == 1) ? @"秒前" : @"秒前"];
    }
    else if (distance < 60 * 60) {
        distance = distance / 60;
        _timestamp = [NSString stringWithFormat:@"%d %@", distance, (distance == 1) ? @"分钟前" : @"分钟前"];
    }
    else if (distance < 60 * 60 * 24) {
        distance = distance / 60 / 60;
        _timestamp = [NSString stringWithFormat:@"%d %@", distance, (distance == 1) ? @"小时前" : @"小时前"];
    }
    else if (distance < 60 * 60 * 24 * 7) {
        distance = distance / 60 / 60 / 24;
        _timestamp = [NSString stringWithFormat:@"%d %@", distance, (distance == 1) ? @"天前" : @"天前"];
    }
    else if (distance < 60 * 60 * 24 * 7 * 4 || TRUE) { // wahaha, hoho...
        distance = distance / 60 / 60 / 24 / 7;
        _timestamp = [NSString stringWithFormat:@"%d %@", distance, (distance == 1) ? @"周前" : @"周前"];
    }
    
    else {
        static NSDateFormatter *dateFormatter = nil;
        if (dateFormatter == nil) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        }
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:createdAt];
        _timestamp = [dateFormatter stringFromDate:date];
    }
    return _timestamp;
}


+ (NSString *) time2Now:(NSTimeInterval) time
{
    NSString * result = nil;
    
    if (time < 60) 
    {
        result = [NSString stringWithFormat:@"%.f秒", time];
    }
    else if (time < 60 * 60)
    {
        int min = (float)time / (float)(60);
        
        if (min >= 25 && 
            min <= 59) 
        {
            result = @"半小时";
        }
        else 
        {
            result = [NSString stringWithFormat:@"%d分钟",  min];
        }        
    }
    else if (time < 60 * 60 * 24)
    {
        int hour = (float)time / (float)(60 * 60);
        
        if (hour >= 5 &&
            hour <= 11) 
        {
            result = @"半天";
        }
        if (hour >= 12 &&
            hour <= 23) 
        {
            result = @"半天";
        }
        else 
        {
            result = [NSString stringWithFormat:@"%d小时",  hour];
        }        
    }
    else if (time < 60 * 60 * 60 * 24)
    {
        int day = (float)time / (float)(60 * 60 * 24);
        
        if (day >= 7 &&
            day <= 13) 
        {
            result = @"一周";
        }
        else if (day >= 14 &&
                 day <= 28)
        {
            result = @"半月";
        }
        else if (day >= 29 &&
                 day <= 58)
        {
            result = @"一月";
        }
        else if (day >= 59 &&
                 day <= 88)
        {
            result = @"二月";
        }
        else if (day >= 89 &&
                 day <= 118)
        {
            result = @"三月";
        }
        else if (day >= 119 &&
                 day <= 148)
        {
            result = @"四月";
        }
        else if (day >= 149 &&
                 day <= 178)
        {
            result = @"五月";
        }
        else if (day >= 179 &&
                 day <= 208)
        {
            result = @"半年";
        }
        else if (day >= 209 &&
                 day <= 238)
        {
            result = @"七月";
        }
        else if (day >= 239 &&
                 day <= 268)
        {
            result = @"八月";
        }
        else if (day >= 269 &&
                 day <= 298)
        {
            result = @"九月";
        }
        else if (day >= 299 &&
                 day <= 318)
        {
            result = @"十月";
        }
        else if (day >= 329 &&
                 day <= 348)
        {
            result = @"十一月";
        }
        else if (day >= 349 /*&&
                 day <= 380*/)
        {
            result = @"一年";
        }
        else 
        {
            result = [NSString stringWithFormat:@"%d天",  day];
        }        
    }
    
    return result;
}

@end
