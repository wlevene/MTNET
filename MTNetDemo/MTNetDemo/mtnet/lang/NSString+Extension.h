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
//  NSString+Extension.h
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 10. 11.
//
//  last update: 10.07.21.
//

#pragma once
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>
#import <UIKit/UIKit.h>

@interface NSString (NSStringExtension)

- (NSString*)encodeAsURIComponent;
- (NSString*)escapeHTML;
- (NSString*)unescapeHTML;
+ (NSString*)localizedString:(NSString*)key;
+ (NSString*)base64encode:(NSString*)str;

/**
 * returns MD5 digest value of this string
 */
- (NSString*)md5Digest;

/**
 * returns Base64 decoded bytes
 */
- (NSData*)base64DecodedBytes;

/**
 * create uuid
 */
+ (NSString *) generateUUID;

-(BOOL) isIncludeSubString:(NSString *) subString;

+ (BOOL) isNilOrEmpty:(NSString *) str;

- (BOOL)endswith:(NSString *)endswith;

- (BOOL)startswith:(NSString *)startswith;

- (NSString *)replace:(NSString *)searchString with:(NSString *)repalceString;

- (NSArray *)split:(NSString *)splitString;

- (NSArray *)split;

- (NSString *)strip;

- (NSString *) trim;

- (NSString *)upper;

- (NSString *)lower;

- (BOOL)isupper;

+(id) stringWithDataByGBK:(NSData *) data;
+(id) stringWithDataByUTF8:(NSData *) data;


- (NSData *) dataUsingASCIIEncoding;

- (NSData *) dataUsingUTF8;

- (NSString*) gbkString;
- (NSString*) gbkStringByData:(NSData *) data;
- (NSString*) utf8StringByData:(NSData*) data;



@end
