//
//  NSObject+Extension.h

//
//  Created by Gang.Wang on 12-5-18.
//  Copyright (c) 2012年. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Extension)

- (NSString *) className;

- (id) objectAtIndexSafe:(NSUInteger) index;

@end
