/*
 Copyright (c) 2010, Sungjin Han <meinside@gmail.com>
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:

  * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
  * Neither the name of meinside nor the names of its contributors may be
    used to endorse or promote products derived from this software without
    specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 */
//
//  NSString+Extension.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 10. 11.
//
//  last update: 10.07.21.
//

#import "NSString+Extension.h"

#import "Base64Transcoder.h"
#import "mcfDef.h"
#import "NSDictionary+Extension.h"
#import "NSArray+NSArrayExtension.h"

//#define OPEN_SCALE_IMAGES

#ifdef OPEN_SCALE_IMAGES
#import "ContentFileSystem.h"
#import "HTTPUtil.h"
#endif

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"; 

@implementation NSString (NSStringExtension)


#pragma mark -
#pragma mark MD5 digest function

- (NSString*)md5Digest
{
	const char* cStr = [self UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH] = {
		0,
	};
	CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
	
	return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1], result[2], result[3],
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]];
}

#pragma mark -
#pragma mark Base64 decoding

- (NSData*)base64DecodedBytes
{
	@try
	{
		size_t base64DecodedLength = EstimateBas64DecodedDataSize([self length]);
		char base64Decoded[base64DecodedLength];
		const char* cStringValue = [self UTF8String];
		if(Base64DecodeData(cStringValue, strlen(cStringValue), base64Decoded, &base64DecodedLength))
		{
			NSData* base64DecodedData = [[NSData alloc] initWithBytes:base64Decoded length:base64DecodedLength];
			return [base64DecodedData autorelease];
		}
	}
	@catch (NSException * e)
	{
		//do nothing
	}
	return nil;
}

#pragma mark-
#pragma mark uuid
+ (NSString *) generateUUID
{
    // 存在内存问题
//    The original works with both GC and non-GC, while the version with
//        autorelease will leak under GC (because the string is never
//                                        CFRelease'd). In order to work with both runtimes, either use the
//                                        original, or do this:

//    CFUUIDRef uuid = CFUUIDCreate(NULL);
//    NSString* retuid = (NSString *)CFUUIDCreateString(NULL, uuid);
//    CFRelease(uuid);
//    return [retuid autorelease];
    
    // 这个不存在内存问题
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    
    
    NSString * result = [[NSString alloc] initWithString:(NSString *)uuidStringRef];
    CFRelease(uuidStringRef);
    return [result autorelease];
}

-(BOOL) isIncludeSubString:(NSString *) subString
{
    NSRange foundObj=[self rangeOfString:subString options:NSCaseInsensitiveSearch];
    if(foundObj.length>0) {
        return TRUE;
    } else {
        return FALSE;
    }
}


+ (BOOL) isNilOrEmpty:(NSString *) str
{
    if(!str)
    {
        return TRUE;
    }
    
    if (str &&
        [str isKindOfClass:[NSString class]])
    {
        if([str length] <= 0)
        {
            return TRUE;
        }
        
        if ([str isEqualToString:@"(null)"])
        {
            return TRUE;
        }
        
        if ([str isEqualToString:@"<nil>"]) {
            return TRUE;
        }
    }
    
    return FALSE;
}


- (BOOL)endswith:(NSString *)endswith
{
    return [self hasSuffix:endswith];
}

- (BOOL)startswith:(NSString *)startswith
{    
    return [self hasPrefix:startswith];
}


- (NSString *)replace:(NSString *)searchString with:(NSString *)repalceString{
    
    if ([NSString isNilOrEmpty:searchString])
        return self;
    if ([NSString isNilOrEmpty:repalceString])
        repalceString = @"";
    return [self stringByReplacingOccurrencesOfString:searchString withString:repalceString];
}

- (NSArray *)split:(NSString *)splitString{
    @try {
        return [self componentsSeparatedByString:splitString];
    }
    @catch (NSException *exception) {
        return nil;
    }
}

- (NSArray *)split
{
    NSArray * result = [self split:@";"];
    if (result && 
        [result count] > 1) {
        return result;
    }
    
    result = [self split:@" "];
    if (result && 
        [result count] > 1) {
        return result;
    }
    
    result = [self split:@"-"];
    if (result && 
        [result count] > 1) {
        return result;
    }
    
    result = [self split:@","];
    if (result && 
        [result count] > 1) {
        return result;
    }
    
    result = [self split:@"."];
    if (result &&
        [result count] > 1) {
        return result;
    }
    
    result = [self split:@"_"];
    if (result &&
        [result count] > 1) {
        return result;
    }
    
    return result;
}

- (NSString *) trim
{
    return [self strip];
}

- (NSString *)strip{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)upper{
    return [self uppercaseString];
}

- (BOOL)isupper
{
    return [self isEqualToString:[self upper]];
}

- (NSString *)lower{
    return [self lowercaseString];
}


- (NSString*)encodeAsURIComponent
{
	const char* p = [self UTF8String];
	NSMutableString* result = [NSMutableString string];
	
	for (;*p ;p++) {
		unsigned char c = *p;
		if (('0' <= c && c <= '9') || ('a' <= c && c <= 'z') || ('A' <= c && c <= 'Z') || c == '-' || c == '_') {
			[result appendFormat:@"%c", c];
		} else {
			[result appendFormat:@"%%%02X", c];
		}
	}
	return result;
}

+ (NSString*)base64encode:(NSString*)str 
{
    if ([str length] == 0)
        return @"";
    
    const char *source = [str UTF8String];
    int strlength  = (int)strlen(source);
    
    char *characters = malloc(((strlength + 2) / 3) * 4);
    if (characters == NULL)
        return nil;
    
    NSUInteger length = 0;
    NSUInteger i = 0;
    
    while (i < strlength) {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < strlength)
            buffer[bufferLength++] = source[i++];
        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = encodingTable[buffer[2] & 0x3F];
        else characters[length++] = '=';
    }
    
    return [[[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES] autorelease];
}

- (NSString*)escapeHTML
{
	NSMutableString* s = [NSMutableString string];
	
	int start = 0;
	int len = (int)[self length];
	NSCharacterSet* chs = [NSCharacterSet characterSetWithCharactersInString:@"<>&\""];
	
	while (start < len) {
		NSRange r = [self rangeOfCharacterFromSet:chs options:0 range:NSMakeRange(start, len-start)];
		if (r.location == NSNotFound) {
			[s appendString:[self substringFromIndex:start]];
			break;
		}
		
		if (start < r.location) {
			[s appendString:[self substringWithRange:NSMakeRange(start, r.location-start)]];
		}
		
		switch ([self characterAtIndex:r.location]) {
			case '<':
				[s appendString:@"&lt;"];
				break;
			case '>':
				[s appendString:@"&gt;"];
				break;
			case '"':
				[s appendString:@"&quot;"];
				break;
			case '&':
				[s appendString:@"&amp;"];
				break;
		}
		
		start = (int)r.location + 1;
	}
	
	return s;
}

- (NSString*)unescapeHTML
{
	NSMutableString* s = [NSMutableString string];
	NSMutableString* target = [[self mutableCopy] autorelease];
	NSCharacterSet* chs = [NSCharacterSet characterSetWithCharactersInString:@"&"];
	
	while ([target length] > 0) {
		NSRange r = [target rangeOfCharacterFromSet:chs];
		if (r.location == NSNotFound) {
			[s appendString:target];
			break;
		}
		
		if (r.location > 0) {
			[s appendString:[target substringToIndex:r.location]];
			[target deleteCharactersInRange:NSMakeRange(0, r.location)];
		}
		
		if ([target hasPrefix:@"&lt;"]) {
			[s appendString:@"<"];
			[target deleteCharactersInRange:NSMakeRange(0, 4)];
		} else if ([target hasPrefix:@"&gt;"]) {
			[s appendString:@">"];
			[target deleteCharactersInRange:NSMakeRange(0, 4)];
		} else if ([target hasPrefix:@"&quot;"]) {
			[s appendString:@"\""];
			[target deleteCharactersInRange:NSMakeRange(0, 6)];
		} else if ([target hasPrefix:@"&amp;"]) {
			[s appendString:@"&"];
			[target deleteCharactersInRange:NSMakeRange(0, 5)];
		} else {
			[s appendString:@"&"];
			[target deleteCharactersInRange:NSMakeRange(0, 1)];
		}
	}
	
	return s;
}

+ (NSString*)localizedString:(NSString*)key
{
	return [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:key];
}


+(id) stringWithDataByGBK:(NSData *) data
{
    NSString * string = [NSString string];// [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
    return [string gbkStringByData:data];
}
+(id) stringWithDataByUTF8:(NSData *) data
{
    NSString * string = [NSString string];// [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    return [string utf8StringByData: data];
}




- (NSData *) dataUsingASCIIEncoding
{
    return [self dataUsingEncoding:NSASCIIStringEncoding];
}

- (NSData *) dataUsingUTF8
{
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}


- (NSString *) gbkStringByData:(NSData *) data
{
    unsigned long encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000); 
    NSString *str = [[NSString alloc] initWithData:data encoding:encode]; 
    return [str autorelease];
}

- (NSString*) utf8StringByData:(NSData*) data {
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [str autorelease];
}

- (NSString *) gbkString
{
    NSData * data = [self dataUsingASCIIEncoding];
    return [self gbkStringByData:data];
}



@end
