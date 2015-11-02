//
//  MTPath.m
//
//  Created by Gang.Wang on 11-10-14.
//  Copyright 2011年. All rights reserved.
//

#import "MTPath.h"
#import "MTFile.h"

@implementation MTPath


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}


static NSString* g_kDocuments = nil;
+(NSString*) kDocuments{
    if (g_kDocuments == nil) {
        
        @synchronized(self){if (g_kDocuments == nil) {
            g_kDocuments = [MTPath Combine:NSHomeDirectory() combinePath:@"Documents"];
           
        }}
    }
    return g_kDocuments;
}


static NSString* g_kTmp = nil;
+(NSString*) kTmp{
    if (g_kTmp == nil) {
        
        @synchronized(self){if (g_kTmp == nil) {
            g_kTmp = [MTPath Combine:NSHomeDirectory() combinePath:@"tmp"];
           
        }}
    }
    return g_kTmp;
}


static NSString* g_kLibrary = nil;
+(NSString*) kLibrary{
    if (g_kLibrary == nil) {
        
        @synchronized(self){if (g_kLibrary == nil) {
            g_kLibrary = [MTPath Combine:NSHomeDirectory() combinePath:@"Library"];
            
        }}
    }
    return g_kLibrary;
}


static NSString* g_kLibraryCaches = nil;
+(NSString*) kLibraryCaches{
    if (g_kLibraryCaches == nil) {
        
        @synchronized(self) {if (g_kLibraryCaches == nil) {
            g_kLibraryCaches = [MTPath Combine:[self kLibrary] combinePath:@"Caches"];
           
        }}
    }
    return g_kLibraryCaches;
    
}


static NSString* g_kResource = nil;
+(NSString*) kResource{
    if (g_kResource == nil) {
        
        @synchronized(self){if (g_kResource == nil) {
            g_kResource = [[NSBundle mainBundle] resourcePath];
           
        }}
    }
    return g_kResource;
}



+ (BOOL)createDirectory:(NSString *)path withAttributes:(NSDictionary*)attributes
{
	NSError* error = nil;
	return [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:attributes error:&error];
}

//referenced: http://stackoverflow.com/questions/2188469/calculate-the-size-of-a-folder
+ (unsigned long long int)sizeOfFolderPath:(NSString *)path
{
    unsigned long long int totalSize = 0;
    
	NSEnumerator* enumerator = [[[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:nil] objectEnumerator];	
    NSString* fileName;
    while((fileName = [enumerator nextObject]))
	{
		totalSize += [[[NSFileManager defaultManager] attributesOfItemAtPath:[path stringByAppendingPathComponent:fileName] error:nil] fileSize];
    }
	
    return totalSize;	
}

+ (void) removeDirectoryIncludeSubDirectory: (NSString *) dir_path 
                              includeSubDir:(BOOL) b_include
{
    NSEnumerator* enumerator = [[[NSFileManager defaultManager] subpathsOfDirectoryAtPath:dir_path error:nil] objectEnumerator];	
    NSString* fileName;
    while((fileName = [enumerator nextObject]))
	{
//		NSString * fileFullPath = [dir_path stringByAppendingPathComponent:fileName];
 
    }
    
}

+ (void) removeDirectory:(NSString *) path
{
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

/**
 * @brief:  用来拼接两个路径段，处理了路径之前的斜杠操作，使用时不再关心路径之间的斜杠处理
 * @param:  path1 & path2 指定两个路径段
 * @return: 拼接完成后的路径
 * @note:
 */
+ (NSString *) Combine:(NSString *) path1 combinePath:(NSString *) path2
{
    return [path1 stringByAppendingPathComponent:path2];
}


/**
 * @brief:  返回一个路径文件的文件名
 * @param:  path 指定的一个路径
 * @return: 返回指定路径文件的文件名
 */
+ (NSString *) fileName:(NSString *) path
{
    return [path lastPathComponent];
}

/**
 * @brief:  返回一个路径文件的扩展名
 * @param:  path 指定的一个路径
 * @return: 返回指定路径文件的扩展名
 */
+ (NSString *) extensionName:(NSString *) path
{
    return [path pathExtension];
}

/**
 * @brief:  重命名文件名称
 * @param:  sourcePath 需要rename的路径
 * @param:  targetPath 命名后的新名称
 * @return: 成功返回 YES, 反之 NO
 * @note:   两个名称必须是全路径名称
 */
+ (BOOL) rename:(NSString *) sourcePath target:(NSString *) targetPath
{
    if (!sourcePath ||
        !targetPath)
    {
        return FALSE;
    }
    
    return [[NSFileManager defaultManager] moveItemAtPath:sourcePath toPath:targetPath error:nil];
}
@end
