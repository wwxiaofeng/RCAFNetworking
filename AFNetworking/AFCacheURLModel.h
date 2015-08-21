//
//  AFCacheURLModel.h
//  AFNetworking
//
//  Created by yangxf on 15/7/17.
//  Copyright (c) 2015年 yangxf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AFCacheURLModel : NSObject

@property (nonatomic,strong) NSString * url;
@property (nonatomic,assign) double expireInMillis;

@end
