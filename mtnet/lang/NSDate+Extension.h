//
//  YDate.h
//
//  Created by Gang.Wang on 11-10-11.
//  Copyright 2011年. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>

@interface NSDate (NSDateExtension)


+ (NSString *) date2string:(NSDate *) _date;

+ (NSDate *) string2date:(NSString *) _string;

+ (NSString *) currectDay;

/*
 返回当前周的周末
 */
- (NSDate *)endOfWeek;

- (NSDate *)beginningOfMonth;

- (NSUInteger)getSecond;

- (NSUInteger)getMin;

- (NSUInteger)getHour;

- (NSUInteger)getDay;

- (NSUInteger)getMonth;

- (NSUInteger)getYear;


#define DATE_SECOND     (1)
#define DATE_MINUTE     (60*DATE_SECOND)
#define DATE_HOUR       (60*DATE_MINUTE)
#define DATE_DAY        (24*DATE_HOUR)
#define DATE_WEEK       (7*DATE_DAY)
#define DATE_MONTH      (30*DATE_DAY)

+(NSString*) formatCommentDateTime:(NSTimeInterval)time; // "yyyy-MM-dd kk:mm:ss"
+(NSString*) formatCommonDateTime_noyear:(NSTimeInterval)time; // "MM月dd日 kk:mm"
+(NSString*) formatCommonDateTime_monthday:(NSTimeInterval)time; // "MM月dd日"
+(NSString*) formatCommonDateTime_hourminute:(NSTimeInterval)time; // "kk:mm"

+(NSString*) formatDateLeft:(NSTimeInterval)time;
+(NSString*) formatStringDisplay_timego:(NSTimeInterval)time;

+(long) getDayOfMultiplyYearToday; // return a + b * 367;
+(long) getDayOfMultiplyYear:(NSTimeInterval)time; // return a + b * 367;
+(BOOL) isYkTimeToday:(NSTimeInterval)time;


/*
  返回当前周的开始开
 */
- (NSDate *)beginOfWeek;

- (NSDate *)endOfMonth;

- (NSDate *)dateAfterSecond:(int)second;

- (NSDate *)dateAfterHour:(int)hour;

- (NSDate *)dateAfterDay:(int)day;

- (NSDate *)dateafterMonth:(int)month;

//该日期是该年的第几周
- (int )getWeekOfYear;

//该日期是该年的第几天真
- (int )getDayOfYear;


+ (NSString *) time2Now:(NSTimeInterval) time;
+ (NSString*)timestampDistanceDisplay:(NSTimeInterval)createdAt;

/**
 * @brief:  时间的比较
 * @param:  要比较的目标时间
 * @return: 0: 相等     1：当前时间比目标时间早  -1：当前时间比目标时间晚
 * @note:   无
 */
- (int) compareDate:(NSDate *)other;


@end
        