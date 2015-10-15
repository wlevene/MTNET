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
//  NSData+Extension.m
//  iPhoneLib,
//  Helper Functions and Classes for Ordinary Application Development on iPhone
//
//  Created by meinside on 09. 12. 4.
//
//  last update: 10.07.21.
//

#import "NSData+Extension.h"

#import "Base64Transcoder.h"
#import "MtLogger.h"



#if TARGET_OS_MAC && (TARGET_OS_IPHONE || MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_4)

#define COMMON_DIGEST_FOR_OPENSSL
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

#define HMAC_MD5(key, keylen, data, datalen, md) CCHmac(kCCHmacAlgMD5, key, keylen, data, datalen, md)
#define HMAC_SHA1(key, keylen, data, datalen, md) CCHmac(kCCHmacAlgSHA1, key, keylen, data, datalen, md)
#define HMAC_SHA256(key, keylen, data, datalen, md) CCHmac(kCCHmacAlgSHA256, key, keylen, data, datalen, md)
#define HMAC_SHA512(key, keylen, data, datalen, md) CCHmac(kCCHmacAlgSHA512, key, keylen, data, datalen, md)

static char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
static char decodingTable[128];
static BOOL initialized = NO;

@implementation NSData (NSDataExtension)



- (NSData *)md5HashWithKey:(NSData *)key
{
    unsigned char digest[MD5_DIGEST_LENGTH];

    HMAC_MD5([key bytes], [key length], [self bytes], [self length], digest);

    return [NSData dataWithBytes:&digest length:MD5_DIGEST_LENGTH];
}

- (NSData *)sha1HashWithKey:(NSData *)key
{
    unsigned char digest[SHA_DIGEST_LENGTH];
    
    HMAC_SHA1([key bytes], [key length], [self bytes], [self length], digest);
    
    return [NSData dataWithBytes:&digest length:SHA_DIGEST_LENGTH];
}

- (NSData *)sha256HashWithKey:(NSData *)key
{
    unsigned char digest[SHA256_DIGEST_LENGTH];
    
    HMAC_SHA256([key bytes], [key length], [self bytes], [self length], digest);
    
    return [NSData dataWithBytes:&digest length:SHA256_DIGEST_LENGTH];
}

- (NSData *)sha512HashWithKey:(NSData *)key
{
    unsigned char digest[SHA512_DIGEST_LENGTH];
    
    HMAC_SHA512([key bytes], [key length], [self bytes], [self length], digest);
    
    return [NSData dataWithBytes:&digest length:SHA512_DIGEST_LENGTH];
}

#pragma mark -
#pragma mark AES encrypt/decrypt functions

- (NSData*) aesEncryptWithKey:(NSString *)key initialVector:(NSString*)iv
{
	int keyLength = (int)[key length];
	if(keyLength != kCCKeySizeAES128 && keyLength != kCCKeySizeAES192 && keyLength != kCCKeySizeAES256)
	{
		return nil;
	}
	
	char keyBytes[keyLength + 1];
	bzero(keyBytes, sizeof(keyBytes));
	[key getCString:keyBytes maxLength:sizeof(keyBytes) encoding:NSUTF8StringEncoding];

	size_t numBytesEncrypted = 0;
	size_t encryptedLength = [self length] + kCCBlockSizeAES128;
	char* encryptedBytes = malloc(encryptedLength);
	
	CCCryptorStatus result = CCCrypt(kCCEncrypt, 
									 kCCAlgorithmAES128 , 
									 (iv == nil ? kCCOptionECBMode | kCCOptionPKCS7Padding : kCCOptionPKCS7Padding),	//default: CBC (when initial vector is supplied)
									 keyBytes, 
									 keyLength, 
									 iv,
									 [self bytes], 
									 [self length],
									 encryptedBytes, 
									 encryptedLength,
									 &numBytesEncrypted);

	if(result == kCCSuccess)
		return [NSData dataWithBytesNoCopy:encryptedBytes length:numBytesEncrypted];

	free(encryptedBytes);
	return nil;
}

- (NSData*) aesDecryptWithKey:(NSString *)key initialVector:(NSString*)iv
{
	int keyLength = (int)[key length];
	if(keyLength != kCCKeySizeAES128 && keyLength != kCCKeySizeAES192 && keyLength != kCCKeySizeAES256)
	{
		return nil;
	}

	char keyBytes[keyLength+1];
	bzero(keyBytes, sizeof(keyBytes));
	[key getCString:keyBytes maxLength:sizeof(keyBytes) encoding:NSUTF8StringEncoding];

	size_t numBytesDecrypted = 0;
	size_t decryptedLength = [self length] + kCCBlockSizeAES128;
	char* decryptedBytes = malloc(decryptedLength);
	
	CCCryptorStatus result = CCCrypt(kCCDecrypt, 
									 kCCAlgorithmAES128 , 
									 (iv == nil ? kCCOptionECBMode | kCCOptionPKCS7Padding : kCCOptionPKCS7Padding),	//default: CBC (when initial vector is supplied)
									 keyBytes, 
									 keyLength, 
									 iv,
									 [self bytes], 
									 [self length],
									 decryptedBytes, 
									 decryptedLength,
									 &numBytesDecrypted);

	if(result == kCCSuccess)
		return [NSData dataWithBytesNoCopy:decryptedBytes length:numBytesDecrypted];
	
	free(decryptedBytes);
	return nil;
}

#pragma mark -
#pragma mark Base64 encoding

- (NSString*) base64EncodedString
{
	@try 
	{
		size_t base64EncodedLength = EstimateBas64EncodedDataSize([self length]);
		char base64Encoded[base64EncodedLength];
		if(Base64EncodeData([self bytes], [self length], base64Encoded, &base64EncodedLength))
		{
			NSData* encodedData = [NSData dataWithBytes:base64Encoded length:base64EncodedLength];
			NSString* base64EncodedString = [[NSString alloc] initWithData:encodedData encoding:NSUTF8StringEncoding];
			return [base64EncodedString autorelease];
		}
	}
	@catch (NSException * e)
	{
		//do nothing
	}
	return nil;
}

#pragma mark -
#pragma mark functions for debug purpose

- (NSString*)hexDump
{
    unsigned char *inbuf = (unsigned char *)[self bytes];	
	NSMutableString* stringBuffer = [NSMutableString string];
    for (int i=0; i<[self length]; i++)
    {
        if (i != 0 && i % 16 == 0)
			[stringBuffer appendString:@"\n"];
		[stringBuffer appendFormat:@"0x%02X, ", inbuf[i]];
    }
	return stringBuffer;
}


+ (void)initBase64 {
    memset(decodingTable, 0, (sizeof(decodingTable)/sizeof(*(decodingTable))));
    for (NSInteger i=0; i<(sizeof(encodingTable)/sizeof(*(encodingTable))); i++) {
        decodingTable[encodingTable[i]] = i;
    }
}



+ (NSData *)dataWithBase64EncodedString:(NSString *)encodedString 
{    
    if (!initialized) {
        initialized = YES;
        [self initBase64];
    }

    const char *string = [encodedString cStringUsingEncoding:NSASCIIStringEncoding];
    NSInteger inputLength = encodedString.length;

    if ((string == NULL) || (inputLength % 4 != 0)) {
        return nil;
    }

    while (inputLength > 0 && string[inputLength - 1] == '=') {
        inputLength--;
    }

    NSInteger outputLength = inputLength * 3 / 4;
    NSMutableData *data = [[NSMutableData dataWithLength:outputLength] retain];
    uint8_t *output = data.mutableBytes;

    NSInteger inputPoint = 0;
    NSInteger outputPoint = 0;
    while (inputPoint < inputLength) {
        char i0 = string[inputPoint++];
        char i1 = string[inputPoint++];
        char i2 = inputPoint < inputLength ? string[inputPoint++] : 'A'; /* 'A' will decode to \0 */
        char i3 = inputPoint < inputLength ? string[inputPoint++] : 'A';
        
        output[outputPoint++] = (decodingTable[i0] << 2) | (decodingTable[i1] >> 4);
        if (outputPoint < outputLength) {
            output[outputPoint++] = ((decodingTable[i1] & 0xf) << 4) | (decodingTable[i2] >> 2);
        }
        if (outputPoint < outputLength) {
            output[outputPoint++] = ((decodingTable[i2] & 0x3) << 6) | decodingTable[i3];
        }
    }

    return [data autorelease];
}



+ (NSData *) dataByIntepretingHexString:(NSString *) hexString
{
    if (!hexString ||
        [hexString length] <= 0)
    {
        return nil;
    }
    
    char const *chars = hexString.UTF8String;
    NSUInteger charCount = strlen(chars);
    if (charCount % 2 != 0) {
        return nil;
    }
    NSUInteger byteCount = charCount / 2;
    uint8_t *bytes = malloc(byteCount);
    for (int i = 0; i < byteCount; ++i) {
        unsigned int value;
        sscanf(chars + i * 2, "%2x", &value);
        bytes[i] = value;
    }
    return [NSData dataWithBytesNoCopy:bytes length:byteCount freeWhenDone:YES];

}




@end


#endif