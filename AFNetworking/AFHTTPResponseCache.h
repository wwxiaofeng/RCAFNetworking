//
//  AFURLCache.h
//  AFURLCache
//
//  Created by yangxf on 15/7/29.
//  Copyright (c) 2015年 yangxf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AFHTTPResponseCache : NSObject<NSSecureCoding>

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) id responseObject;
@property (nonatomic, strong) NSData* responseData;
@property (nonatomic, strong) NSDate* expirationDate;

+ (id)getResponseObjectFromMemoryWithURL:(NSString*)url;

+ (void)saveResponseObjectToMemoryWithURL:(NSString*)url
                           responseObject:(id)responseObject;


+ (NSData*)getResponseDataFromDiskWithURL:(NSString*)url
                       expirationInterval:(NSTimeInterval)expirationInterval;

+ (void)saveResponseDataToDiskWithURL:(NSString*)url
                         responseData:(NSData*)responseData;


@end
