//
//  AFURLCache.h
//  AFURLCache
//
//  Created by yangxf on 15/7/29.
//  Copyright (c) 2015年 yangxf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AFHTTPRequestCache : NSObject<NSSecureCoding>

@property (readonly, copy) NSString *url;
@property (readonly, copy) id responseObject;
@property (readonly, copy) NSDate* expirationDate;

- (id)initWithUrl:(NSString*)url
   responseObject:(id)responseObject
   expirationDate:(NSDate*)expirationDate;

+ (void)saveCacheWithURL:(NSString*)url
      expirationInterval:(NSTimeInterval)expirationInterval
          responseObject:(NSDictionary*)responseObject;

+ (AFHTTPRequestCache*)getCacheWithURL:(NSString*)url;

@end
