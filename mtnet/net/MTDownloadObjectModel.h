//
//  MTDownloadObjectModel.h
//  mcf
//
//  Created by 王刚 on 14-2-18.
//  Copyright (c) 2014年 Gang.Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTDownloadObjectModel : NSObject
{
    NSString * url_;
    NSString * httpMethod_;
    
    NSDictionary * httpHeaderField_;
    NSTimeInterval connectionTimeout;
    
    NSURLRequestCachePolicy cachePolicy_;
    
    NSData * httpBody_;
}

@property (nonatomic, strong) NSString * url;
@property (nonatomic, strong) NSString * httpMethod;

@property (nonatomic, strong) NSDictionary * httpHeaderField;
@property (nonatomic, assign) NSTimeInterval connectionTimeout;

@property (nonatomic, assign) NSURLRequestCachePolicy cachePolicy;
@property (nonatomic, strong) NSData * httpBody;

@end
