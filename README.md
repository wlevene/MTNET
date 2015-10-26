

	┌──┐┌──┐┌──┐┌──┐┌──┐
	││││└┐┌┘│┌┐││ ─┤└┐┌┘
	││││ ││ │││││ ─┤ ││　
	└┴┴┘ └┘ └┘└┘└──┘ └┘　
　　　　　　　　　　　　　　　　
# MTNET

MTNET是一个十分轻量、功能强大的ios的http网络库，用来处理有大量很频繁发起http请求的场景，在已上架的数歀app使用中表现良好稳定。 

其它的网络库上手容易，但要处理比较密集和较大文件下载时就显得比较麻烦。

使用下载池管理所有网络下载，可设置同时下载的请求数，针对单个请求可以中止和取消，提供两种数据接收方式：内存接收和磁盘接收。 

磁盘接收数据会将接收到的数据小块小块的写入磁盘，避免了如果下载文件比较大时造成的内存吃紧

开发者可继承MTDownloadRecvDataFileSystem类，灵活指定下载文件的存储路径和存储文件名，并提供文件是否缓存和获取缓存文件的方法


***MTNET是MRC版本***

# ToDo
- 有很多同学反馈需要支持arc版本， 会尽快支持


# 使用
引入头文件

```objectivec
#import "MTDownloaderHelper.h"
#import "MTDownloadObjectModel.h"
#import "MTDownloadRequest.h"
#import "MTDownloadRecvData.h"	
```

声明下载池

```objectivec
@property (nonatomic, strong) MTDownloaderHelper * downloadHelper;

	...
	
self.downloadHelper = [[MTDownloaderHelper alloc] init];	
```

设置下载池同时最多可执行的任务数

```objectivec
[self.downloadHelper setMaxConcurrentTaskCount:5];
```

可给下载池中所有链接指定同一个下载超时的设置

```objectivec
[self.downloadHelper setTimeout:20];
```

向下载池中投入一个下载请求

```objectivec
MTDownloadRequest * request = [[MTDownloadRequest alloc] init];
MTDownloadObjectModel * downloadMdel = [[MTDownloadObjectModel alloc] init];
downloadMdel.url = @"http://www.baidu.com";
request.downloadModel = downloadMdel;
    
request.delegate  = self;
    
[self.downloadHelper addDownloadRequest:request];
```

取消一个下载请求，如此下载请求还未开始下载就从下载队列中移除。如已开始下开就中止当前下载

```objectivec
[self.downloadHelper cancelDownloadRequestByName:request.name];
```

使用`MTDownloadRequestDelegate` 获取下载结果

```objectivec
- (void) didTaskReceiveDataFinish   : (NSData *) theData    request:(MTDownloadRequest*) request
{
    NSLog(@"download ok");
}

- (void) taskDataDownloadFailed     : (NSError *) error     request:(MTDownloadRequest*) request
{
    NSLog(@"download failed:%@", error);
}
```



###自定义接收下载规则
可以继承`MTDownloadRecvDataFileSystem`自己制定下载规则，在此类中还提供了`processRecvAllDataFinish` 和 `processRecvAllDataFalied`这两个方法，重写就可以自定义处理当下载数据出错或者成功后的操作

比如 下载数据出错后需要清理缓存，下载成功后需要对文件进行解压、压缩、图片缩放等


```objectivec
#import "MTDownloadRecvData.h"

@interface AppImageDowloadRecv : MTDownloadRecvDataFileSystem

- (void) setFileName:(NSString *) fileName;

@end



#import "AppImageDowloadRecv.h"
#import "MTPath.h"
#import "MTFile.h"
#import "NSString+Extension.h"
#import "mcfDef.h"

@implementation AppImageDowloadRecv

- (id) init
{
    self = [super init];
    if(self)
    {
        self.localCacheDirPath = [MTPath Combine:kCache combinePath:@"appdata"];
        static BOOL created = FALSE;
        if (!created) {
            created = TRUE;
            [MTPath createDirectory:self.localCacheDirPath withAttributes:nil];
        }
    }
    
    return self;
}

- (void) setFileName:(NSString *) fileName
{
    if ([NSString isNilOrEmpty:fileName])
    {
        return;
    }
    
    self.name = fileName;
    self.localFullPath = [MTPath Combine:self.localCacheDirPath combinePath:fileName];
}

- (BOOL) bCached
{
    return [MTFile fileExistsAtPath:self.localFullPath];
}

- (NSData *) data
{
    if ([self bCached])
    {
        return [NSData dataWithContentsOfFile:self.localFullPath];
    }
    
    return nil;
}

@end

```



向下载池中投入一个自己定义下载规则的请求

```objectivec
MTDownloadRequest * request = [[MTDownloadRequest alloc] init];
    
MTDownloadObjectModel * downloadMdel = [[MTDownloadObjectModel alloc] init];
downloadMdel.url = @"http://www.baidu.com";
request.downloadModel = downloadMdel;
    
AppImageDowloadRecv * recvData = [[AppImageDowloadRecv alloc] init];
[recvData setFileName:@"filename"];
request.recvData = recvData;
    
request.delegate  = self;
    
[self.downloadHelper addDownloadRequest:request];
```



---
If you like this project, give a start ；）

