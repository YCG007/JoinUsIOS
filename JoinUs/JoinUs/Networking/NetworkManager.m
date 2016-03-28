//
//  NetworkManager.m
//  JoinUs
//
//  Created by Liang Qian on 19/3/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "NetworkManager.h"
#import <UIKit/UIKit.h>

//static NSString* const kApiUrl = @"http://192.168.1.2/joinus/api/";
//static NSString* const kImageUrl = @"http://192.168.1.2/joinus/images/";

static NSString* const kApiUrl = @"http://localhost/joinus/api/";
static NSString* const kImageUrl = @"http://localhost/joinus/images/";

@implementation NetworkManager {
    NSURLSession* _dataSession;
}

+ (id)sharedManager {
    static NetworkManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration* dataSessionConfigration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        
        dataSessionConfigration.timeoutIntervalForRequest = 30.0;
        dataSessionConfigration.timeoutIntervalForResource = 60.0;
//        dataSessionConfigration.HTTPMaximumConnectionsPerHost = 1;
        
        _dataSession = [NSURLSession sessionWithConfiguration:dataSessionConfigration];
    }
    return self;
}

- (BOOL)isLoggedIn {
    if (_token && [_token userId] && [[_token experiationDate] compare:[[NSDate alloc] init]] == NSOrderedDescending) {
        return YES;
    }
    return NO;
}

- (NSURLSessionDataTask*)getDataWithUrl:(NSString *)url completionHandler:(void (^)(long, NSData *))completionHandler {
    return [self requestDataWithUrl:url method:@"GET" data:nil completionHandler:completionHandler];
}

- (NSURLSessionDataTask *)postDataWithUrl:(NSString *)url data:(NSData *)data completionHandler:(void (^)(long, NSData *))completionHandler {
    return [self requestDataWithUrl:url method:@"POST" data:data completionHandler:completionHandler];
}

- (NSURLSessionDataTask *)putDataWithUrl:(NSString *)url data:(NSData *)data completionHandler:(void (^)(long, NSData *))completionHandler {
    return [self requestDataWithUrl:url method:@"PUT" data:data completionHandler:completionHandler];
}

- (NSURLSessionDataTask *)deleteDataWithUrl:(NSString *)url data:(NSData *)data completionHandler:(void (^)(long, NSData *))completionHandler {
    return [self requestDataWithUrl:url method:@"DELETE" data:data completionHandler:completionHandler];
}

- (NSURLSessionDataTask *)requestDataWithUrl:(NSString *)url method:(NSString *)method data:(NSData *)data completionHandler:(void (^)(long, NSData *))completionHandler {
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[kApiUrl stringByAppendingPathComponent:url]]];
    
    [request setHTTPMethod:method];
    
    if ([method isEqualToString:@"POST"] || [method isEqualToString:@"PUT"] || [method isEqualToString:@"DELETE"]) {
        [request setHTTPBody:data];
    }
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [request addValue:[self deviceId] forHTTPHeaderField:@"device-id"];
    [request addValue:[self channel] forHTTPHeaderField:@"channel"];
    [request addValue:[self os] forHTTPHeaderField:@"os"];
    [request addValue:[self version] forHTTPHeaderField:@"client-version"];
    [request addValue:[self pushAgency] forHTTPHeaderField:@"push-agency"];
    [request addValue:[self pushToken] forHTTPHeaderField:@"push-token"];
    
    NSURLSessionDataTask* dataTask = [_dataSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger statusCode;
        if (error == nil) {
            statusCode = [(NSHTTPURLResponse *)response statusCode];
            //NSLog(@"%@ Error: %ld, %@", url, (long)statusCode, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        } else {
            statusCode = error.code;
            NSLog(@"%@ Error: %ld, %@", url, (long)error.code, error);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(statusCode, data);
        });
    }];
    [dataTask resume];
    return dataTask;
}


- (NSString*)deviceId {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

- (NSString*)version {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

- (NSString*)build {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
}

- (NSString*)channel {
    return @"app_store";
}

- (NSString*)os {
    return [[UIDevice currentDevice] systemVersion];
}

- (NSString*)pushAgency {
    return @"No";
}

- (NSString*)pushToken {
    return @"No";
}

@end
