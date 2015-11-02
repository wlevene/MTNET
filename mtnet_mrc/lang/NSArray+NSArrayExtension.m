//
//  NSArray+NSArrayExtension.m

//
//  Created by Gang.Wang on 12-5-15.
//  Copyright (c) 2012年. All rights reserved.
//

#import "NSArray+NSArrayExtension.h"
#import "NSObject+Extension.h"

@implementation NSArray (NSArrayExtension)

- (NSArray *) randomizedArray {  
    NSMutableArray *results = [NSMutableArray arrayWithArray:self];  
    
    int i = (int)[results count];
    while(--i > 0) {  
        int j = rand() % (i+1);  
        [results exchangeObjectAtIndex:i withObjectAtIndex:j];  
    }  
    
    return [NSArray arrayWithArray:results];  
}  

+ (BOOL) isNilOrEmpty:(NSArray *) array
{
    if ((NSObject *)array == [NSNull null] ||
        !array ||
        [array count] <= 0) 
    {
        return TRUE;
    }
    
    return FALSE;
}

- (NSString *) bondingAString:(NSString *) linkSymbol
{
    NSString * result = @"";
    int count = (int)[self count];
    if (count == 1) 
    {
        id obj = [self objectAtIndexSafe:0];
        if ([obj isKindOfClass:[NSString class]]) 
        {
            result = [result stringByAppendingFormat:@"%@", obj];
        }
        
        return result;
    }
    
    
    for (int i = 0; i < count; i++) 
    {
        id obj = [self objectAtIndexSafe:i];
        if ([obj isKindOfClass:[NSString class]]) 
        {
            result = [result stringByAppendingFormat:@"%@", obj];
            
            if (i < count - 1) 
            {
                result = [result stringByAppendingFormat:@"%@", linkSymbol];
            }
        }
    }
    
    return result;
}

- (NSString *) bondingAString
{
    return [self bondingAString:@","];
}


- (NSArray *) subarrayWithRangeEx:(NSRange)range
{
    NSInteger local = range.location;
    NSInteger len = range.length;
    
    if (local < 0 ||
        local >= [self count])
    {
        return nil;
    }
    
    if(len > ([self count] - local))
    {
        len = ([self count] - local);
    }


    if ( len <= 0)
    {
        return nil;
    }

    return [self subarrayWithRange:NSMakeRange(local, len)];

}

@end

@implementation NSMutableArray (NSArrayExtension)
+ (BOOL) isNilOrEmpty:(NSArray *) array
{
    if ((NSObject *)array == [NSNull null] ||
        !array ||
        [array count] <= 0) {
        return TRUE;
    }
    
    return FALSE;
}


//- (NSString *) bondingAString:(NSString *) linkSymbol
//{
//    return [(NSArray *)self bondingAString:linkSymbol];
//}
//
//- (NSString *) bondingAString
//{
//    return [self bondingAString:@","];
//}
@end