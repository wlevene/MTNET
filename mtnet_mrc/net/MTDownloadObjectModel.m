//
//  MTDownloadObjectModel.m
//  mcf
//
//  Created by 王刚 on 14-2-18.
//  Copyright (c) 2014年 Gang.Wang. All rights reserved.
//

#import "MTDownloadObjectModel.h"


#import "mcfDef.h"

@implementation MTDownloadObjectModel

@synthesize url             = url_;
@synthesize httpMethod      = httpMethod_;

@synthesize httpHeaderField = httpHeaderField_;
@synthesize connectionTimeout;

@synthesize cachePolicy     = cachePolicy_;
@synthesize httpBody        =  httpBody_;

- (void) dealloc
{
    MTRelease(url_)
    MTRelease(httpHeaderField_)
    
    MTRelease(httpMethod_)
    MTRelease(httpBody_)
    
    [super dealloc];
}

- (id) init
{
    self = [super init];
    
    if (self)
    {
        self.url                = Nil;
        self.httpHeaderField    = Nil;
        
        self.httpMethod         = Nil;
        self.connectionTimeout  = 0.0f;
    }
    return self;
}



@end
