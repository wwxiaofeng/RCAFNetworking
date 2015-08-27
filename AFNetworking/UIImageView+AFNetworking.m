//
//  UIImageView+AFNetworking.m
//  AFNetworking
//
//  Created by yangxf on 15/8/27.
//  Copyright (c) 2015年 yangxf. All rights reserved.
//

#import "UIImageView+AFNetworking.h"
#import "AFHTTPRequestCache.h"
#import <objc/runtime.h>

@implementation UIImageView (AFNetworking)


+ (NSOperationQueue *)sharedImageRequestOperationQueue {
    static NSOperationQueue *sharedImageRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedImageRequestOperationQueue = [[NSOperationQueue alloc] init];
        sharedImageRequestOperationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    });
    
    return sharedImageRequestOperationQueue;
}

- (AFHTTPRequestOperation *)imageRequestOperation {
    return (AFHTTPRequestOperation *)objc_getAssociatedObject(self, @selector(imageRequestOperation));
}

- (void)setImageRequestOperation:(AFHTTPRequestOperation *)imageRequestOperation {
    objc_setAssociatedObject(self, @selector(imageRequestOperation), imageRequestOperation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (void)setImageWithURL:(NSString*)url
{
    [self setImageWithURL:url placeholderImage:nil];
}

- (void)setImageWithURL:(NSString*)url
       placeholderImage:(UIImage *)placeholderImage
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    AFHTTPRequestCache* cache = [AFHTTPRequestCache getCacheWithURL:[request.URL absoluteString]];
    
    if (cache.responseObject) {
        self.image = cache.responseObject;
        return;
    }
    
    self.image = placeholderImage;
    self.imageRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    self.imageRequestOperation.responseSerializer = [AFImageResponseSerializer serializer];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(AFHTTPRequestOperation*) weakOperation = self.imageRequestOperation;
    
    [self.imageRequestOperation setCompletionBlock:^{
        
        if (weakOperation.responseObject) {
            
            weakSelf.image = weakOperation.responseObject;
            [AFHTTPRequestCache saveCacheWithURL:[request.URL absoluteString]
                              expirationInterval:60
                                  responseObject:weakOperation.responseObject];
        }
        
    }];
    
    [[[self class] sharedImageRequestOperationQueue] addOperation:self.imageRequestOperation];
}
@end
