//
//  MTTaskPool.m
//  mcf
//
//  Created by Gang.Wang on 12-1-18.
//  Copyright (c) 2012年. All rights reserved.
//

#import "MTTaskPool.h"
#import "MTFixSizeMutableDictionary.h"
#import "mcfDef.h"
#import "NSString+Extension.h"

@implementation MTTaskPool
@synthesize pool = _operation_queue_;
@synthesize taskResults;

-(MTFixSizeMutableDictionary *) taskResults
{
    @synchronized(taskResults)
    {
        return taskResults;
    }
}

@synthesize isInited = b_inited;
@synthesize poolId = pool_id;
-(void) setPoolId:(NSString *)value
{
    if(bSetTaskPoolName)
    {
        return;
    }
    
    bSetTaskPoolName = YES;
    
    pool_id = [[NSString alloc] initWithString:value];
    [self.pool setName:value];
}

-(NSString *) poolId
{
    return pool_id;
}


-(void) _init
{
    if(b_inited)
    {
        return;
    }
    
        
    bSetTaskPoolName = NO;
    
    self.poolId = [[NSString alloc] initWithString:[NSString generateUUID]]; // 不设置的时候，将会内部产生一个名称
    
    self.pool = [[NSOperationQueue alloc] init];
    
    self.taskResults = [[MTFixSizeMutableDictionary alloc] initWithCapacity:_NAX_SIZE_TASK_RELUST_IN_TASK_POOL_];
    
    b_inited = YES;
}
 

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here. 
        [self _init];
    }
    
    return self;
}

-(BOOL) setMaxConcurrentTaskCount:(NSInteger) max_count
{
    if(!self.isInited)   
    {
        return FALSE;
    }
    
    [self.pool setMaxConcurrentOperationCount:max_count];
    
    return  TRUE;
}

- (NSArray *)    tasks
{
    if (!self.isInited) {
        return nil;
    }
    return [self.pool operations];
}

-(NSString *) addTask:(MTTask *) task
{
    if(!self.isInited)   
    {
        return nil;
    }
        
    if (!task) {
        return nil;
    }
    
    if (task.taskName == nil ||
        [task.taskName length] <= 0) {
        task.taskName = [NSString generateUUID];
    }
    
    [task setTaskDelegate:self];
    [self.pool addOperation:task];
    return task.taskName;
}

- (NSArray *)addTasks:(NSArray *)tasks waitUntilFinished:(BOOL)wait
{
    
    if(!self.isInited)   
    {
        return nil;
    }
    
    NSArray * _tasks = tasks;
    
    NSMutableArray * task_names_ = [[NSMutableArray alloc] init];
    
    for (MTTask * _task in _tasks) 
    {
        if (_task.taskName == nil ||
            [_task.taskName length] <= 0)
        {
            _task.taskName = [NSString generateUUID];
        } 
        [task_names_ addObject:_task.taskName];
        
        [_task setTaskDelegate:self];
    }
    
    [self.pool addOperations:_tasks waitUntilFinished:wait];
    
    return (NSArray *) task_names_;
}

-(void) cancelAllTask
{
    if(!self.isInited)   
    {
        return;
    }
    
    [self.pool cancelAllOperations];
}

- (void) cancelTask:(MTTask *) task
{
    if(!self.isInited)   
    {
        return;
    }
    
    [task cancel];
}

- (void) cancelTaskByName :(NSString *) taskName
{
    if(!self.isInited)   
    {
        return;
    }
    
    
    MTTask * task = [self taskByName:taskName];
    if (task) 
    {
        [task cancel];
    }    
}

- (NSInteger) taskCount
{
    if(!self.isInited)   
    {
        return 0;
    }
    
    return [self.pool operationCount];
}

- (void) waitUntilAllTaskAreFinished
{
    if(!self.isInited)   
    {
        return;
    }
    
    [self.pool waitUntilAllOperationsAreFinished];
}

- (NSInteger) maxConcurrentTaskCount
{
    if(!self.isInited)   
    {
        return 0;
    }
    
    return [self.pool maxConcurrentOperationCount];
}


- (void) setSuspended:(BOOL) bSuspended
{
    if(!self.isInited)
    {
        return;
    }
    
    [self.pool setSuspended:bSuspended];
}

- (BOOL)isSuspended
{
    if(!self.isInited)
    {
        return FALSE;
    }
    
    return [self.pool isSuspended];
}

- (void) stopAllTask
{
    if(!self.isInited)   
    {
        return;
    }
    
    NSArray * tasks = [self.pool operations];
    for (MTTask * task in tasks) {
        [self stopTask:task];
    }
}

- (void)        stopTask : (MTTask*) task
{
    [task stop];
}



- (void)        stopTaskByName :(NSString *) taskName
{
    if(!self.isInited)   
    {
        return;
    }
    
    MTTask * task = [self taskByName:taskName];
    if (task) 
    {
        [task stop];
    }    
}



- (MTTask *) taskByName:(NSString *) taskName
{
    if ([NSString isNilOrEmpty:taskName]) {
        return nil;
    }
    
    NSArray * tasks = [self.pool operations];
    for (MTTask * task in tasks) {
        if([task.taskName isEqualToString:taskName])
        {
            return task;
        }
    }

    return nil;
}

- (void)        setTaskQueuePrioity:(PriorityLevel) queuePriorityLevel withTaskName:(NSString *) taskName
{
    if ([NSString isNilOrEmpty:taskName]) {
        return;
    }
    
    MTTask * task = [self taskByName:taskName];
    if (task) 
    {
        [task setQueuePriority:(NSOperationQueuePriority)queuePriorityLevel];
    }        
}


- (void)        setTaskQueuePrioity:(PriorityLevel) queuePriorityLevel withTask:(MTTask *) task
{
    if (!task) 
    {
        return;
    }
    
    [task setQueuePriority:(NSOperationQueuePriority)queuePriorityLevel];
}






#pragma mark
#pragma mark YTaskDelegate
- (void) taskBeforeRun :(MTTask *) task
{
    
}

- (void) taskAfterRun  :(MTTask *) task
{     
    if (!self.taskResults) 
    {
        return;
    }
    
    [self.taskResults setObject:task.result forKey:task.taskName];
}
@end
