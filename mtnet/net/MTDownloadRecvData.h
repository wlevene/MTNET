//
//  MTDownloadRecvData.h
//  mcf
//
//  Created by 王刚 on 14-2-18.
//  Copyright (c) 2014年 Gang.Wang. All rights reserved.
//

/*
 在使用的时候，使用 DownloadRecvDataMemory || DownloadRecvDataFileSystem 进行数据
 的接收，不能直接使用基类 DownloadRecvData 这里面什么事情都没有做。
 */

#import <Foundation/Foundation.h>
#import "MTDownloadObjectModel.h"

@interface MTDownloadRecvData : NSObject{
    NSString * name_;
    NSString * localCacheDirPath_;
    
    long long needRecvDataLenght_;
    
    BOOL valid_;
    BOOL bCached;
    
    BOOL bCheckRecvDataLenght;
    
    MTDownloadObjectModel * downloadModel_;
    
    BOOL recvFinished;
    BOOL recvedDataFromNet_;
    
    BOOL ignoreCache;
    
}
@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * localCacheDirPath;

@property (nonatomic, assign) long long needRecvDataLenght;
@property (nonatomic, assign) BOOL valid;

@property (nonatomic, assign) BOOL bCached;
@property (nonatomic, assign) BOOL bCheckRecvDataLenght;

@property (nonatomic, strong) MTDownloadObjectModel * downloadModel;
@property (nonatomic, assign, getter = isRecvFinished) BOOL recvFinished;

@property (nonatomic, assign, getter = isRecvedDataFromNet) BOOL recvedDataFromNet;

@property (nonatomic, assign, getter = isIgnoreCache) BOOL ignoreCache;
@property (nonatomic, assign) NSInteger tag;

@property (nonatomic, retain) NSString * localFullPath;


-(void) AppendData : (NSData *) data;

- (void) processRecvAllDataFinish;
- (void) processRecvAllDataFalied;

- (long long)length;

- (NSData *) data;
- (void) clearData;

@end


@interface MTDownloadRecvDataMemory : MTDownloadRecvData
{
    NSMutableData *data_;
}
@property (retain) NSMutableData *recvData;
@end

@interface MTDownloadRecvDataFileSystem : MTDownloadRecvData
{
    NSString * localFullPath_;
    
    NSFileHandle* file_handle_;
    
    BOOL isCraeteByMyself;
    
    NSString * tmpFullPath_;
    
}

@property (nonatomic, retain) NSFileHandle * fileHandle;

@property (nonatomic, copy) NSString * tmpFullPath;

@end