//
//  MTTaskResult.h
//  mcf
//
//  Created by Gang.Wang on 12-1-19.
//  Copyright (c) 2012年. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MTTaskDef.h"

@interface MTTaskResult : NSObject
{
@private
    Result _result;
}

@property (nonatomic, assign) Result result;

@end