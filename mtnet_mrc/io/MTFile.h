//
//  MTFile.h
//  mcf
//
//  Created by Gang.Wang on 12-1-4.
//  Copyright (c) 2012年. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _PathType {
	PathTypeLibrary,
	PathTypeDocument,
	PathTypeResource,
	PathTypeBundle,
	PathTypeTemp,
} PathType;


@interface MTFile : NSObject {
    FILE *mFile;    
}

- (BOOL) openRead: (NSString*) file;
- (BOOL) openWrite: (NSString*) file;

- (BOOL) openAppend: (NSString*) file;
- (void) close;

- (NSString*) readUTF;
- (void) writeUTF: (NSString*) string;

- (int) readInt;
- (void) writeInt: (int) value;

- (float) readFloat;
- (void) writeFloat: (float) value;




+ (NSString*)pathForPathType:(PathType)type;
+ (NSString*)pathOfFile:(NSString*)filename withPathType:(PathType)type;

+ (BOOL)fileExistsAtPath:(NSString*)path;
+ (BOOL)copyFileFromPath:(NSString*)srcPath toPath:(NSString*)dstPath;
+ (BOOL)moveFileFromPath:(NSString*)srcPath toPath:(NSString*)dstPath;

+ (BOOL)deleteFileAtPath:(NSString*)path;
+ (BOOL)createDirectoryAtPath:(NSString *)path withAttributes:(NSDictionary*)attributes;
+ (BOOL)createFileAtPath:(NSString*)path withData:(NSData*)data andAttributes:(NSDictionary*)attr;

+ (NSData*)dataFromPath:(NSString*)path;
+ (NSArray*)contentsOfDirectoryAtPath:(NSString*)path;

+ (unsigned long long int)sizeOfFolderPath:(NSString *)path;
+ (unsigned long long int)sizeOfFilePath:(NSString *)path;

+(void) isDirectory:(NSString *) path isDirectory:(BOOL *)isDirectory;

+ (NSDate *)fileModificationDate:(NSString *)path;
+ (BOOL) fileIsExpired:(NSString*)path tlenByHour:(long long)tlenByHour; // >=
@end
