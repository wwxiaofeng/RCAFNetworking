//
//  AFURLCache.m
//  CurlHTTP
//
//  Created by yangxf on 15/7/29.
//  Copyright (c) 2015年 yangxf. All rights reserved.
//

#import "AFHTTPResponseCache.h"
#import <CommonCrypto/CommonDigest.h>

@implementation AFHTTPResponseCache

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    _url = [aDecoder decodeObjectForKey:@"url"];
    _responseObject = [aDecoder decodeObjectForKey:@"responseObject"];
    _responseData = [aDecoder decodeObjectForKey:@"responseData"];
    _expirationDate = [aDecoder decodeObjectForKey:@"expirationDate"];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_url forKey:@"url"];
    [aCoder encodeObject:_responseObject forKey:@"responseObject"];
    [aCoder encodeObject:_responseData forKey:@"responseData"];
    [aCoder encodeObject:_expirationDate forKey:@"expirationDate"];
}


+ (NSCache*)sharedImageMemoryCache
{
    static NSCache* sharedImageMemoryCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedImageMemoryCache = [[NSCache alloc] init];
    });
    
    return sharedImageMemoryCache;
}

+ (dispatch_queue_t)sharedCacheQueue
{
    static dispatch_queue_t sharedCacheQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCacheQueue = dispatch_queue_create("cache_queue", NULL);
    });
    
    return sharedCacheQueue;
}

+ (id)getResponseObjectFromMemoryWithURL:(NSString*)url;
{
    return [[[self class] sharedImageMemoryCache] objectForKey:[self encodeStringMd5:url]];
}

+ (void)saveResponseObjectToMemoryWithURL:(NSString*)url
                           responseObject:(id)responseObject
{
    if (responseObject) {
        [[[self class] sharedImageMemoryCache] setObject:responseObject
                                                  forKey:[self encodeStringMd5:url]];
    }
}

+ (NSData*)getResponseDataFromDiskWithURL:(NSString*)url
                       expirationInterval:(NSTimeInterval)expirationInterval
{
    NSString* cacheFilePath = [self getCacheFilePathWithURL:url];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath]) {
        return nil;
    }

    if (expirationInterval > 0) {
        
        NSDictionary* fileAttribute = [[NSFileManager defaultManager] attributesOfItemAtPath:cacheFilePath error:nil];
        NSDate* modificationDate = (NSDate*)[fileAttribute objectForKey:NSFileModificationDate];
        
        NSTimeInterval timeIntervalSinceModificationDate = [[NSDate date] timeIntervalSinceDate:modificationDate];
        
        if (timeIntervalSinceModificationDate > expirationInterval) {
            [[NSFileManager defaultManager] removeItemAtPath:cacheFilePath error:nil];
            return nil;
        }
    }
   
    return [NSData dataWithContentsOfFile:cacheFilePath];
}

+ (void)saveResponseDataToDiskWithURL:(NSString*)url
                         responseData:(NSData*)responseData
{
    NSString* cacheFilePath = [[self class] getCacheFilePathWithURL:url];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath]) {
        [responseData writeToFile:cacheFilePath atomically:NO];
    }
}
//+ (id)getResponseObjectFromDiskWithURL:(NSString*)url
//{
//    NSString* cachesFilePath = [self getCacheFilePathWithURL:url];
//    NSData* cachedUrlData = [NSData dataWithContentsOfFile:cachesFilePath];
//    
//    if (cachedUrlData) {
//        
//        AFHTTPResponseCache* cache = [NSKeyedUnarchiver unarchiveObjectWithData:cachedUrlData];
//        
//        if ([cache.expirationDate compare:[NSDate date]] == NSOrderedAscending) {
//            [[NSFileManager defaultManager] removeItemAtPath:cachesFilePath error:nil];
//            return nil;
//        }
//        
//        return cache.responseObject;
//    }
//    
//    return nil;
//}


//+ (void)saveResponseObjectToDiskeWithURL:(NSString*)url
//                          responseObject:(id)responseObject
//                      expirationInterval:(NSTimeInterval)expirationInterval
//{
//    if (expirationInterval <= 0) {
//        return;
//    }
//    
//    AFHTTPResponseCache* cache = [[AFHTTPResponseCache alloc] init];
//    cache.responseObject = responseObject;
//    cache.expirationDate =  [[NSDate date] dateByAddingTimeInterval:expirationInterval];
//    
//    NSData* archiveCache = [NSKeyedArchiver archivedDataWithRootObject:cache];
//    
//    NSString* cacheFilePath = [[self class] getCacheFilePathWithURL:url];
//    
//    if ([archiveCache writeToFile:cacheFilePath atomically:YES]) {
//        
//    }
//
//}

+ (NSString*)getCacheFilePathWithURL:(NSString*)url
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* curlCachesDir = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"com.AFNetwork.http"];
    
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
