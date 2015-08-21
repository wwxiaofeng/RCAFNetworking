//
//  AFURLCache.m
//  CurlHTTP
//
//  Created by yangxf on 15/7/29.
//  Copyright (c) 2015年 yangxf. All rights reserved.
//

#import "AFHTTPRequestCache.h"

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

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


@end
