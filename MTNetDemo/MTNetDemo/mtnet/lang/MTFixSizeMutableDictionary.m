//
//  YFixSizeMutableDictionary.m
//  mcf
//
//  Created by Gang.Wang on 12-1-18.
//  Copyright (c) 2012年. All rights reserved.
//

#import "MTFixSizeMutableDictionary.h"
#import "NSString+Extension.h"
#import "mcfDef.h"

@implementation MTFixSizeMutableDictionary

@synthesize keys;
@synthesize count;

- (id)initWithCapacity:(int)cap
{
	if (nil != (self = [super init])) 
    {
		capacity = cap;
		kDictionary = [[NSMutableDictionary alloc] initWithCapacity:cap];
		keys = [[NSMutableArray alloc] initWithCapacity:cap];
        
        obj1 = [[NSObject alloc] init];
        obj2 = [[NSObject alloc] init];
        obj3 = [[NSObject alloc] init];
	}
	return self;
}

- (NSInteger) count
{
    return [self.keys count];
}

- (void) removeAllObject
{
    [keys removeAllObjects];
    [kDictionary removeAllObjects];
}

- (id)objectForKey:(id)key
{
        // Pull key out of age array and move to front, indicates recently used
        @try
        {
        @synchronized(self)
            {
                if (key == nil) return nil;
            
             assert([key isKindOfClass:[NSString class]]);
            if ([NSString isNilOrEmpty:key])
            {
                return nil;
            }
            NSUInteger index = [keys indexOfObject:key];
            if (index == NSNotFound)
                return nil;
            
            if (index>=keys.count)
                return nil;
            
            if (index != 0)
            {
                [keys removeObjectAtIndex:index];
                [keys insertObject:key atIndex:0];
            }
            
            return [kDictionary objectForKey:key];
        }
        }
        @catch (NSException *exception) {
            return nil;
        }
        @finally {
            
        }        
}


- (void)setObject:(id)value forKey:(id)key
{
    if (!value ||
        !key)
    {
        return;
    }
	// Update the age of the inserted object and delete the oldest if needed
          @try {
              @synchronized(self)
              {
                  NSString * keyValue = key;
                
                  if ([NSString isNilOrEmpty:keyValue])
                  {
                      return;
                  }
                  
                  NSUInteger index = [keys indexOfObject:keyValue];
                  if (index != 0) {
                      if (index != NSNotFound)
                      {
                          [keys removeObjectAtIndex:index];
                      }
                      [keys insertObject:keyValue atIndex:0];
                      
                      if ([keys count] > capacity) {
                          id delKey = [keys lastObject];
                          [kDictionary removeObjectForKey:delKey];
                          [keys removeLastObject];
                      }
                  }
                  
                  [kDictionary setObject:value forKey:keyValue];
              }
        }
        @catch (NSException *exception) {
            exception = nil;
        }
        @finally {
            
        }   
}

- (void)removeObjectForKey:(id)aKey
{
    @try {@synchronized(self){
            
            if (!aKey) 
            {
                return;
            }
            
            if (!keys ||
                [keys count] <= 0) 
            {
                return;
            }
            
            if (!kDictionary ||
                [kDictionary count] <= 0) 
            {
                return;
            }
            
            if ([keys containsObject:aKey]) 
            {
                [keys removeObject:aKey];
            }
            
            if ([kDictionary valueForKey:aKey]) 
            {
                [kDictionary removeObjectForKey:aKey];
            }
    }}
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }  
}


- (NSArray *) allKeys
{
    @synchronized(self)
    {
        return keys;
    }
}

- (NSArray *) allValues
{
    @synchronized(self)
    {
        return [kDictionary allValues];
    }
}

@end
