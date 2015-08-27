//
//  UIImageView+AFNetworking.h
//  AFNetworking
//
//  Created by yangxf on 15/8/27.
//  Copyright (c) 2015年 yangxf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPRequestOperation.h"

@interface UIImageView (AFNetworking)

@property(nonatomic, strong, setter = setImageRequestOperation:)AFHTTPRequestOperation* imageRequestOperation;

- (void)setImageWithURL:(NSString*)url;

- (void)setImageWithURL:(NSString*)url
       placeholderImage:(UIImage *)placeholderImage;
@end
