//
//  AFHTTPRequestOperationTest.m
//  AFNetworking
//
//  Created by yangxf on 15/7/6.
//  Copyright (c) 2015年 yangxf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "AFHTTPRequestOperation.h"
#import "AFHTTPRequestOperationManager.h"

@interface AFHTTPRequestOperationTest : XCTestCase

@end

@implementation AFHTTPRequestOperationTest
{
    
}

- (void)setUp {
    [super setUp];
    
    //[Expecta setAsynchronousTestTimeout:5.0];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testGET{
    
//    XCTestExpectation* channelException = [self expectationWithDescription:@"channel"];
//    
//    [[AFHTTPRequestOperationManager manager] GET:@"http://po.funshion.com/v7/config/channel"
//                                      parameters:nil
//                              expirationInterval:60
//                                 completionBlock:^(id responseObject, NSError *error) {
//        
//        [channelException fulfill];
//        
//        XCTAssertNotNil(responseObject);
//        XCTAssertNil(error);
//
//    }];
//    
//    
//    XCTestExpectation* homepageException = [self expectationWithDescription:@"homepage"];
//    
//    [[AFHTTPRequestOperationManager manager] GET:@"http://po.funshion.com/v7/config/homepage"
//                                      parameters:nil
//                              expirationInterval:60
//                                 completionBlock:^(id responseObject, NSError *error) {
//        
//        [homepageException fulfill];
//        
//        XCTAssertNotNil(responseObject);
//        XCTAssertNil(error);
//
//        
//    }];
//    
//    XCTestExpectation* mediaplayException = [self expectationWithDescription:@"mediaplay"];
//    
//    [[AFHTTPRequestOperationManager manager] GET:@"http://pm.funshion.com/v5/media/play"
//                                      parameters:[NSDictionary dictionaryWithObjectsAndKeys:@"622334", @"id",nil]
//                              expirationInterval:60
//                                 completionBlock:^(id responseObject, NSError *error) {
//        
//        
//        [mediaplayException fulfill];
//        
//        XCTAssertNotNil(responseObject);
//        XCTAssertNil(error);
//        
//        
//    }];
//    
//    XCTestExpectation* mediadownloadException = [self expectationWithDescription:@"mediadownload"];
//    
//    [[AFHTTPRequestOperationManager manager] GET:@"http://pm.funshion.com/v5/media/download"
//                                      parameters:[NSDictionary dictionaryWithObjectsAndKeys:@"622334", @"id",nil]
//                              expirationInterval:60
//                                 completionBlock:^(id responseObject, NSError *error) {
//        
//        
//        [mediadownloadException fulfill];
//        
//        XCTAssertNotNil(responseObject);
//        XCTAssertNil(error);
//
//        
//        
//    }];
//    
//    XCTestExpectation* videoplayException = [self expectationWithDescription:@"videoplay"];
//    
//    [[AFHTTPRequestOperationManager manager] GET:@"http://pv.funshion.com/v5/video/play"
//                                      parameters:[NSDictionary dictionaryWithObjectsAndKeys:@"4004819", @"id",nil]
//                              expirationInterval:60
//                                 completionBlock:^(id responseObject, NSError *error) {
//                                     
//                                     [videoplayException fulfill];
//                                     
//                                     XCTAssertNotNil(responseObject);
//                                     XCTAssertNil(error);
//                                     
//                                     NSLog(@"%@", responseObject);
//                                     
//                                     
//                                 }];
//    

    XCTestExpectation* invalidException = [self expectationWithDescription:@"invalidException"];
    
    [[AFHTTPRequestOperationManager manager] GET:@"http://pi.funshion.com"
                                      parameters:nil
                              expirationInterval:60
                                 completionBlock:^(id responseObject, NSError *error) {
                                     
                                     [invalidException fulfill];
                                     
                                     XCTAssertNotNil(error);
                                     XCTAssertNil(responseObject);
                                     
                                     
                                     
                                 }];
        
    [self waitForExpectationsWithTimeout:20 handler:^(NSError *error) {
        
    }];
}

- (void)testDownloadFiles{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cachesPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"test"];

    
    XCTestExpectation* fileException0 = [self expectationWithDescription:@"fileException0"];
    NSString* filePath0 =  [cachesPath stringByAppendingPathComponent:@"20150715135654-8638844.mp4"];
    NSString* fileURL0 = @"http://adm.funshion.com/mat/20150715135654-8638844.mp4";
    
    [[AFHTTPRequestOperationManager manager] DFILE:fileURL0
                                       parameters:nil
                                         savePath:filePath0
                            downloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                                
                                NSLog(@"file0-bytesRead:%lu totalBytesRead:%lld totalBytesExpectedToRead:%lld", (unsigned long)bytesRead, totalBytesRead, totalBytesExpectedToRead);
                            }
                                  completionBlock:^(NSError *error) {
                                      
                                      [fileException0 fulfill];
                                      
                                  }];
    
    XCTestExpectation* fileException1 = [self expectationWithDescription:@"fileException1"];
    NSString* filePath1 =  [cachesPath stringByAppendingPathComponent:@"49C77BC2F168D2A538F3568AD85AB1932FEFCE17.mp4"];
    NSString* fileURL1 = @"http://124.228.136.144:80/play/49C77BC2F168D2A538F3568AD85AB1932FEFCE17.mp4";
    
    [[AFHTTPRequestOperationManager manager] DFILE:fileURL1
                                       parameters:nil
                                         savePath:filePath1
                            downloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                                
                                NSLog(@"file1-bytesRead:%lu totalBytesRead:%lld totalBytesExpectedToRead:%lld", (unsigned long)bytesRead, totalBytesRead, totalBytesExpectedToRead);
                            }
                                  completionBlock:^(NSError *error) {
                                      
                                      [fileException1 fulfill];
                                      
                                  }];
    
    XCTestExpectation* fileException2 = [self expectationWithDescription:@"fileException2"];
    NSString* fileURL2 = @"http://218.76.97.44:80/play/45EA188606B53599639C757B2CC111694751765F.mp4";
    NSString* filePath2 =  [cachesPath stringByAppendingPathComponent:@"45EA188606B53599639C757B2CC111694751765F.mp4"];
    
    [[AFHTTPRequestOperationManager manager] DFILE:fileURL2
                                       parameters:nil
                                         savePath:filePath2
                            downloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                                
                                NSLog(@"file2-bytesRead:%lu totalBytesRead:%lld totalBytesExpectedToRead:%lld", (unsigned long)bytesRead, totalBytesRead, totalBytesExpectedToRead);
                            }
                                  completionBlock:^(NSError *error) {
                                      
                                      [fileException2 fulfill];
                                      
                                  }];
    
    XCTestExpectation* fileException3 = [self expectationWithDescription:@"fileException3"];
    NSString* fileURL3 = @"http://124.228.136.142:80/play/CEEE18709F2DF2B224BE2FDF6EA517186DAC59B6.mp4";
    NSString* filePath3 =  [cachesPath stringByAppendingPathComponent:@"CEEE18709F2DF2B224BE2FDF6EA517186DAC59B6.mp4"];
    
    [[AFHTTPRequestOperationManager manager] DFILE:fileURL3
                                       parameters:nil
                                         savePath:filePath3
                            downloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                                
                                NSLog(@"file3-bytesRead:%lu totalBytesRead:%lld totalBytesExpectedToRead:%lld", (unsigned long)bytesRead, totalBytesRead, totalBytesExpectedToRead);
                            }
                                  completionBlock:^(NSError *error) {
                                      
                                      [fileException3 fulfill];
                                      
                                  }];
    [self waitForExpectationsWithTimeout:60*60 handler:^(NSError *error) {
        
    }];

}

- (void)testUploadFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cachesPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"test"];

    XCTestExpectation* uploadFileException1 = [self expectationWithDescription:@"fileException1"];
    NSString* filePath1 =  [cachesPath stringByAppendingPathComponent:@"49C77BC2F168D2A538F3568AD85AB1932FEFCE17.mp4"];
    
    [[AFHTTPRequestOperationManager manager] UFILE:@"http://127.0.0.1:8080/upload"
                                        parameters:nil
                                          filePath:filePath1
                               uploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
                                   
                                   NSLog(@"upload-file0-bytesWritten:%lu totalBytesWritten:%lld totalBytesExpectedToWrite:%lld",
                                         (unsigned long)bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
                                   
                               }
                                   completionBlock:^(NSError *error) {
                                       
                                       [uploadFileException1 fulfill];
                                       
                                       XCTAssertNil(error);
                                   }];
    
    [self waitForExpectationsWithTimeout:60 * 60 handler:^(NSError *error) {
        
        
    }];
}

- (void)testPauseDownloadFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cachesPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"test"];

    
   // XCTestExpectation* pauseDownloadException = [self expectationWithDescription:@"pauseDownloadException"];
    
    XCTestExpectation* resumeDownloadException = [self expectationWithDescription:@"resumeDownloadException"];

    NSString* filePath1 =  [cachesPath stringByAppendingPathComponent:@"49C77BC2F168D2A538F3568AD85AB1932FEFCE17.mp4"];
    NSString* fileURL1 = @"http://124.228.136.144:80/play/49C77BC2F168D2A538F3568AD85AB1932FEFCE17.mp4";
    
    AFHTTPRequestOperation* operation = [[AFHTTPRequestOperationManager manager] DFILE:fileURL1
                                                                           parameters:nil
                                                                             savePath:filePath1
                                                                downloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                                                                    
                                                                    NSLog(@"file1-bytesRead:%lu totalBytesRead:%lld totalBytesExpectedToRead:%lld", (unsigned long)bytesRead, totalBytesRead, totalBytesExpectedToRead);
                                                                }
                                                                      completionBlock:^(NSError *error) {
                                                                          
                                                                          [resumeDownloadException fulfill];
                                                                          
                                                                      }];
    
    
    [operation pause];
    
    XCTAssertTrue([operation isPaused]);
    
    [operation resume];
    
    XCTAssertTrue([operation isExecuting]);
    
    [self waitForExpectationsWithTimeout:60 * 60 handler:^(NSError *error) {
        
       
    }];
}

- (void)testImage
{
    
}
- (void)testRunloop
{
//    while (1) {
//        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 5, YES);
//    }
    
    //CFRunLoopRef runloop = CFRunLoopGetCurrent();
    
    while (1) {
        NSRunLoop* runloop1 = [NSRunLoop currentRunLoop];
        [runloop1 runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];

    }
    
    NSLog(@"testRunloop");
}

//- (void)testAsyncTheOldWay
//{
//    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:5.0];
//    __block BOOL responseHasArrived = NO;
//    
//    [self.pageLoader requestUrl:@"http://bignerdranch.com"
//              completionHandler:^(NSString *page) {
//                  
//                  NSLog(@"The web page is %ld bytes long.", page.length);
//                  responseHasArrived = YES;
//                  XCTAssert(page.length > 0);
//              }];
//    
//    while (responseHasArrived == NO && ([timeoutDate timeIntervalSinceNow] > 0)) {
//        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.01, YES);
//    }
//    
//    if (responseHasArrived == NO) {
//        XCTFail(@"Test timed out");
//    }
//}


//    "http://124.228.136.144:80/play/49C77BC2F168D2A538F3568AD85AB1932FEFCE17.mp4",
//    "http://125.88.148.7:80/play/49C77BC2F168D2A538F3568AD85AB1932FEFCE17.mp4",
//    "http://222.84.164.40:80/play/49C77BC2F168D2A538F3568AD85AB1932FEFCE17.mp4",
//    "http://183.131.82.145:80/play/49C77BC2F168D2A538F3568AD85AB1932FEFCE17.mp4",
//    "http://221.229.165.30:80/play/49C77BC2F168D2A538F3568AD85AB1932FEFCE17.mp4"

//    "http://218.76.97.44:80/play/45EA188606B53599639C757B2CC111694751765F.mp4",
//    "http://125.88.148.8:80/play/45EA188606B53599639C757B2CC111694751765F.mp4",
//    "http://222.84.164.8:80/play/45EA188606B53599639C757B2CC111694751765F.mp4",
//    "http://115.231.181.94:80/play/45EA188606B53599639C757B2CC111694751765F.mp4",
//    "http://221.229.165.15:80/play/45EA188606B53599639C757B2CC111694751765F.mp4"
//
//    "http://124.228.136.142:80/play/CEEE18709F2DF2B224BE2FDF6EA517186DAC59B6.mp4",
//    "http://14.17.72.76:80/play/CEEE18709F2DF2B224BE2FDF6EA517186DAC59B6.mp4",
//    "http://222.84.164.3:80/play/CEEE18709F2DF2B224BE2FDF6EA517186DAC59B6.mp4",
//    "http://183.131.82.138:80/play/CEEE18709F2DF2B224BE2FDF6EA517186DAC59B6.mp4",
//    "http://221.229.165.3:80/play/CEEE18709F2DF2B224BE2FDF6EA517186DAC59B6.mp4"

@end
