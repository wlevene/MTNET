//
//  NSObject+Extension.m

//
//  Created by Gang.Wang on 12-5-18.
//  Copyright (c) 2012年. All rights reserved.
//

#import "NSObject+Extension.h"

@implementation NSObject (Extension)

- (NSString *) className
{
    NSString * result = [NSString stringWithFormat:@"%@", [self class]];
    return result;
}


- (id) objectAtIndexSafe:(NSUInteger) index
{
    if (![self isKindOfClass:[NSArray class]])
    {
        return nil;
    }
    
    
    if (index >= [(NSArray *) self count])
    {
        return nil;
    }
    
    return [(NSArray *) self objectAtIndex:index];
}

@end
