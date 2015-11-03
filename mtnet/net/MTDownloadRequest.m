//
//  MTDownloadRequest.m
//  mcf
//
//  Created by 王刚 on 14-2-18.
//  Copyright (c) 2014年 Gang.Wang. All rights reserved.
//

#import "MTDownloadRequest.h"
#import "mcfDef.h"
#import "NSString+Extension.h"
@implementation MTDownloadRequest

@synthesize name = name_;
@synthesize downloadModel = downloadModel_;

@synthesize delegate = delegate_;
@synthesize recvData = recvData_;

@synthesize unNotifyAtFinish;
@synthesize level = level_;

@synthesize runloop = runloop_;
@synthesize runloopMode = runloopMode_;


- (id) init
{
    self = [super init];
    if (self) {
        self.name = [NSString generateUUID];
        self.downloadModel = [[MTDownloadObjectModel alloc] init];
    }
    return self;
}


-(void) processOptionWithRequestFinish
{
    
}

-(void) processOptionWithRequestFailed
{
    
}



- (NSString *) description
{
    return [NSString stringWithFormat:@"==================================================\r\n[URL:%@] \r\n[HEADER:%@] \r\n[METHOD:    %@] \r\n[START:    %.3f] \r\n[FINISH:   %.3f]\r\n[DURATION: %.3f]\r\n==================================================",
            self.downloadModel.url,
            self.downloadModel.httpHeaderField,
            self.downloadModel.httpMethod,
            self.startTime,
            self.finishTime,
            self.duration];
}
@end
