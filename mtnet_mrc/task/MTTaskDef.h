//
//  MTTaskDef.h
//  mcf
//
//  Created by Gang.Wang on 12-1-18.
//  Copyright (c) 2012年. All rights reserved.
//

#ifndef mcf_YTaskDef_h
#define mcf_YTaskDef_h


#define _NAX_SIZE_TASK_RELUST_IN_TASK_POOL_     200

typedef enum{
    SUCCEED = 1,
    ERROR,
    FAILED,
    NUKNOW
} Result;


typedef enum {
    YTaskStatus_Cancelled = -1,
    YTaskStatus_Inactive = 0,
    YTaskStatus_Executing = 1,
    YTaskStatus_Finished = 2
} MTTaskStatus;


typedef enum {
    PriorityVeryLow     = NSOperationQueuePriorityVeryLow,
	PriorityLow         = NSOperationQueuePriorityLow,
	PriorityNormal      = NSOperationQueuePriorityNormal,
	PriorityHigh        = NSOperationQueuePriorityHigh,
	PriorityVeryHigh    = NSOperationQueuePriorityVeryHigh
}PriorityLevel;
#endif
