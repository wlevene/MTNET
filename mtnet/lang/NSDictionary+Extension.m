//
//  NSDictionary+Extension.m

//
//  Created by Gang.Wang on 12-5-29.
//  Copyright (c) 2012年. All rights reserved.
//

#import "NSDictionary+Extension.h"
#include "NSString+Extension.h"

@implementation NSDictionary (Extension)
+ (BOOL) isNilOrEmpty:(NSDictionary *) dictionary
{
    if (!dictionary ||
        [dictionary count] <= 0) {
        return TRUE;
    }
    return FALSE;
}

- (id)objectForKeySafe:(id)aKey
{
    if (!self ||
        (NSObject *)self == [NSNull null])
    {
        return nil;
    }
    
    if (!aKey)
    {
        return nil;
    }
    
    if ([aKey isKindOfClass:[NSString class]] &&
        [NSString isNilOrEmpty:aKey])
    {
        return nil;
    }
    
    if ([self count] <= 0)
    {
        return nil;
    }
    
    if (![self respondsToSelector:@selector(objectForKey:)])
    {
        return nil;
    }
    
    id obj = [self objectForKey:aKey];
    
    if (obj == [NSNull null])
    {
        return nil;
    }
    
    return obj;
}

@end


@implementation NSMutableDictionary (Extension)
+ (BOOL) isNilOrEmpty:(NSMutableDictionary *) dictionary
{
    if (!dictionary ||
        [dictionary count] <= 0) {
        return TRUE;
    }
    return FALSE;
}

- (id)objectForKeySafe:(id)aKey
{
    if (!self ||
        (NSObject *)self == [NSNull null])
    {
        return nil;
    }
    
    if (!aKey)
    {
        return nil;
    }
    
    if ([aKey isKindOfClass:[NSString class]] &&
        [NSString isNilOrEmpty:aKey])
    {
        return nil;
    }
    
    if ([self count] <= 0)
    {
        return nil;
    }
    
    if (![self respondsToSelector:@selector(objectForKey:)])
    {
        return nil;
    }
    
    id obj = [self objectForKey:aKey];
    
    if (obj == [NSNull null])
    {
        return nil;
    }
    
    return obj;
}

@end