//
//  MTDownloaderHelper.h
//  mcf
//
//  Created by 王刚 on 14-2-18.
//  Copyright (c) 2014年 Gang.Wang. All rights reserved.
//

#import "MTTaskPool.h"
#include "MTDownloadRecvData.h"


@class MTDownloadObjectModel;
@class MTDownloadRequest;
@class MTDownloaderTask;

@protocol MTDownloaderTaskDelegate <NSObject>
@optional
/**
 * @brief:  下载任务结束时，通知外部
 * @param:  theData 下载到的数据
 * @param:  KDownloaderTask 对应的下载任务
 * @return: 无
 * @note:   无
 */
- (void) didTaskReceiveDataFinish: (NSData *) theData       task:(MTDownloaderTask *) task;

/**
 * @brief:  将网络上需要下载对象的文件名通知给外部
 * @param:  aName  要下载的文件名
 * @param:  KDownloaderTask 对应的下载任务
 * @return: 无
 * @note:   这个方法是在 建立 connect 后，立即调用的， 即（返回 Response 时调用的）
 */
- (void) didTaskReceiveFilename: (NSString *) aName         task:(MTDownloaderTask *) task;

/**
 * @brief:  下载任务出错
 * @param:  error 下载过程中的出错信息
 * @param:  KDownloaderTask 对应的下载任务
 * @return: 无
 * @note:   各种能引起下载失败的原因都会经此通知外部
 */
- (void) taskDataDownloadFailed: (NSError *) error          task:(MTDownloaderTask *) task;

/**
 * @brief:  下载进度的通知
 * @param:  aPercent 进度值
 * @param:  KDownloaderTask 对应的下载任务
 * @return: 无
 * @note:   每次接入到数据后都会经此方法通知外部（因为apple自己的规定，无法指定每次接收数据的长度）
 */
- (void) taskDataDownloadAtPercent: (NSNumber *) aPercent   task:(MTDownloaderTask *) task;

/**
 * @brief:  上传进度的通知
 * @param:  aPercent 进度值
 * @param:  KDownloaderTask 对应的下载任务
 * @return: 无
 * @note:   每次接入到数据后都会经此方法通知外部（因为apple自己的规定，无法指定每次上传数据的长度）
 */
- (void) taskDataPostAtPercent: (NSNumber *) aPercent   task:(MTDownloaderTask *) task;

@end

@interface MTDownloaderHelper : MTTaskPool<MTDownloaderTaskDelegate>
{
    MTFixSizeMutableDictionary * requestDictionary_;
    
    NSTimeInterval timeout;
    
}

@property (nonatomic, retain) MTFixSizeMutableDictionary * requestDictionary;
@property (nonatomic, assign) NSTimeInterval timeout;


/**
 * @brief:  添加一个下载请求到下载池
 * @param:  下载请求对象
 * @return: 无
 * @note:   提交后，由下载池管理
 */
- (void) addDownloadRequest:(MTDownloadRequest *) request;
- (void) addDownloadRequest:(MTDownloadRequest *) request unique:(BOOL) unique;

/**
 * @brief:  取消一个下载请求
 * @param:  指定需要取消的下载请求
 * @return: 无
 * @note:   如果此下载请求还在排除就从等待运行队列中移除， 如果已运行就中止当前请求的下载
 */
- (void) cancelDownloadRequest:(MTDownloadRequest *) request;

/**
 * @brief:  取消一个下载请求
 * @param:  指定需要取消的下载请求的名称
 * @return: 无
 * @note:   如果此下载请求还在排除就从等待运行队列中移除， 如果已运行就中止当前请求的下载
 */
- (void) cancelDownloadRequestByName:(NSString *) requestName;

/**
 * @brief:  停止当前下载池中所有的下载任务
 * @return: 无
 * @note:   无
 */
- (void) stopAllRequest;

- (void) setAllRequestPriorityLevel:(PriorityLevel) level;

- (void) stopRequestsWithLevel:(PriorityLevel) level;

- (void) setRequestPriorityLevel:(PriorityLevel) level withRequestName:(NSString *) requestName;
- (NSArray *) allRequests;
@end


@interface MTDownloaderTask : MTTask
{
    NSURLResponse *response_;
    MTDownloadRecvData * recvData_;
    
	MTDownloadObjectModel * downloadModel_;
	NSURLConnection *urlconnection_;
    
    id <MTDownloaderTaskDelegate> delegate_;
    
    NSTimeInterval  timeout;
    NSURL * url;
    
    NSTimeInterval connectionTimeout;
    
    NSRunLoop * runloop_;
    NSString * runloopMode_;
    
}

@property (nonatomic, retain) NSURLResponse *response;
@property (nonatomic, retain) NSURLConnection *urlconnection;

@property (nonatomic, retain) MTDownloadRecvData *recvData;
@property (nonatomic, retain) MTDownloadObjectModel *downloadModel;

@property (nonatomic, assign) id<MTDownloaderTaskDelegate> delegate;
@property (nonatomic, assign) NSTimeInterval  timeout;

@property (nonatomic, retain) NSURL * url;
@property (nonatomic, assign) NSTimeInterval connectionTimeout;

@property (nonatomic, strong) NSRunLoop * runloop;
@property (nonatomic, strong) NSString * runloopMode;

@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval finishTime;

@property (nonatomic, assign) NSTimeInterval duration;

/**
 * @brief:  开始一个具体的下载
 * @param:  包含好下载的url & method & http header 等信息
 * @return: 无
 * @note:   无
 */
- (void) download:(MTDownloadObjectModel *) downloadModel;

/**
 * @brief:  停止当前下载线程
 * @return: 无
 * @note:   无
 */
- (void) stopDownload;

/**
 * @brief:  用来清理在下载停止时的一些操作
 * @return: 无
 * @note:   无
 */
- (void) clearRecvedData;

/**
 * @brief:  停止当前下载线程，并进行清理操作
 * @return: 无
 * @note:   无
 */
- (void) stopDownloadAndClearRecvedData;
@end
