//
//  YSchemeUrlParse.h
//  mcf
//
//  Created by Gang.Wang on 13-8-5.
//  Copyright (c) 2013年 yuike. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTSchemeUrlParse : NSObject

@property (nonatomic, copy, readonly)   NSString * scheme;
@property (nonatomic, copy, readonly)   NSString * doma;

@property (nonatomic, copy, readonly)   NSString * query;
@property (nonatomic, retain, readonly) NSString * resourceSpecifier;

@property (nonatomic, retain) NSArray * params;

- (id) initWithString:(NSString *)string;
- (id) initWithUrl:(NSURL *) url;

- (NSString *) valueForParam:(NSString *) param;

@end
