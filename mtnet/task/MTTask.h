//
//  MTTask.h
//  mcf
//
//  Created by Gang.Wang on 12-1-18.
//  Copyright (c) 2012年. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTTaskDef.h"
@class MTTaskResult;

@protocol MTTaskDelegate;
@interface MTTask : NSOperation
{
    NSString * _name;
    MTTaskResult * _result;
    
    BOOL bNeedStop;
    
    MTTaskStatus _status;    
    BOOL suspend_task;
    
//    id<MTTaskDelegate> task_delegate_;
}

@property(nonatomic, strong) NSString * taskName;
@property(nonatomic, strong) MTTaskResult * result;

@property (nonatomic, assign) BOOL bNeedStop;
@property (nonatomic, assign, getter = isSuspended) BOOL suspendTask;

@property (nonatomic, assign) MTTaskStatus status;
@property (nonatomic, assign) id<MTTaskDelegate> taskDelegate;


/**
 * @brief:  当前任务需要的执行体
 * @param:  无
 * @return: 执行体是否正确执行完成
 * @note:   返回YES, 将会执行 taskAfterRun 方法， 反之则直接退出
 */
- (BOOL) run;

/**
 * @brief:  中止当前任务
 * @param:  无
 * @return: 无
 * @note:   无
 */
- (void) stop;

/**
 * @brief:  任务执行前进行的准备操作
 * @param:  无
 * @return: 准备成功返回 YES, 反之 返回NO
 * @note:   返回YES 任务将继续进行，反之任务将自动中止
 */
-(BOOL) taskBeforeRun;

/**
 * @brief:  任务执行结束，进行的一些操作
 * @param:  无
 * @return: 结束后的操作正确执行返回YES, 反之 返回NO
 * @note:   无
 */
-(BOOL) taskAfterRun;

@end

@protocol MTTaskDelegate <NSObject>
- (void) taskBeforeRun :(MTTask *) task;
- (void) taskAfterRun  :(MTTask *) task;
@end
