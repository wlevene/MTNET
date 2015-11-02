//
//  MTFile.m
//  mcf
//
//  Created by Gang.Wang on 12-1-4.
//  Copyright (c) 2012年. All rights reserved.
//

#import "MTFile.h"

@implementation MTFile

#pragma mark
#pragma c file function
- (MTFile*) init {
    self = [super init];
    if (self)
    {
        mFile = NULL;
    }
    
    return self;
}

- (BOOL) openRead: (NSString*) file {
    [self close];
    mFile = fopen([file fileSystemRepresentation], "rb");
    
    return mFile != NULL;
}

- (BOOL) openWrite: (NSString*) file {
    [self close];
    mFile = fopen([file fileSystemRepresentation], "wb");    
    
    return mFile != NULL;
}

- (BOOL) openAppend: (NSString*) file {
    [self close];
    mFile = fopen([file fileSystemRepresentation], "ab");
    
    return mFile != NULL;
}

- (void) close {
    if (mFile != NULL) {
        fclose(mFile);
        mFile = NULL;
    }
}

- (void)dealloc {
    [self close];
    [super dealloc];
}

- (NSString*) readUTF {
    int length = 0;
    fread(&length, 2, 1, mFile); //Java's writeUTF writes length in 2 bytes only
    
    char *buff = malloc(length + 1); //Extra byte for '\0'
    fread(buff, 1, length, mFile);
    buff[length] = '\0';
    
    NSString *string = [NSString stringWithUTF8String: buff];
    
    free(buff);
    
    return string;
}

- (void) writeUTF: (NSString*) string {
    const char *utf = [string UTF8String];
    int length = (int)strlen(utf);
    
    fwrite(&length, 2, 1, mFile); //Java's writeUTF writes length in 2 bytes only
    fwrite(utf, 1, length, mFile); //Write UTF-8 bytes
}

- (int) readInt {
    int i;
    
    fread(&i, sizeof(int), 1, mFile);
    
    return i;
}

- (void) writeInt: (int) value {
    fwrite(&value, sizeof(int), 1, mFile);
}

- (float) readFloat {
    float f;
    
    fread(&f, sizeof(float), 1, mFile);
    
    return f;
}

- (void) writeFloat: (float) value {
    fwrite(&value, sizeof(float), 1, mFile);
}


#pragma mark -
#pragma mark file-related functions


+(void) isDirectory:(NSString *) path isDirectory:(BOOL *)isDirectory
{
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:isDirectory];
}

+ (NSString*)pathForPathType:(PathType)type
{
	NSSearchPathDirectory directory;
	switch(type)
	{
		case PathTypeDocument:
			directory = NSDocumentDirectory;
			break;
		case PathTypeLibrary:
			directory = NSLibraryDirectory;
			break;
		case PathTypeBundle:
			return [[NSBundle mainBundle] bundlePath];
			break;
		case PathTypeResource:
			return [[NSBundle mainBundle] resourcePath];
			break;
		case PathTypeTemp:
			return NSTemporaryDirectory();
			break;
		default:
			return nil;
	}
    assert(false);
    //NSSearchPathForDirectoriesInDomains 很耗费时间
	NSArray* directories = NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES);
	if(directories != nil && [directories count] > 0)
		return [directories objectAtIndex:0];
	return nil;
}

+ (NSString*)pathOfFile:(NSString*)filename withPathType:(PathType)type
{
	return [[self pathForPathType:type] stringByAppendingPathComponent:filename];
}

+ (BOOL)fileExistsAtPath:(NSString*)path
{
	return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (BOOL)copyFileFromPath:(NSString*)srcPath toPath:(NSString*)dstPath
{
    if (![self fileExistsAtPath:srcPath])
        return NO;
    
	NSError* error = nil;
	BOOL ret = [[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:dstPath error:&error];
    if (!ret) {
        NSDictionary* userInfo = [error userInfo];
        NSEnumerator* enumx = [userInfo keyEnumerator];
        for (NSString* key in enumx) {
            NSString* value = [userInfo valueForKey:key];
#pragma unused(value)
        }
        
        // 再次尝试
        if ([self createDirectoryAtPath:[dstPath stringByDeletingLastPathComponent] withAttributes:nil]) {
            ret = [[NSFileManager defaultManager] copyItemAtPath:srcPath toPath:dstPath error:&error];
        }
    }
    return ret;
}

+ (BOOL)moveFileFromPath:(NSString*)srcPath toPath:(NSString*)dstPath
{
	NSError* error = nil;
	BOOL ret = [[NSFileManager defaultManager] moveItemAtPath:srcPath toPath:dstPath error:&error];
    if (!ret) {
        NSDictionary* userInfo = [error userInfo];
        NSEnumerator* enumx = [userInfo keyEnumerator];
        for (NSString* key in enumx) {
            NSString* value = [userInfo valueForKey:key];
//            DebugLog(@"[moveItemAtPath] %@: %@", key, value);
#pragma unused(value)
        }
    }
    return ret;
}

+ (BOOL)deleteFileAtPath:(NSString*)path
{
    if(![MTFile fileExistsAtPath:path])
    {
        return YES;
    }
    
	NSError* error = nil;
	return [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
}

+ (BOOL)createDirectoryAtPath:(NSString *)path withAttributes:(NSDictionary*)attributes
{
	NSError* error = nil;
	return [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:attributes error:&error];
}


+ (BOOL)createFileAtPath:(NSString*)path withData:(NSData*)data andAttributes:(NSDictionary*)attr
{
	return [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:attr];
}

+ (NSData*)dataFromPath:(NSString *)path
{
	return [[NSFileManager defaultManager] contentsAtPath:path];
}

+ (NSArray*)contentsOfDirectoryAtPath:(NSString*)path
{
	NSError* error = nil;
	return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
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
+ (unsigned long long int)sizeOfFilePath:(NSString *)path
{
    NSFileManager* mgr = [NSFileManager defaultManager];
    NSDictionary* dict = [mgr attributesOfItemAtPath:path error:nil];
    return [dict fileSize];
}

+ (NSDate *)fileModificationDate:(NSString *)path {
    NSFileManager* mgr = [NSFileManager defaultManager];
    NSDictionary* dict = [mgr attributesOfItemAtPath:path error:nil];
    return [dict fileModificationDate];
}

+ (BOOL) fileIsExpired:(NSString*)localPath tlenByHour:(long long)tlenByHour { // >=
    
    // 是否须要下载
    BOOL needownload = false;
    if ([self fileExistsAtPath: localPath]) {
        NSTimeInterval modify = [self fileModificationDate:localPath].timeIntervalSince1970;
        NSTimeInterval current = [[NSDate date] timeIntervalSince1970];
        NSInteger result = current - modify;
        if (result >= tlenByHour * 60*60) {// 本地存在，并且过期了，已经。
            needownload = true;
        }
    } else {
        needownload = true;
    }
    return needownload;
}
@end
