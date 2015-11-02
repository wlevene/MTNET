//
//  MTPath.h
//
//  Created by Gang.Wang on 11-10-14.
//  Copyright 2011年. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTPath : NSObject {
    
}



+(NSString*) kDocuments;
+(NSString*) kTmp;
+(NSString*) kLibrary;
+(NSString*) kLibraryCaches;
+(NSString*) kResource;



+ (BOOL) createDirectory:(NSString *)path 
          withAttributes:(NSDictionary*)attributes; 

+ (unsigned long long int)sizeOfFolderPath:(NSString *)path;

+ (void) removeDirectory:(NSString *) path;

+ (void) removeDirectoryIncludeSubDirectory: (NSString *) path 
                              includeSubDir:(BOOL) b_include;

/**
 * @brief:  用来拼接两个路径段，处理了路径之前的斜杠操作，使用时不再关心路径之间的斜杠处理
 * @param:  path1 & path2 指定两个路径段
 * @return: 拼接完成后的路径
 * @note:   
 */
+ (NSString *) Combine:(NSString *) path1 combinePath:(NSString *) path2;

/**
 * @brief:  返回一个路径文件的文件名
 * @param:  path 指定的一个路径
 * @return: 返回指定路径文件的文件名
 */
+ (NSString *) fileName:(NSString *) path;

/**
 * @brief:  返回一个路径文件的扩展名
 * @param:  path 指定的一个路径
 * @return: 返回指定路径文件的扩展名
 */
+ (NSString *) extensionName:(NSString *) path;

/**
 * @brief:  重命名文件名称
 * @param:  sourcePath 需要rename的路径
 * @param:  targetPath 命名后的新名称
 * @return: 成功返回 YES, 反之 NO
 * @note:   两个名称必须是全路径名称
 */
+ (BOOL) rename:(NSString *) sourcePath target:(NSString *) targetPath;
@end
