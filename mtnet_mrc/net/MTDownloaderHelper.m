//
//  MTDownloaderHelper.m
//  mcf
//
//  Created by 王刚 on 14-2-18.
//  Copyright (c) 2014年 Gang.Wang. All rights reserved.
//

#import "MTDownloaderHelper.h"
#import "MTFixSizeMutableDictionary.h"
#import "MTDownloadObjectModel.h"
#import "mcfDef.h"
#import "NSString+Extension.h"
#import "MTDownloadRequest.h"
#import "MtLogger.h"
#import "NSArray+NSArrayExtension.h"
#import "NSDictionary+Extension.h"

#define _MAX_SIZE_DOWNLOAD_TASK_RELUST_IN_TASK_POOL_        200

@implementation MTDownloaderHelper
@synthesize requestDictionary = requestDictionary_;
-(MTFixSizeMutableDictionary *) requestDictionary
{
    @synchronized(requestDictionary_)
    {
        return requestDictionary_;
    }
}

@synthesize timeout;
- (void) dealloc
{
    MTRelease(requestDictionary_);
    [super dealloc];
}

- (id) init
{
    self = [super init];
    if (self)
    {
        MTFixSizeMutableDictionary * tmp = [[MTFixSizeMutableDictionary alloc] initWithCapacity:_MAX_SIZE_DOWNLOAD_TASK_RELUST_IN_TASK_POOL_];
        self.requestDictionary = tmp;
        MTRelease(tmp);
        
        [self setMaxConcurrentTaskCount:4];
    }
    return self;
}

- (void) addDownloadRequest:(MTDownloadRequest *) request
{
    [self addDownloadRequest:request unique:NO];
}

- (void) addDownloadRequest:(MTDownloadRequest *) request unique:(BOOL) unique
{
    if (!request) {
        return;
    }
    
    if (unique)
    {
        NSArray * requests = [self allRequests];
        for (MTDownloadRequest * task in requests)
        {
            NSString * url = task.downloadModel.url;
            if ([request.downloadModel.url isEqualToString:url])
            {
                return;
            }
        }
    }
    
    if ( !request.recvData.isIgnoreCache &&
        request.recvData.bCached)
    {
        return;
    }
    
    
    if ([NSString isNilOrEmpty:request.recvData.name])
    {
        request.recvData.name = [request.downloadModel url];
    }
    
    [self.requestDictionary setObject:request forKey:request.name];
    
    MTDownloaderTask * task_ = [[MTDownloaderTask alloc] init];
    [task_ setTaskName:request.name];
    [task_ setRecvData:request.recvData];
    //    [task_ setDownloadModel:request.downloadModel];
    [task_ setQueuePriority:(NSOperationQueuePriority)request.level];
    
    if (self.timeout != 0)
    {
        [task_ setTimeout:self.timeout];
    }
    
    if (request.runloop)
    {
        [task_ setRunloop:request.runloop];
    }
    
    if (![NSString isNilOrEmpty:request.runloopMode])
    {
        [task_ setRunloopMode:request.runloopMode];
    }
    
    [task_ setDelegate:self];
    [task_ download:request.downloadModel];
    
    [self addTask:task_];
    //    LOG(@"task added count:%d, url is:%@, name is: %@",
    //             self.taskCount,
    //             [request.downloadModel url],
    //             task_.taskName);
    
    MTRelease(task_);
    
}

- (void) cancelDownloadRequest:(MTDownloadRequest *) request
{
    if (!request)
    {
        return;
    }
    
    [self cancelDownloadRequestByName:request.name];
}

- (void) cancelDownloadRequestByName:(NSString *) requestName
{
    
    if ([NSString isNilOrEmpty:requestName])
    {
        return;
    }
    
    MTDownloaderTask * task = (MTDownloaderTask *) [self taskByName:requestName];
    if (!task)
    {
        return;
    }
    
    if ([task.recvData isRecvFinished]) {
        return;
    }
    
    
    //    LOG(@"stop unFinish Task:%@", requestName);
    [self stopTaskByName:requestName];
    //    [self cancelTaskByName:requestName];
    [self.requestDictionary removeObjectForKey:requestName];
    
    
}

- (void) stopAllRequest
{
    [self cancelAllTask];
    
    if (self.requestDictionary &&
        ![NSArray isNilOrEmpty:[self.requestDictionary keys]] )
    {
        NSArray * requestKeys = [[self.requestDictionary keys] mutableCopy];
        
        for (NSString * key  in requestKeys)
        {
            if ([NSString isNilOrEmpty:key])
            {
                continue;
            }
            
            MTDownloadRequest * requst = [self.requestDictionary objectForKey:key];
            if(!requst)
            {
                continue;
            }
            requst.delegate = nil;
        }
        
        MTRelease(requestKeys);
    }
    
    [self stopAllTask];
    [self.requestDictionary removeAllObject];
}

- (void) stopTask:(MTTask *)task
{
    if (!task)
    {
        return;
    }
    
    [(MTDownloaderTask *) task setDelegate:nil];
    [super stopTask:task];
}

- (void) setAllRequestPriorityLevel:(PriorityLevel) level
{
    NSArray * allTasks = [self tasks];
    for (MTTask *  task in allTasks)
    {
        [task setQueuePriority:(NSOperationQueuePriority)level];
    }
}

- (void) stopRequestsWithLevel:(PriorityLevel) level
{
    NSArray * allTasks = [self tasks];
    for (MTTask *  task in allTasks)
    {
        if ([task queuePriority] == level)
        {
            [self stopTask:task];
            [self cancelTask:task];
        }
    }
    
}
- (void) setRequestPriorityLevel:(PriorityLevel) level withRequestName:(NSString *) requestName
{
    if ([NSString isNilOrEmpty:requestName]) {
        return;
    }
    
    MTTask * task = [self taskByName:requestName];
    if(task)
    {
        [task setQueuePriority:(NSOperationQueuePriority)level];
    }
}

- (MTDownloadRequest *) requestForKey :(NSString *) key
{
    if ([NSString isNilOrEmpty:key]) {
        return nil;
    }
    
    if (!self.requestDictionary) {
        return nil;
    }
    
    return [self.requestDictionary objectForKey:key];
}

- (NSArray *) allRequests
{
    if (!self.requestDictionary) {
        return nil;
    }
    
    return [self.requestDictionary allValues];
}
#pragma mark
#pragma mark DownloadTaskDelegate
- (void) didTaskReceiveDataFinish: (NSData *) theData task:(MTDownloaderTask *) task;
{
    //    LOG(@"download task finish, taskName:%@", task.name);
    MTDownloadRequest * request = [self requestForKey:task.taskName];
    if (!request) {
        
        //        LOG(@"NOT FOUND REQUEST :%@", task.taskName);
        return;
    }
    
    request.startTime = task.startTime;
    request.finishTime = task.finishTime;
    request.duration = task.duration;
    
    if (!request.recvData)
    {
        request.recvData = task.recvData;
    }
    
    
    [request processOptionWithRequestFinish];
    
    if (!request.delegate) {
        
        //        LOG(@"NOT FOUND REQUEST DELEGATE :%@", task.taskName);
        return;
    }
    
    if ([request.delegate respondsToSelector:@selector(didTaskReceiveDataFinish: request:)])
    {
        [[request delegate] didTaskReceiveDataFinish:theData request:request];
    }
    else {
        //        LOG(@"NOT FOUND REQUEST DELEGATE didTaskReceiveDataFinish :%@", task.taskName);
    }
    
    [self.requestDictionary removeObjectForKey:request.name];
}

- (void) didTaskReceiveFilename: (NSString *) aName task:(MTDownloaderTask *) task;
{
    MTDownloadRequest * request = [self requestForKey:task.taskName];
    if (!request) {
        return;
    }
    
    if (!request.recvData)
    {
        request.recvData = task.recvData;
    }
    
    
    if (!request.delegate) {
        return;
    }
    
    if ([request.delegate respondsToSelector:@selector(didTaskReceiveFilename: request:)])
    {
        [[request delegate] didTaskReceiveFilename:aName request:request];
    }
}

- (void) taskDataDownloadFailed: (NSError *) error task:(MTDownloaderTask *) task;
{
    LOG(@"reason:%@   name:%@", error, task.taskName);
    
    MTDownloadRequest * request = [self requestForKey:task.taskName];
    if (!request) {
        return;
    }
    
    request.startTime = task.startTime;
    request.finishTime = task.finishTime;
    request.duration = task.duration;
    
    if (!request.recvData)
    {
        request.recvData = task.recvData;
    }
    
    
    [request processOptionWithRequestFailed];
    
    if (!request.delegate) {
        return;
    }
    
    if ([request.delegate respondsToSelector:@selector(taskDataDownloadFailed: request:)])
    {
        [[request delegate] taskDataDownloadFailed:error request:request];
    }
    
    [self.requestDictionary removeObjectForKey:request.name];
}

- (void) taskDataDownloadAtPercent: (NSNumber *) aPercent task:(MTDownloaderTask *) task;
{
    MTDownloadRequest * request = [self requestForKey:task.taskName];
    if (!request)
    {
        return;
    }
    
    if (!request.recvData)
    {
        request.recvData = task.recvData;
    }
    
    
    if (!request.delegate)
    {
        return;
    }
    
    if ([request.delegate respondsToSelector:@selector(taskDataDownloadAtPercent: request:)])
    {
        [[request delegate] taskDataDownloadAtPercent:aPercent request:request];
    }
}

- (void) taskDataPostAtPercent: (NSNumber *) aPercent   task:(MTDownloaderTask *) task
{
    MTDownloadRequest * request = [self requestForKey:task.taskName];
    if (!request)
    {
        return;
    }
    
    if (!request.recvData)
    {
        request.recvData = task.recvData;
    }
    
    if (!request.delegate)
    {
        return;
    }
    
    if ([request.delegate respondsToSelector:@selector(taskDataPostAtPercent: request:)])
    {
        [request.delegate taskDataPostAtPercent:aPercent request:request];
    }
}

@end

@interface MTDownloaderTask()
{
    NSTimer * exitTime_;
    BOOL exit;
    
    NSTimer * connectionTimeoutTimer_;
}

@property (nonatomic, strong) NSTimer * exitTime;
@property (nonatomic, strong) NSTimer * connectionTimeoutTimer;

- (void) deleteConnectionTimeoutTimer;

@end

@implementation MTDownloaderTask

@synthesize response               = response_;
@synthesize urlconnection          = urlconnection_;

@synthesize downloadModel          = downloadModel_;
@synthesize recvData               = recvData_;

@synthesize delegate               = delegate_;
@synthesize timeout;

@synthesize exitTime               = exitTime_;
@synthesize url;

@synthesize connectionTimeout;
@synthesize connectionTimeoutTimer = connectionTimeoutTimer_;

@synthesize runloop = runloop_;
@synthesize runloopMode = runloopMode_;

- (void) dealloc
{
    [self stopDownload];
    
    MTRelease(downloadModel_);
    MTRelease(urlconnection_);
    
    MTRelease(recvData_);
    MTRelease(response_);
    
    MTRelease(url)
    MTRelease(exitTime_)
    
    MTRelease(connectionTimeoutTimer_);
    
    MTRelease(runloopMode_)
    MTRelease(runloop_)
    
    [super dealloc];
}

- (id) init
{
    self = [super init];
    if (self) {
        self.downloadModel      = Nil;
        self.recvData           = Nil;
        self.urlconnection      = Nil;
        self.response           = Nil;
        
        exit                    = TRUE;
        self.exitTime = [NSTimer timerWithTimeInterval:0.000001f target:self selector:@selector(exitInputSource) userInfo:nil repeats:NO];
    }
    return self;
}

- (void) setConnectionTimeout:(NSTimeInterval)connectionTimeoutValue
{
    if (connectionTimeoutValue <= 0 )
    {
        return;
    }
    
    connectionTimeout = connectionTimeoutValue;
    
    self.connectionTimeoutTimer = [NSTimer timerWithTimeInterval:connectionTimeout target:self selector:@selector(exitForConnectionTimeout) userInfo:nil repeats:NO];
    
    [[NSRunLoop currentRunLoop] addTimer:self.connectionTimeoutTimer forMode:NSDefaultRunLoopMode];
}

- (void) exitForConnectionTimeout
{
    LOG(@"连接超时:%@", self->url);
    [self deleteConnectionTimeoutTimer];
    
    [self stop];
    [self stopDownload];
    
    [self.recvData processRecvAllDataFalied];
    [self.recvData setRecvFinished:TRUE];
    
    [self delegateFailedReason:[NSError errorWithDomain:@"connect time out" code:444 userInfo:nil]];
    
}

- (void) cleanup
{
	self.recvData       = nil;
	self.response       = nil;
    
	self.urlconnection  = nil;
	self.downloadModel  = nil;
}

- (void) stopDownload
{
    [self.urlconnection cancel];
    self.urlconnection = nil;
}

- (void) clearRecvedData
{
    [self.recvData clearData];
}


- (void) stopDownloadAndClearRecvedData
{
    [self stopDownload];
    [self clearRecvedData];
}

- (void) download:(MTDownloadObjectModel *) downloadModelValue;
{
    self.downloadModel = downloadModelValue;
    
    if (!downloadModelValue) {
        return;
    }
    
    if ([NSString isNilOrEmpty:downloadModelValue.url])
    {
        return;
    }
    
    NSString * strUrl = self.downloadModel.url;
    
    //    NSString * decoderUrlString = [strUrl urldecodedValue];
    //    NSString * encodingUrlString = [decoderUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL * urlHttp = [NSURL URLWithString:strUrl];
    self.url = urlHttp;
}



- (void)exitInputSource
{
    //    LOG(@"exitInputSource, name:%@, needstop:%d", self.name, self.bNeedStop);
    [self.exitTime invalidate];
}


-(void) addExitTime2CurrentRunLoop
{
    [[NSRunLoop currentRunLoop] addTimer:self.exitTime forMode:NSDefaultRunLoopMode];
    [self.exitTime fire];
}

- (void) deleteConnectionTimeoutTimer
{
    if (!self.connectionTimeoutTimer)
    {
        return;
    }
    
    if (self.connectionTimeoutTimer.isValid)
    {
        [self.connectionTimeoutTimer invalidate];
    }
}


#pragma mark
#pragma mark MTTask
- (void) stop
{
    [super stop];
    [self addExitTime2CurrentRunLoop];
}


- (void) cancel
{
    [self stop];
    [super cancel];
}

- (void) delegateFailedReason:(NSError *) error
{
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(taskDataDownloadFailed:task:)])
    {
        [self.delegate taskDataDownloadFailed:error task:self];
    }
}
- (BOOL) taskBeforeRun
{
    if(![super taskBeforeRun])
    {
        return FALSE;
    }
    
    NSDate * date = [NSDate date];
    self.startTime = [date timeIntervalSince1970];
    
    // to do setup
    if (!self->url)
    {
        NSString *reason = [NSString stringWithFormat:@"Could not create URL from string %@", self->url];
        NSError * error = [NSError errorWithDomain:reason code:444 userInfo:nil];
        LOG(@"%@", reason);
		[self delegateFailedReason:error];
        return FALSE;
    }
    
    if ([self->url isFileURL])
    {
        NSString *reason = [NSString stringWithFormat:@"Url is local path %@", self->url];
        LOG(@"%@", reason);
        NSError * error = [NSError errorWithDomain:reason code:444 userInfo:nil];
		[self delegateFailedReason:error];
        return FALSE;
    }
    
    if (!self.recvData.isIgnoreCache &&
        [self.recvData bCached]) {
        NSString *reason = [NSString stringWithFormat:@"RecvData is Cached %@", self.recvData];
        LOG(@"%@", reason);
        NSError * error = [NSError errorWithDomain:reason code:444 userInfo:nil];
		[self delegateFailedReason:error];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTaskReceiveDataFinish: task:)])
        {
            [[self delegate] didTaskReceiveDataFinish:self.recvData.data task:self];
        }
        return FALSE;
    }
    
    NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc] init];
	if (!theRequest)
	{
		NSString *reason = [NSString stringWithFormat:@"Could not create URL request from string %@", self->url];
        LOG(@"%@", reason);
        NSError * error = [NSError errorWithDomain:reason code:444 userInfo:nil];
		[self delegateFailedReason:error];
		return FALSE;
	}
    
    [theRequest setURL:self->url];
    [theRequest setCachePolicy:self.downloadModel.cachePolicy];
    
    if (self.timeout != 0)
    {
        [theRequest setTimeoutInterval:self.timeout];
    }
    
    if (![NSString isNilOrEmpty:self.downloadModel.httpMethod])
    {
        [theRequest setHTTPMethod:self.downloadModel.httpMethod];
    }
    
    if (![NSDictionary isNilOrEmpty:self.downloadModel.httpHeaderField])
    {
        [theRequest setAllHTTPHeaderFields:self.downloadModel.httpHeaderField];
    }
    
    if (self.downloadModel.httpBody)
    {
        [theRequest setHTTPBody:self.downloadModel.httpBody];
    }
    
    self.urlconnection = [[[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:NO] autorelease];
    MTRelease(theRequest)
	if (!self.urlconnection)
	{
		NSString *reason = [NSString stringWithFormat:@"URL connection failed for string %@", self->url];
        //        LOG(reason);
        NSError * error = [NSError errorWithDomain:reason code:444 userInfo:nil];
		[self delegateFailedReason:error];
		return FALSE;
	}
    
    if (![NSString isNilOrEmpty:self.runloopMode])
    {
        [self.urlconnection scheduleInRunLoop:!self.runloop ? [NSRunLoop currentRunLoop] : self.runloop forMode:self.runloopMode];
    }
    
    if (self.downloadModel.connectionTimeout > 0)
    {
        self.connectionTimeout = self.downloadModel.connectionTimeout;
    }
    
    [self.urlconnection start];
    
    return TRUE;
}

- (BOOL) taskAfterRun
{
    if(![super taskAfterRun])
    {
        return FALSE;
    }
    
    return TRUE;
}

- (BOOL) run
{
    NSDate* endDate = [NSDate distantFuture];
    NSRunLoop * currentRunLoop = [NSRunLoop currentRunLoop];
    
    do {
        
        [currentRunLoop runMode:NSDefaultRunLoopMode beforeDate:endDate];
        if ([self isCancelled])
        {
            //            LOG(@"isCancelled Task:%@", self.name);
            return FALSE;
        }
        
    } while (!self.bNeedStop);
    
    if (self.bNeedStop)
    {
        //        LOG(@"Stoped Task:%@", self.name);
        [self stopDownload];
    }
    
    return TRUE;
}


- (void) setFinishTime:(NSTimeInterval)finishTime
{
    _finishTime = finishTime;
    
    self.duration = finishTime - self.startTime;
}


#pragma mark
#pragma mark NSURLConnection

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse
{
    @try
    {
        [self deleteConnectionTimeoutTimer];
        
        if (self.bNeedStop)
        {
            [self stop];
            return;
        }
        
        // store the response information
        self.response = aResponse;
        
        [self.recvData setNeedRecvDataLenght:[self.response expectedContentLength]];
        if ([self.response expectedContentLength] < 0)
        {
            [self.recvData setBCheckRecvDataLenght:NO];
        }
        
        if ([aResponse suggestedFilename])
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didTaskReceiveFilename: task:)])
            {
                [[self delegate] didTaskReceiveFilename:[aResponse suggestedFilename] task:self];
            }
        }
    }
    @catch (NSException *exception) {
        NSString* debuginfo = [NSString stringWithFormat:@"Error: name: %@ reason: %@", exception.name, exception.reason];
#pragma unused(debuginfo)
        LOG(@"%@", debuginfo);
        [self stop];
    }
    @finally {
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData
{
    @try
    {
        if (self.bNeedStop)
        {
            [self stop];
            return;
        }
        
        if (!theData)
        {
            return;
        }
        
        if(!self.recvData)
        {
            MTDownloadRecvDataMemory * temp_recv = [[MTDownloadRecvDataMemory alloc] init];
            self.recvData = temp_recv;
            MTRelease(temp_recv)
        }
        
        [self.recvData AppendData:theData];
        
        if (self.response)
        {
            float expectedLength = [self.response expectedContentLength];
            float currentLength = self.recvData.length;
            
            float percent = .0f;
            if (expectedLength != .0f)
            {
                percent = currentLength / expectedLength;
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(taskDataDownloadAtPercent: task:)])
            {
                [[self delegate] taskDataDownloadAtPercent:NUMBER(percent) task:self];
            }
        }
        
    }
    @catch (NSException *exception) {
        NSString* debuginfo = [NSString stringWithFormat:@"Error: name: %@ reason: %@", exception.name, exception.reason];
#pragma unused(debuginfo)
        LOG(@"%@", debuginfo);
    }
    @finally {
        
    }
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    @try
    {
        if (self.bNeedStop)
        {
            [self stop];
            return;
        }
        
        self.response = nil;
        
        [self.recvData processRecvAllDataFinish];
        [self.recvData setRecvFinished:TRUE];
        
        NSData *theData = [self.recvData data];
        
        NSDate * date = [NSDate date];
        self.finishTime = [date timeIntervalSince1970];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTaskReceiveDataFinish: task:)])
        {
            [[self delegate] didTaskReceiveDataFinish:theData task:self];
        }
        
        [self stop];
        
    }
    @catch (NSException *exception) {
        
        NSString* debuginfo = [NSString stringWithFormat:@"Error: name: %@ reason:%@ info:%@",
                               exception.name,
                               exception.reason,
                               exception.userInfo];
#pragma unused(debuginfo)
        LOG(@"%@", debuginfo);
        [self stop];
    }
    @finally {
    }
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    @try
    {
        if (self.bNeedStop)
        {
            [self stop];
            return;
        }
        
        [self deleteConnectionTimeoutTimer];
        
        [self.recvData processRecvAllDataFalied];
        [self.recvData setRecvFinished:TRUE];
        
        NSDate * date = [NSDate date];
        self.finishTime = [date timeIntervalSince1970];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(taskDataDownloadFailed: task:)])
        {
            [[self delegate] taskDataDownloadFailed:error task:self];
        }
        [self stop];
    }
    @catch (NSException *exception) {
        NSString* debuginfo = [NSString stringWithFormat:@"Error: name: %@ reason: %@", exception.name, exception.reason];
#pragma unused(debuginfo)
        LOG(@"%@", debuginfo);
        [self stop];
    }
    @finally {
        
    }
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    @try
    {
        if (self.bNeedStop)
        {
            [self stop];
            return;
        }
        
        /*
         bytesWritten  本次写入多少数据
         ntotalBytesWritten 当前已写入多少数据
         totalBytesExpectedToWrite  一共要写入多少数据
         */
        
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(taskDataPostAtPercent: task:)])
        {
            NSInteger percent = (int)((float)totalBytesWritten / (float)totalBytesExpectedToWrite * 100);
            [[self delegate] taskDataPostAtPercent:NUMBER(percent) task:self];
        }
    }
    @catch (NSException *exception) {
        NSString* debuginfo = [NSString stringWithFormat:@"Error: name: %@ reason: %@", exception.name, exception.reason];
#pragma unused(debuginfo)
        LOG(@"%@", debuginfo);
    }
    @finally {
        
    }
    
}



@end


