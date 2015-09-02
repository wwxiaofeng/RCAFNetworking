// AFURLConnectionOperation.h
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

#import <Availability.h>
#import "AFURLRequestSerialization.h"
#import "AFURLResponseSerialization.h"
#import "AFSecurityPolicy.h"

#ifndef NS_DESIGNATED_INITIALIZER
#if __has_attribute(objc_designated_initializer)
#define NS_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
#else
#define NS_DESIGNATED_INITIALIZER
#endif
#endif

/**
 `AFURLConnectionOperation` is a subclass of `NSOperation` that implements `NSURLConnection` delegate methods.

 ## Subclassing Notes

 This is the base class of all network request operations. You may wish to create your own subclass in order to implement additional `NSURLConnection` delegate methods (see "`NSURLConnection` Delegate Methods" below), or to provide additional properties and/or class constructors.

 If you are creating a subclass that communicates over the HTTP or HTTPS protocols, you may want to consider subclassing `AFHTTPRequestOperation` instead, as it supports specifying acceptable content types or status codes.

 ## NSURLConnection Delegate Methods

 `AFURLConnectionOperation` implements the following `NSURLConnection` delegate methods:

 - `connection:didReceiveResponse:`
 - `connection:didReceiveData:`
 - `connectionDidFinishLoading:`
 - `connection:didFailWithError:`
 - `connection:didSendBodyData:totalBytesWritten:totalBytesExpectedToWrite:`
 - `connection:willCacheResponse:`
 - `connectionShouldUseCredentialStorage:`
 - `connection:needNewBodyStream:`
 - `connection:willSendRequestForAuthenticationChallenge:`

 If any of these methods are overridden in a subclass, they _must_ call the `super` implementation first.

 ## Callbacks and Completion Blocks

 The built-in `completionBlock` provided by `NSOperation` allows for custom behavior to be executed after the request finishes. It is a common pattern for class constructors in subclasses to take callback block parameters, and execute them conditionally in the body of its `completionBlock`. Make sure to handle cancelled operations appropriately when setting a `completionBlock` (i.e. returning early before parsing response data). See the implementation of any of the `AFHTTPRequestOperation` subclasses for an example of this.

 Subclasses are strongly discouraged from overriding `setCompletionBlock:`, as `AFURLConnectionOperation`'s implementation includes a workaround to mitigate retain cycles, and what Apple rather ominously refers to as ["The Deallocation Problem"](http://developer.apple.com/library/ios/#technotes/tn2109/).

 ## SSL Pinning

 Relying on the CA trust model to validate SSL certificates exposes your app to security vulnerabilities, such as man-in-the-middle attacks. For applications that connect to known servers, SSL certificate pinning provides an increased level of security, by checking server certificate validity against those specified in the app bundle.

 SSL with certificate pinning is strongly recommended for any application that transmits sensitive information to an external webservice.

 Connections will be validated on all matching certificates with a `.cer` extension in the bundle root.

 ## App Extensions

 When using AFNetworking in an App Extension, `#define AF_APP_EXTENSIONS` to avoid using unavailable APIs.

 ## NSCoding & NSCopying Conformance

 `AFURLConnectionOperation` conforms to the `NSCoding` and `NSCopying` protocols, allowing operations to be archived to disk, and copied in memory, respectively. However, because of the intrinsic limitations of capturing the exact state of an operation at a particular moment, there are some important caveats to keep in mind:

 ### NSCoding Caveats

 - Encoded operations do not include any block or stream properties. Be sure to set `completionBlock`, `outputStream`, and any callback blocks as necessary when using `-initWithCoder:` or `NSKeyedUnarchiver`.
 - Operations are paused on `encodeWithCoder:`. If the operation was encoded while paused or still executing, its archived state will return `YES` for `isReady`. Otherwise, the state of an operation when encoding will remain unchanged.

 ### NSCopying Caveats

 - `-copy` and `-copyWithZone:` return a new operation with the `NSURLRequest` of the original. So rather than an exact copy of the operation at that particular instant, the copying mechanism returns a completely new instance, which can be useful for retrying operations.
 - A copy of an operation will not include the `outputStream` of the original.
 - Operation copies do not include `completionBlock`, as it often strongly captures a reference to `self`, which would otherwise have the unintuitive side-effect of pointing to the _original_ operation when copied.
 */
#define DISPATCH dispatch_sync
//#define dispatch_async dispatch_async

@interface AFHTTPRequestOperation : NSOperation <NSURLConnectionDelegate, NSURLConnectionDataDelegate, NSSecureCoding, NSCopying>


@property (readonly, nonatomic, strong) NSURLRequest *request;
@property (readonly, nonatomic, strong) NSHTTPURLResponse *response;
@property (readonly, nonatomic, strong) NSError *error;

@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, strong) NSDictionary *userInfo;

@property (readonly, nonatomic, strong) id responseObject;
@property (readonly, nonatomic, strong) NSData *responseCacheData;
@property (readonly, nonatomic, strong) NSData *responseData;
@property (readonly, nonatomic, copy)   NSString *responseString;
@property (readonly, nonatomic, assign) NSStringEncoding responseStringEncoding;


@property (nonatomic, assign) BOOL shouldUseCredentialStorage;
@property (nonatomic, strong) NSURLCredential *credential;
@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;

@property (nonatomic, strong) NSSet *runLoopModes;

@property (nonatomic, strong) AFHTTPResponseSerializer <AFURLResponseSerialization> * responseSerializer;

@property(nonatomic, copy)id (^cacheResponseObjectBlock)(void);
@property(nonatomic, copy)NSData* (^responseCacheDataBlock)(void);

- (instancetype)initWithRequest:(NSURLRequest *)urlRequest NS_DESIGNATED_INITIALIZER;

- (void)pause;
- (BOOL)isPaused;

- (void)resume;

- (void)setUploadProgressBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))block;

- (void)setDownloadProgressBlock:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))block;

- (void)setWillSendRequestForAuthenticationChallengeBlock:(void (^)(NSURLConnection *connection, NSURLAuthenticationChallenge *challenge))block;

- (void)setRedirectResponseBlock:(NSURLRequest * (^)(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse))block;

- (void)setCacheResponseBlock:(NSCachedURLResponse * (^)(NSURLConnection *connection, NSCachedURLResponse *cachedResponse))block;


@end


extern NSString * const AFNetworkingOperationDidStartNotification;

/**
 Posted when an operation finishes.
 */
extern NSString * const AFNetworkingOperationDidFinishNotification;
