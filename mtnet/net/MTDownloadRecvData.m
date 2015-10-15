//
//  MTDownloadRecvData.m
//  mcf
//
//  Created by 王刚 on 14-2-18.
//  Copyright (c) 2014年 Gang.Wang. All rights reserved.
//

#import "MTDownloadRecvData.h"
#import "MTFile.h"
#import "MTPath.h"
#import "mcfDef.h"
#import "MtLogger.h"
#import "NSString+Extension.h"

@implementation MTDownloadRecvData
@synthesize  name = name_;
@synthesize localCacheDirPath = localCacheDirPath_;

@synthesize needRecvDataLenght = needRecvDataLenght_;
@synthesize valid = valid_;

@synthesize bCached;
@synthesize bCheckRecvDataLenght;

@synthesize downloadModel = downloadModel_;
@synthesize recvFinished;

@synthesize recvedDataFromNet = recvedDataFromNet_;
@synthesize ignoreCache;

-(void) dealloc
{
    MTRelease(name_);
    MTRelease(localCacheDirPath_);
    
    MTRelease(downloadModel_)
    [super dealloc];
}

-(id) init
{
    self = [super init];
    if (self)
    {
        self.bCheckRecvDataLenght = YES;
        [self setRecvFinished:FALSE];
        
        [self setRecvedDataFromNet:FALSE];
        self.localCacheDirPath = Nil;
        
        self.needRecvDataLenght = 0;
        self.valid = FALSE;
        
        self.bCached = FALSE;
        self.downloadModel = Nil;
    }
    return self;
}

-(void) AppendData:(NSData *)data
{
    [self setRecvedDataFromNet:TRUE];
}

- (long long)length
{
    // 子类 override 此方法
    kMustOverrideMethod
    return 0;
}

- (NSData *) data
{
    // 子类 override 此方法
    kMustOverrideMethod
    return nil;
}

- (void) clearData
{
    // 子类 override 此方法
    kMustOverrideMethod
}

- (void) processRecvAllDataFinish
{
    kMustOverrideMethod
}
- (void) processRecvAllDataFalied
{
    kMustOverrideMethod
}
@end

@implementation MTDownloadRecvDataMemory
@synthesize recvData = data_;

-(void) dealloc
{
    MTRelease(data_);
    [super dealloc];
}

-(id) init
{
    self = [super init];
    if(self)
    {
        self.recvData = [NSMutableData data];
    }
    return self;
}

-(void) AppendData:(NSData *)dataValue
{
    [super AppendData:dataValue];
    
    if(self.recvData == nil)
        self.recvData = [[[NSMutableData alloc] init] autorelease];
    [self.recvData appendData:dataValue];
    
}

- (long long)length
{
    if(self.data == nil)
    {
        return 0;
    }
    
    return self.data.length;
}

- (NSData *) data
{
    return data_;
}

- (void) processRecvAllDataFinish
{
    
}

- (void) processRecvAllDataFalied
{
    
}

@end


@implementation MTDownloadRecvDataFileSystem

@synthesize fileHandle = file_handle_;

@synthesize tmpFullPath = tmpFullPath_;

-(void) dealloc
{
    [self.fileHandle closeFile];
    MTRelease(file_handle_);
    
    // 为了 在主动 cancel 下载任务时， 需要自己清理还下完的文件
    if (self.isRecvedDataFromNet)
    {
        if (!self.isRecvFinished)
        {
            [self clearData];
        }
        
        // 检查文件长度，是否下载的数据的数据头里的是否一致
        if (self.bCheckRecvDataLenght)
        {
            NSData * checkData = [self data];
            if (checkData &&
                self.needRecvDataLenght != [[self data] length])
            {
                [self clearData];
            }
        }
    }
    
    MTRelease(tmpFullPath_);
    [super dealloc];
}

- (id) init
{
    self = [super init];
    if (self) {
        isCraeteByMyself = NO;
        self.localFullPath = Nil;
        self.tmpFullPath = Nil;
        
        if (![MTFile fileExistsAtPath:kDownloadTempPath]) {
            [MTFile createDirectoryAtPath:kDownloadTempPath withAttributes:nil];
        }
    }
    return self;
}

- (void) clearData
{
    if (![NSString isNilOrEmpty:self.localFullPath] &&
        [MTFile fileExistsAtPath:self.localFullPath])
    {
        BOOL isDir = FALSE;
        [MTFile isDirectory:self.localFullPath isDirectory:&isDir];
        
        if (isDir)
        {
            return;
        }
        
        [MTFile deleteFileAtPath:self.localFullPath];
    }
    
    if (![NSString isNilOrEmpty:self.tmpFullPath] &&
        [MTFile fileExistsAtPath:self.tmpFullPath])
    {
        BOOL isDir = FALSE;
        [MTFile isDirectory:self.tmpFullPath isDirectory:&isDir];
        
        if (isDir)
        {
            return;
        }
        [MTFile deleteFileAtPath:self.tmpFullPath];
    }
}

-(void) AppendData:(NSData *)data
{
    
    @try
    {
        [super AppendData:data];
        
        if ([NSString isNilOrEmpty:self.tmpFullPath])
        {
            // 文件名为空，无法保存，直接退出
            LOG(@"Download File is Nil, return");
            return;
        }
        
        
        if(![MTFile fileExistsAtPath:self.tmpFullPath])
        {
            [MTFile createFileAtPath:self.tmpFullPath withData:nil andAttributes:nil];
            isCraeteByMyself = YES;
            
            if (!self.fileHandle)
            {
                [self.fileHandle closeFile];
                MTRelease(file_handle_);
            }
            NSError * error = nil;
            self.fileHandle = [NSFileHandle fileHandleForUpdatingURL:[NSURL fileURLWithPath:self.tmpFullPath]
                                                               error:&error];
            
            if(error ||
               !self.fileHandle)
            {
                LOG(@"fileHandleForUpdatingURL has Error: %@", error);
                error = nil;
                
                if (!self.fileHandle)
                {
                    [self.fileHandle closeFile];
                    MTRelease(file_handle_);
                }
                
                self.fileHandle = [NSFileHandle fileHandleForUpdatingURL:[NSURL fileURLWithPath:self.tmpFullPath]
                                                                   error:&error];
                
                if(error ||
                   !self.fileHandle)
                {
                    LOG(@"fileHandleForUpdatingURL has Error again: %@", error);
                    error = nil;
                    
                    if (!self.fileHandle)
                    {
                        [self.fileHandle closeFile];
                        MTRelease(file_handle_);
                    }
                    
                    self.fileHandle = [NSFileHandle fileHandleForUpdatingURL:[NSURL fileURLWithPath:self.tmpFullPath]
                                                                       error:&error];
                }
            }
        }
        
        if (!isCraeteByMyself) {
            return;
        }
        
        
        if (!self.fileHandle) {
            LOG(@"fileHandle is Nil, return");
            return;
        }
        
        unsigned long long  seekOfFile = [self.fileHandle seekToEndOfFile];
        if (seekOfFile < 0.0f)
        {
            return;
        }
        [self.fileHandle writeData:data];
    }
    @catch (NSException *exception) {
        LOG(@"Error: name: %@ reason: %@", exception.name, exception.reason);
        return;
    }
    @finally {
        return;
    }
}

- (long long)length
{
    @try {
        unsigned long long length_ = [MTFile sizeOfFilePath:self.tmpFullPath];
        return  length_;
    }
    @catch (NSException *exception) {
        LOG(@"Error: name: %@ reason: %@", exception.name, exception.reason);
        return 0.0f;
    }
    @finally {
        
    }
    
}

- (NSString *) tmpFullPath
{
    if ([NSString isNilOrEmpty:tmpFullPath_]) {
        tmpFullPath_ = [[MTPath Combine:kDownloadTempPath combinePath:[self.name stringByAppendingString:[NSString generateUUID]]] retain];
        
        BOOL isDirectory = FALSE;
        [MTFile isDirectory:tmpFullPath_ isDirectory:&isDirectory];
        if (isDirectory)
        {
            return tmpFullPath_;
        }
        
        BOOL bExists = [MTFile fileExistsAtPath:tmpFullPath_];
        if (bExists) {
            [MTFile deleteFileAtPath:tmpFullPath_];
        }
    }
    
    return tmpFullPath_;
}

- (NSData *) data
{
    NSURL * file_url_ = [NSURL fileURLWithPath:self.localFullPath];
    if(!file_url_)
    {
        return nil;
    }
    NSData * data_ = [NSData dataWithContentsOfURL:file_url_];
    return data_;
}

- (BOOL) bCached
{
    BOOL bExists = [MTFile fileExistsAtPath:self.localFullPath];
    return bExists;
}

- (NSString *) localCacheDirPath
{
    if ([NSString isNilOrEmpty:localCacheDirPath_])
    {
        return kCache;
    }
    
    return localCacheDirPath_;
}


- (NSString *) localFullPath
{
    if ([NSString isNilOrEmpty:self.name])
    {
        return nil;
    }
    
    if ([NSString isNilOrEmpty:self.localCacheDirPath])
    {
        return nil;
    }
    
    return [MTPath Combine:self.localCacheDirPath combinePath:self.name];
}



- (void) processRecvAllDataFinish
{
    if ([NSString isNilOrEmpty:self.localFullPath] ||
        [NSString isNilOrEmpty:self.tmpFullPath])
    {
        return;
    }
    
    if ([NSString isNilOrEmpty:self.localCacheDirPath])
    {
        self.localCacheDirPath = kCache;
    }
    
    if ([NSString isNilOrEmpty:self.localFullPath])
    {
        self.localFullPath = [MTPath Combine:self.self.localFullPath combinePath:self.name];
    }
    
    if (![MTFile fileExistsAtPath:self.localCacheDirPath])
    {
        [MTPath createDirectory:self.localCacheDirPath withAttributes:nil];
    }
    
    [MTFile moveFileFromPath:self.tmpFullPath toPath:self.localFullPath];
}
- (void) processRecvAllDataFalied
{
    
}
@end
