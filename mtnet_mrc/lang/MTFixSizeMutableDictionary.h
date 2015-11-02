//
//  YFixSizeMutableDictionary.h
//  mcf
//
//  Created by Gang.Wang on 12-1-18.
//  Copyright (c) 2012年. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface MTFixSizeMutableDictionary : NSObject 
{
    int capacity;
	NSMutableDictionary *kDictionary;
	NSMutableArray *keys;
    
    NSObject* obj1;
    NSObject* obj2;
    NSObject* obj3;
    
    NSInteger count;
}
@property ( retain, readonly)	NSMutableArray *keys;
@property (nonatomic, assign) NSInteger count;

- (id)initWithCapacity:(int)cap;

- (id)objectForKey:(id)key;
- (void)setObject:(id)value forKey:(id)key;

- (void)removeObjectForKey:(id)aKey;

- (void) removeAllObject;
- (NSArray *) allKeys;
- (NSArray *) allValues;



@end
