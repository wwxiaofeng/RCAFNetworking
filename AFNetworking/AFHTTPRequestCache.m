//
//  AFURLCache.m
//  CurlHTTP
//
//  Created by yangxf on 15/7/29.
//  Copyright (c) 2015年 yangxf. All rights reserved.
//

#import "AFHTTPRequestCache.h"
#import <CommonCrypto/CommonDigest.h>

@implementation AFHTTPRequestCache

- (id)initWithUrl:(NSString*)url
   responseObject:(NSDictionary*)responseObject
   expirationDate:(NSDate*)expirationDate
{
    if (self = [super init]) {
        
        _url = url;
        _responseObject = responseObject;
        _expirationDate = expirationDate;
        
        return self;
    }
    
    return nil;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    _url = [aDecoder decodeObjectForKey:@"url"];
    _responseObject = [aDecoder decodeObjectForKey:@"responseObject"];
    _expirationDate = [aDecoder decodeObjectForKey:@"expirationDate"];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_url forKey:@"url"];
    [aCoder encodeObject:_responseObject forKey:@"responseObject"];
    [aCoder encodeObject:_expirationDate forKey:@"expirationDate"];
}

+ (void)saveCacheWithURL:(NSString*)url
      expirationInterval:(NSTimeInterval)expirationInterval
          responseObject:(NSDictionary*)responseObject
{
    if (expirationInterval <= 0) {
        return;
    }
    
    NSDate* expirationDate = [[NSDate date] dateByAddingTimeInterval:expirationInterval];
    
    AFHTTPRequestCache* cache = [[AFHTTPRequestCache alloc] initWithUrl:url
                                                         responseObject:responseObject
                                                         expirationDate:expirationDate];
    
    NSData* archiveCache = [NSKeyedArchiver archivedDataWithRootObject:cache];
    
    NSString* cacheFilePath = [[self class] getCacheFilePathWithURL:url];
    
    if ([archiveCache writeToFile:cacheFilePath atomically:YES]) {
        
    }
    
}

+ (AFHTTPRequestCache*)getCacheWithURL:(NSString*)url
{
    NSString* cachesFilePath = [self getCacheFilePathWithURL:url];
    NSData* cachedUrlData = [NSData dataWithContentsOfFile:cachesFilePath];
    
    if (cachedUrlData) {
        
        AFHTTPRequestCache* cache = [NSKeyedUnarchiver unarchiveObjectWithData:cachedUrlData];
        
        if ([cache.expirationDate compare:[NSDate date]] == NSOrderedAscending) {
            [[NSFileManager defaultManager] removeItemAtPath:cachesFilePath error:nil];
            return nil;
        }
        
        return cache;
    }
    
    return nil;
}

+ (NSString*)getCacheFilePathWithURL:(NSString*)url
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* curlCachesDir = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"com.yangxf.http"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:curlCachesDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:curlCachesDir
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    
    NSString* cachesFilePath = [curlCachesDir stringByAppendingPathComponent:[self encodeStringMd5:url]];
    return cachesFilePath;
}

+ (NSString*)encodeStringMd5:(NSString *)string
{
    if( self == nil || string.length == 0 )
        return nil;
    
    const char *value = [string UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (uint)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}


@end
