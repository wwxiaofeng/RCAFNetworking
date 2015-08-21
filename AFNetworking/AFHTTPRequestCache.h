//
//  AFURLCache.h
//  AFURLCache
//
//  Created by yangxf on 15/7/29.
//  Copyright (c) 2015年 yangxf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AFHTTPRequestCache : NSObject<NSSecureCoding, NSCopying>

@property (readonly, copy) NSString *url;
@property (readonly, copy) NSDictionary *responseObject;
@property (readonly, copy) NSDate* expirationDate;

- (id)initWithUrl:(NSString*)url
   responseObject:(NSDictionary*)responseObject
   expirationDate:(NSDate*)expirationDate;

@end
