//
//  mcfDef.h
//
//  Created by Gang.Wang on 12-10-20.
//  Copyright (c) 2012年. All rights reserved.
//

#ifndef mcfDef_h
#define mcfDef_h


#define MTRelease(obj)               [obj release]; obj = nil;
#define MTLocalizedString(s)         NSLocalizedString(s,nil)

#define CLASSNAME(cls)       [[cls class] description]

/*
 本地路径宏定义
 */
#define kDocuments           [MTPath kDocuments]
#define kTmp                 [MTPath kTmp]
#define kLibrary             [MTPath kLibrary]
#define kLibraryCaches       [MTPath kLibraryCaches]
#define kResource            [MTPath kResource]


#define kCache                    [kLibraryCaches stringByAppendingPathComponent:@"matiaCache"]
#define kDownloadTempPath         [kCache stringByAppendingPathComponent:@"cache/download"]


#define DELEGATE_CALLBACK(X, Y) if (self.delegate && [((NSObject*)self.delegate) respondsToSelector:@selector(X)]) [((NSObject*)self.delegate) performSelector:@selector(X) withObject:Y];

#define NUMBER(X) [NSNumber numberWithFloat:X]


#define DEF_didReceiveMemoryWarning DebugLog(@"======== didReceiveMemoryWarning ========"); \
    DebugLog(@"getAvailableMegaBytes is: %f", [MTSystem getAvailableMegaBytes]);
#define SUPER_didReceiveMemoryWarning [super didReceiveMemoryWarning]


#define kMustOverrideMethod  [NSException raise:NSInternalInconsistencyException format:@"You must override Method:%@ in a subclass With Super Class:%@", NSStringFromSelector(_cmd), [[self class] description]];



#endif
