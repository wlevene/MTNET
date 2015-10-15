//
//  ViewController.m
//  MTNetDemo
//
//  Created by Gang.Wang on 10/15/15.
//  Copyright © 2015 Gang.Wang. All rights reserved.
//

#import "ViewController.h"

#import "MTDownloaderHelper.h"
#import "MTDownloadObjectModel.h"
#import "MTDownloadRequest.h"
#import "MTDownloadRecvData.h"
#import "AppImageDowloadRecv.h"

@interface ViewController ()<MTDownloadRequestDelegate>

@property (nonatomic, strong) MTDownloaderHelper * downloadHelper;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.downloadHelper = [[MTDownloaderHelper alloc] init];
    
    [self.downloadHelper setTimeout:20];
    [self.downloadHelper setMaxConcurrentTaskCount:5];
    
    
    
}


- (void) download1
{
    MTDownloadRequest * request = [[MTDownloadRequest alloc] init];
    MTDownloadObjectModel * downloadMdel = [[MTDownloadObjectModel alloc] init];
    downloadMdel.url = @"http://www.baidu.com";
    request.downloadModel = downloadMdel;
    
    request.delegate  = self;
    
    [self.downloadHelper addDownloadRequest:request];
    
    
    // cancel download
    // [self.downloadHelper cancelDownloadRequestByName:request.name];
}


- (void) download2
{
    MTDownloadRequest * request = [[MTDownloadRequest alloc] init];
    
    MTDownloadObjectModel * downloadMdel = [[MTDownloadObjectModel alloc] init];
    downloadMdel.url = @"http://www.baidu.com";
    request.downloadModel = downloadMdel;
    
    AppImageDowloadRecv * recvData = [[AppImageDowloadRecv alloc] init];
    [recvData setFileName:@"filename"];
    request.recvData = recvData;
    
    request.delegate  = self;
    
    [self.downloadHelper addDownloadRequest:request];
    
    // cancel download
    // [self.downloadHelper cancelDownloadRequestByName:request.name];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - MTDownloadRequestDelegate

- (void) didTaskReceiveDataFinish   : (NSData *) theData    request:(MTDownloadRequest*) request
{
    NSLog(@"download ok");
}

- (void) taskDataDownloadFailed     : (NSError *) error     request:(MTDownloadRequest*) request
{
    NSLog(@"download failed:%@", error);
}

- (void) taskDataDownloadAtPercent  : (NSNumber *) aPercent request:(MTDownloadRequest*) request
{
    
}

- (void) taskDataPostAtPercent      : (NSNumber *) aPercent request:(MTDownloadRequest *) request
{
    
}

- (void) didTaskReceiveFilename     : (NSString *) aName    request:(MTDownloadRequest*) request
{
    
}

@end
