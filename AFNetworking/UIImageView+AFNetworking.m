//
//  UIImageView+AFNetworking.m
//  AFNetworking
//
//  Created by yangxf on 15/8/27.
//  Copyright (c) 2015年 yangxf. All rights reserved.
//

#import "UIImageView+AFNetworking.h"
#import "AFHTTPResponseCache.h"
#import <objc/runtime.h>

@implementation UIImageView (AFNetworking)


+ (NSOperationQueue *)sharedImageRequestOperationQueue {
    static NSOperationQueue *sharedImageRequestOperationQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedImageRequestOperationQueue = [[NSOperationQueue alloc] init];
        sharedImageRequestOperationQueue.maxConcurrentOperationCount = 5;
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
    [self afsetImageWithURL:url placeholderImage:nil];
}

- (void)afsetImageWithURL:(NSString*)url
       placeholderImage:(UIImage *)placeholderImage
{
   
    self.image = [AFHTTPResponseCache getResponseObjectFromMemoryWithURL:url];
    
    if (self.image) {
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    
    self.image = placeholderImage;
    self.imageRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    self.imageRequestOperation.responseSerializer = [AFImageResponseSerializer serializer];
    
//    __weak typeof(self) weakSelf = self;
//    __strong __typeof(weakSelf)strongSelf = weakSelf;
    __weak UIImageView *wself = self;
    __weak typeof(AFHTTPRequestOperation*) weakOperation = self.imageRequestOperation;
    
    //[self.imageRequestOperation setQueuePriority:NSOperationQueuePriorityVeryHigh];
    
    [self.imageRequestOperation setResponseCacheDataBlock:^NSData*{
        return [AFHTTPResponseCache getResponseDataFromDiskWithURL:[request.URL absoluteString]
                                                expirationInterval:0];
    }];
    
    [self.imageRequestOperation setCompletionBlock:^{

        if (weakOperation.responseCacheData && weakOperation.responseObject) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                wself.image = weakOperation.responseObject;
                 [wself setNeedsLayout];
            });
            
            [AFHTTPResponseCache saveResponseObjectToMemoryWithURL:[request.URL absoluteString]
                                                    responseObject:weakOperation.responseObject];
        }
        else if (weakOperation.responseObject) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                 wself.image = weakOperation.responseObject;
                 [wself setNeedsLayout];
            });
           
            [AFHTTPResponseCache saveResponseObjectToMemoryWithURL:[request.URL absoluteString]
                                                    responseObject:weakOperation.responseObject];

//            NSData* imagePressData;
//            if (UIImagePNGRepresentation(wself.image)==nil) {
//                imagePressData = UIImageJPEGRepresentation(wself.image, 1.0);
//            }else{
//                imagePressData = UIImagePNGRepresentation(wself.image);
//            }
            
            [AFHTTPResponseCache saveResponseDataToDiskWithURL:[request.URL absoluteString]
                                                  responseData:weakOperation.responseData];
        }
        
    }];
    
    [[[self class] sharedImageRequestOperationQueue] addOperation:self.imageRequestOperation];
}
@end
