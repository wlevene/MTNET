//
//  NSDictionary+Extension.h

//
//  Created by Gang.Wang on 12-5-29.
//  Copyright (c) 2012年. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Extension)

+ (BOOL) isNilOrEmpty:(NSDictionary *) dictionary;
- (id)objectForKeySafe:(id)aKey;

@end


@interface NSMutableDictionary (Extension)

+ (BOOL) isNilOrEmpty:(NSMutableDictionary *) dictionary;
- (id)objectForKeySafe:(id)aKey;

@end