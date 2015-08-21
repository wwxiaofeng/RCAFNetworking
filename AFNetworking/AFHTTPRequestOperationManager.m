// AFHTTPRequestOperationManager.m
//
// Copyright (c) 2013-2015 AFNetworking (http://afnetworking.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>

#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestCache.h"

#import <Availability.h>
#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>

#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
#import <UIKit/UIKit.h>
#endif

static AFHTTPRequestOperationManager* sharedInstance;

@implementation AFHTTPRequestOperationManager
{
    dispatch_queue_t _saveCacheQueue;
}

+ (instancetype)manager {
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        
        if (!sharedInstance) {
            sharedInstance = [[self alloc] init];
        }
    });
    
    return sharedInstance;
}


- (id)init
{
    
    if (self = [super init]) {
        
//        [[NSURLCache sharedURLCache] removeAllCachedResponses];
//        
//        [[NSURLCache sharedURLCache] setMemoryCapacity:10*1024*1024];
//
//        _saveCacheQueue = dispatch_queue_create("AFCacheQueue", NULL);
        
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        
        self.securityPolicy = [AFSecurityPolicy defaultPolicy];
        
        self.reachabilityManager = [AFNetworkReachabilityManager sharedManager];
        
        self.operationQueue = [[NSOperationQueue alloc] init];
        
        self.shouldUseCredentialStorage = YES;
        
        self.runLoopModes = [NSSet setWithObject:NSRunLoopCommonModes];
        
        return self;
    }
    
    return nil;

}

- (void)setRequestSerializer:(AFHTTPRequestSerializer <AFURLRequestSerialization> *)requestSerializer {
    NSParameterAssert(requestSerializer);

    _requestSerializer = requestSerializer;
}

- (void)setResponseSerializer:(AFHTTPResponseSerializer <AFURLResponseSerialization> *)responseSerializer {
    NSParameterAssert(responseSerializer);

    _responseSerializer = responseSerializer;
}

#pragma mark -
- (AFHTTPRequestOperation*)GET:(NSString *)urlString
                    parameters:(id)parameters
               completionBlock:(void (^)(id responseObject, NSError *error))completionBlock
{
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET"
                                                                   URLString:urlString
                                                                  parameters:parameters
                                                                       error:&serializationError];
    
    
    if (serializationError) {
        if (completionBlock) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            completionBlock(nil, serializationError);
#pragma clang diagnostic pop
        }
        
        return nil;
    }

    AFHTTPRequestCache* cache = [self getCacheWithURL:[request.URL absoluteString]];
    
    if (cache.responseObject) {
        completionBlock(cache.responseObject, nil);
        return nil;
    }
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = self.responseSerializer;
    operation.shouldUseCredentialStorage = self.shouldUseCredentialStorage;
    operation.credential = self.credential;
    operation.securityPolicy = self.securityPolicy;

    __weak typeof(AFHTTPRequestOperation*) weakOperation = operation;
    
    [operation setCompletionBlock:^{
        
        if (completionBlock) {
            completionBlock(weakOperation.responseObject, weakOperation.error);
        }
        
        [self saveCacheWithURL:[request.URL absoluteString]
            expirationInterval:60
                responseObject:weakOperation.responseObject];
    }];
    
    [self.operationQueue addOperation:operation];
    
    return operation;
}

- (AFHTTPRequestOperation*)DFILE:(NSString *)urlString
                      parameters:(id)parameters
                        savePath:(NSString*)savePath
           downloadProgressBlock:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))downloadProgressBlock
                 completionBlock:(void (^)(NSError *error))completionBlock
{
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET"
                                                                   URLString:urlString
                                                                  parameters:parameters
                                                                       error:&serializationError];
    
    
    if (serializationError) {
        if (completionBlock) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            completionBlock(serializationError);
#pragma clang diagnostic pop
        }
        
        return nil;
    }
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = self.responseSerializer;
    operation.shouldUseCredentialStorage = self.shouldUseCredentialStorage;
    operation.credential = self.credential;
    operation.securityPolicy = self.securityPolicy;
    
//    创建一个向指定 File 对象表示的文件中写入数据的文件输出流。如果第二个参数为 true，则将字节写入文件末尾处，而不是写入文件开始处。
    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:savePath append:YES]];
    [operation setDownloadProgressBlock:downloadProgressBlock];

//    if ([operation.outputStream propertyForKey:NSStreamFileCurrentOffsetKey]) {
//        
//        u_int64_t offset = 0;
//        offset = [(NSNumber *)[operation.outputStream propertyForKey:NSStreamFileCurrentOffsetKey] unsignedLongLongValue];
//        
//        [request setValue:[NSString stringWithFormat:@"bytes=%llu-", offset] forHTTPHeaderField:@"Range"];
//    }

    if ([[NSFileManager defaultManager] fileExistsAtPath:savePath]) {
         u_int64_t offset = [[[NSFileManager defaultManager] attributesOfItemAtPath:savePath error:nil] fileSize];
        
        [request setValue:[NSString stringWithFormat:@"bytes=%llu-", offset] forHTTPHeaderField:@"Range"];
    }
    __weak typeof(AFHTTPRequestOperation*) weakOperation = operation;
    
    [operation setCompletionBlock:^{
        
        if (completionBlock) {
            completionBlock(weakOperation.error);
        }
    }];
    
    [self.operationQueue addOperation:operation];
    
    return operation;
}

- (AFHTTPRequestOperation*)UFILE:(NSString *)urlString
                      parameters:(id)parameters
                        filePath:(NSString*)filePath
             uploadProgressBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))uploadProgressBlock
                 completionBlock:(void (^)(NSError *error))completionBlock
{
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST"
                                                                                URLString:urlString
                                                                               parameters:parameters
                                                                constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                    
                                                                    [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:@"files[]" error:nil];
                                                                }

                                                                                    error:&serializationError];
    
    
    if (serializationError) {
        if (completionBlock) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            completionBlock(serializationError);
#pragma clang diagnostic pop
        }
        
        return nil;
    }

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = self.responseSerializer;
    operation.shouldUseCredentialStorage = self.shouldUseCredentialStorage;
    operation.credential = self.credential;
    operation.securityPolicy = self.securityPolicy;
    
    [operation setUploadProgressBlock:uploadProgressBlock];
    
    __weak typeof(AFHTTPRequestOperation*) weakOperation = operation;
    
    [operation setCompletionBlock:^{
        
        if (completionBlock) {
            completionBlock(weakOperation.error);
        }
    }];
    
    [self.operationQueue addOperation:operation];
    
    return operation;
}


- (void)saveCacheWithURL:(NSString*)url
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
    
    NSString* cacheFilePath = [self getCacheFilePathWithURL:url];
    
    if ([archiveCache writeToFile:cacheFilePath atomically:YES]) {
        
    }

}

- (AFHTTPRequestCache*)getCacheWithURL:(NSString*)url
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

- (NSString*)getCacheFilePathWithURL:(NSString*)url
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* curlCachesDir = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"com.fun.curlhttp"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:curlCachesDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:curlCachesDir
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    
    NSString* cachesFilePath = [curlCachesDir stringByAppendingPathComponent:[self encodeStringMd5:url]];
    return cachesFilePath;
}

- (NSString *)encodeStringMd5:(NSString *)string
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