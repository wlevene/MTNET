//
//  MTDownloadRequest.h
//  mcf
//
//  Created by 王刚 on 14-2-18.
//  Copyright (c) 2014年 Gang.Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTTaskDef.h"
#import "MTDownloadRecvData.h"

#import "MTDownloadObjectModel.h"


@protocol MTDownloadRequestDelegate;

@interface MTDownloadRequest : NSObject
{
    
    NSString * name_;
    MTDownloadObjectModel * downloadModel_;
    
    MTDownloadRecvData * recvData_;
    
    id<MTDownloadRequestDelegate> delegate_;
    
    BOOL unNotifyAtFinish;
    PriorityLevel   level_;
    
    NSRunLoop * runloop_;
    NSString * runloopMode_;
}

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) MTDownloadObjectModel * downloadModel;

@property (nonatomic, strong)  MTDownloadRecvData * recvData;

@property (nonatomic, strong) id<MTDownloadRequestDelegate> delegate;
@property (nonatomic, assign) BOOL unNotifyAtFinish;

@property (nonatomic, assign) PriorityLevel  level;

@property (nonatomic, strong) NSRunLoop * runloop;
@property (nonatomic, strong) NSString * runloopMode;

@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, assign) NSInteger mRepeatCountForOuterCtrl; // 重复计数控制，外部使用。

@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval finishTime;

@property (nonatomic, assign) NSTimeInterval duration;


-(void) processOptionWithRequestFinish;

-(void) processOptionWithRequestFailed;

@end


@protocol MTDownloadRequestDelegate <NSObject>
@optional
- (void) didTaskReceiveDataFinish   : (NSData *) theData    request:(MTDownloadRequest*) request;
- (void) taskDataDownloadFailed     : (NSError *) error     request:(MTDownloadRequest*) request;
- (void) taskDataDownloadAtPercent  : (NSNumber *) aPercent request:(MTDownloadRequest*) request;
- (void) taskDataPostAtPercent      : (NSNumber *) aPercent request:(MTDownloadRequest *) request;
- (void) didTaskReceiveFilename     : (NSString *) aName    request:(MTDownloadRequest*) request;
@end
