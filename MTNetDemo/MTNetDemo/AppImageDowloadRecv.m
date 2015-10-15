//
//  AppImageDowloadRecv.m
//  MTNetDemo
//
//  Created by Gang.Wang on 10/15/15.
//  Copyright © 2015 Gang.Wang. All rights reserved.
//

#import "AppImageDowloadRecv.h"
#import "MTPath.h"
#import "MTFile.h"
#import "NSString+Extension.h"
#import "mcfDef.h"

@implementation AppImageDowloadRecv

- (id) init
{
    self = [super init];
    if(self)
    {
        self.localCacheDirPath = [MTPath Combine:kCache combinePath:@"appdata"];
        static BOOL created = FALSE;
        if (!created) {
            created = TRUE;
            [MTPath createDirectory:self.localCacheDirPath withAttributes:nil];
        }
    }
    
    return self;
}

- (void) setFileName:(NSString *) fileName
{
    if ([NSString isNilOrEmpty:fileName])
    {
        return;
    }
    
    self.name = fileName;
    self.localFullPath = [MTPath Combine:self.localCacheDirPath combinePath:fileName];
}

- (BOOL) bCached
{
    return [MTFile fileExistsAtPath:self.localFullPath];
}

- (NSData *) data
{
    if ([self bCached])
    {
        return [NSData dataWithContentsOfFile:self.localFullPath];
    }
    
    return nil;
}

@end
