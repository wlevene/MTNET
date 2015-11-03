//
//  MTTask.m
//  mcf
//
//  Created by Gang.Wang on 12-1-18.
//  Copyright (c) 2012年. All rights reserved.
//

#import "MTTask.h"
#import "NSString+Extension.h"
#import "mcfDef.h"
#import "MTTaskResult.h"
@implementation MTTask
@synthesize taskName = _taskName;
@synthesize result = _result;

@synthesize bNeedStop;
@synthesize suspendTask = suspend_task;

@synthesize status = _status;

@synthesize taskDelegate = task_delegate_;


-(id) init
{
    self = [super init];
    if(self)
    {
        self.bNeedStop          = FALSE;
        self.taskName               = [NSString generateUUID];
        self.suspendTask        = FALSE;
        
        
        MTTaskResult * taskResult = [[MTTaskResult alloc] init];
        taskResult.result = NUKNOW;
        
        self.result = taskResult;
        
        self.status = YTaskStatus_Inactive;
    }
    
    return  self;
}

- (void) stop
{
    self.bNeedStop = TRUE;
}

-(BOOL) taskBeforeRun
{
    self.status = YTaskStatus_Executing;
    
    if (!self.taskDelegate ||
        ![self respondsToSelector:@selector(taskBeforeRun:)]) {
        return TRUE;
    }
    
    [self.taskDelegate performSelector:@selector(taskBeforeRun:) withObject:self];
    
    return TRUE;
}

-(BOOL) taskAfterRun
{
    self.status = YTaskStatus_Finished;
    
    if (!self.taskDelegate ||
        ![self respondsToSelector:@selector(taskAfterRun:)]) {
        return TRUE;
    }
    
    [self.taskDelegate performSelector:@selector(taskAfterRun:) withObject:self];
    
    return TRUE;
}


-(void) main
{
    @autoreleasepool 
    {
        if(![self taskBeforeRun])
        {
            return;
        }
        
        if(![self run])
        {
            return;
        }
        
        if(![self taskAfterRun])
        {
            return;
        }
    }    
}

-(BOOL) run
{    
    // 所有的子类 必须 重写此方法
    return TRUE;
}

- (NSString *) description
{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    
    [dic setObject:self.taskName forKey:@"taskname"];
    [dic setObject:NUMBER(self.status) forKey:@"status"];
    
    [dic setObject:self.taskName forKey:@"taskname"];
    [dic setObject:NUMBER(self.bNeedStop) forKey:@"bNeedStop"];    
    
    NSString * result = [dic description];
    
    return result;
}

@end
