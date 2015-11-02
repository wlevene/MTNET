//
//  YSchemeUrlParse.m
//  mcf
//
//  Created by Gang.Wang on 13-8-5.
//  Copyright (c) 2013年 yuike. All rights reserved.
//

#import "MTSchemeUrlParse.h"
#import "mcfDef.h"
#import "NSString+Extension.h"
#import "NSArray+NSArrayExtension.h"
#import "NSDictionary+Extension.h"
@interface MTSchemeUrlParse ()

@property (nonatomic, retain) NSURL * schemeUrl;
@property (nonatomic, retain) NSMutableDictionary * paramDic;

@end

@implementation MTSchemeUrlParse

- (id) initWithString:(NSString *)string
{
    if ([NSString isNilOrEmpty:string])
    {
        return nil;
    }
    
    self = [super init];
    if (self)
    {
        self.schemeUrl = [NSURL URLWithString:string];
    }
    
    return self;
}

- (id) initWithUrl:(NSURL *) url
{
    if (!url)
    {
        return nil;
    }
    
    self = [super init];
    if (self)
    {
        self.schemeUrl = url;
    }
    
    return self;
}

- (void) setSchemeUrl:(NSURL *)schemeUrl
{
    MTRelease(_schemeUrl);
    _schemeUrl = [schemeUrl retain];
    
    MTRelease(_scheme);
    _scheme = [[self.schemeUrl scheme] copy];
    
    MTRelease(_doma);
    _doma = [[self.schemeUrl host] copy];
    
    MTRelease(_query);
    _query = [[self.schemeUrl query] copy];
    
    MTRelease(_resourceSpecifier);
    _resourceSpecifier = [[self.schemeUrl resourceSpecifier] copy];
    
    
    self.paramDic = [NSMutableDictionary dictionary];
    NSMutableArray * mutableParams = [NSMutableArray array];
    
    NSArray * theArray = [self.query split:@"&"];
    if (![NSArray isNilOrEmpty:theArray])
    {
        for (NSString * item in theArray)
        {
            if ([NSString isNilOrEmpty:item] ||
                ![item isIncludeSubString:@"="])
            {
                continue;
            }
            
            NSRange r = [item rangeOfString:@"="];
            if (r.location >= [item length] ||
                r.length != 1)
            {
                continue;
            }
            
            NSString * param = [item substringToIndex:r.location];
            NSString * value = [item substringFromIndex:r.location + r.length];
            
            if ([NSString isNilOrEmpty:param] ||
                [NSString isNilOrEmpty:value])
            {
                continue;
            }
            
            [mutableParams addObject:param];
            [self.paramDic setObject:value forKey:param];
        }
    }
    
    MTRelease(_params);
    _params = [[NSArray alloc] initWithArray:mutableParams];
}

- (NSString *) valueForParam:(NSString *) param
{
    if ([NSString isNilOrEmpty:param])
    {
        return nil;
    }
    
    return [self.paramDic objectForKeySafe:param];
}



@end
