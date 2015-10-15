//
//  MTTaskPool.h
//  mcf
//
//  Created by Gang.Wang on 12-1-18.
//  Copyright (c) 2012年. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MTTask.h"

@class MTFixSizeMutableDictionary;

@interface MTTaskPool : NSObject <MTTaskDelegate>
{
    NSOperationQueue *  _operation_queue_;
    BOOL                b_inited;
    MTFixSizeMutableDictionary * taskResults;
    NSString * pool_id;
    BOOL bSetTaskPoolName;
}

@property (nonatomic, readonly) BOOL                            isInited;
@property (nonatomic, retain)   MTFixSizeMutableDictionary       * taskResults;
@property (nonatomic, copy)     NSString                        * poolId;
@property (nonatomic, retain)   NSOperationQueue                * pool;

/**
 * @brief:  设置当前线程池可以同时执行的线程数
 * @param:  max_count 可同时执行的线程数
 * @return: 设置成功返回YES, 反之返回NO
 * @note:   无
 */
- (BOOL)        setMaxConcurrentTaskCount:(NSInteger) max_count;

/**
 * @brief:  添加一个线程到当前线程池
 * @param:  task 需要添加的线程
 * @return: 添加成功返回此任务的名称
 * @note:   此种方式添加任务不需要手动调用 开始运行 的操作， 由线程池根据当前的状态会在
 *          合适的时候自动启动此任务
 */
- (NSString *)  addTask:(MTTask *) task;

/**
 * @brief:  添加一批任务，并执行
 * @param:  tasks 需要添加的一批任务
 * @param:  wait 是否等待此批任务操作结束
 * @return: 返回此批任务的名称列表
 * @note:   无
 */
- (NSArray *)   addTasks:(NSArray *)tasks waitUntilFinished:(BOOL)wait; 

/**
 * @brief:  停止当前线程池中所有未开始运行的任务
 * @param:  无
 * @return: 无
 * @note:   只会停止还未开始的任务，已开始的任务此方法无效
 */
- (void)        cancelAllTask;

/**
 * @brief:  停止一个指定的任务在当前线程池
 * @param:  需要停止的任务
 * @return: 无
 * @note:   无
 */
- (void)        cancelTask:(MTTask *) task;

/**
 * @brief:  停止一个指定的任务在当前线程池
 * @param:  需要停止的任务名称
 * @return: 无
 * @note:   无
 */
- (void)        cancelTaskByName :(NSString *) taskName;

/**
 * @brief:  返回当前线程池中的任务数
 * @param:  无
 * @return: 返回当前线程池中的任务数
 * @note:   无
 */
- (NSInteger)   taskCount;

/**
 * @brief:  返回当前线程池最大可以同时运行的任务数
 * @param:  无
 * @return: 返回当前线程池最大可以同时运行的任务数
 * @note:   无
 */
- (NSInteger)   maxConcurrentTaskCount;

/**
 * @brief:  挂起当前线程池
 * @param:  bSuspended 是否挂起
 * @return: 挂起当前线程池
 * @note:   无
 */
- (void)        setSuspended:(BOOL) bSuspended;

/**
 * @brief:  当前线程池是否挂起
 * @param:  无
 * @return: 当前线程池是否挂起
 * @note:   无
 */
- (BOOL)        isSuspended;

/**
 * @brief:  等待当前线程池中所有任务执行结束
 * @param:  无
 * @return: 无
 * @note:   无
 */
- (void)        waitUntilAllTaskAreFinished;

/**
 * @brief:  中止当前线程池中正在执行的任务
 * @param:  无
 * @return: 无
 * @note:   无
 */
- (void)        stopAllTask;

/**
 * @brief:  中止当前线程池中一个指定的任务
 * @param:  需要中止的任务
 * @return: 无
 * @note:   无
 */
- (void)        stopTask : (MTTask*) task;

/**
 * @brief:  中止当前线程池中一个指定的任务
 * @param:  需要中止的任务名称 
 * @return: 无
 * @note:   无
 */
- (void)        stopTaskByName :(NSString *) taskName;

/**
 * @brief:  当前线程池中所有的任务列表
 * @param:  无
 * @return: 当前线程池中所有的任务列表
 * @note:   无
 */
- (NSArray *)    tasks;

/**
 * @brief:  设置一个指定任务的优先级
 * @param:  queuePriorityLevel 任务的优先级
 * @param:  taskName 指定的任务名称
 * @return: 无
 * @note:   无
 */
- (void)        setTaskQueuePrioity:(PriorityLevel) queuePriorityLevel withTaskName:(NSString *) taskName;

/**
 * @brief:  设置一个指定任务的优先级
 * @param:  queuePriorityLevel 任务的优先级
 * @param:  taskName 指定的任务
 * @return: 无
 * @note:   无
 */
- (void)        setTaskQueuePrioity:(PriorityLevel) queuePriorityLevel withTask:(MTTask *) task;

/**
 * @brief:  根据任务名称返回一个任务对象
 * @param:  指定的任务名称
 * @return: 根据任务名称返回一个任务对象
 * @note:   无
 */
- (MTTask *) taskByName:(NSString *) taskName;
@end
