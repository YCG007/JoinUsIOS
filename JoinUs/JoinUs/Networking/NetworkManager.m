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
    NSURLSession* _imageSession;
}

@synthesize myProfile = _myProfile;
@synthesize token = _token;

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
        
        NSURLSessionConfiguration* imageSessionConfigration = [NSURLSessionConfiguration defaultSessionConfiguration];
        [imageSessionConfigration setURLCache:[NSURLCache sharedURLCache]];
        [imageSessionConfigration setRequestCachePolicy:NSURLRequestReturnCacheDataElseLoad];
        imageSessionConfigration.timeoutIntervalForRequest = 30.0;
        imageSessionConfigration.timeoutIntervalForResource = 60.0;
        
        _imageSession = [NSURLSession sessionWithConfiguration:imageSessionConfigration];
    }
    return self;
}

- (BOOL)isLoggedIn {
    if ([self token] && [[self token] userId] && [[[self token] experiationDate] compare:[[NSDate alloc] init]] == NSOrderedDescending) {
        return YES;
    }
    return NO;
}

- (void)logout {
    _myProfile = nil;
    _token = nil;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nil forKey:@"myProfile"];
    [userDefaults setObject:nil forKey:@"token"];
    [userDefaults synchronize];
}

- (void)setMyProfile:(UserProfile *)myProfile {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[myProfile toJSONString] forKey:@"myProfile"];
    [userDefaults synchronize];
    _myProfile = myProfile;
}

- (UserProfile *)myProfile {
    if (_myProfile == nil) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        _myProfile = [[UserProfile alloc] initWithString:[userDefaults objectForKey:@"myProfile"] error:nil] ;
    }
    return _myProfile;
}

- (void)setToken:(UserToken *)token {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[token toJSONString] forKey:@"token"];
    [userDefaults synchronize];
    _token = token;
}

- (UserToken *)token {
    if (_token == nil) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        _token = [[UserToken alloc] initWithString:[userDefaults objectForKey:@"token"] error:nil] ;
    }
    return _token;
}

- (NSURLSessionDataTask*)getDataWithUrl:(NSString *)url completionHandler:(void (^)(long, NSData *, NSString *))completionHandler {return [self requestDataWithUrl:url method:@"GET" data:nil completionHandler:completionHandler];
}

- (NSURLSessionDataTask *)postDataWithUrl:(NSString *)url data:(NSData *)data completionHandler:(void (^)(long, NSData *, NSString *))completionHandler {
    return [self requestDataWithUrl:url method:@"POST" data:data completionHandler:completionHandler];
}

- (NSURLSessionDataTask *)putDataWithUrl:(NSString *)url data:(NSData *)data completionHandler:(void (^)(long, NSData *, NSString *))completionHandler {
    return [self requestDataWithUrl:url method:@"PUT" data:data completionHandler:completionHandler];
}

- (NSURLSessionDataTask *)deleteDataWithUrl:(NSString *)url data:(NSData *)data completionHandler:(void (^)(long, NSData *, NSString *))completionHandler {
    return [self requestDataWithUrl:url method:@"DELETE" data:data completionHandler:completionHandler];
}

- (NSURLSessionDataTask *)requestDataWithUrl:(NSString *)url method:(NSString *)method data:(NSData *)data completionHandler:(void (^)(long, NSData *, NSString *))completionHandler {
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[kApiUrl stringByAppendingPathComponent:url]]];
    
    [request setHTTPMethod:method];
    
    if ([method isEqualToString:@"POST"] || [method isEqualToString:@"PUT"] || [method isEqualToString:@"DELETE"]) {
        [request setHTTPBody:data];
    }
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    if ([self isLoggedIn]) {
        [request setValue:[_token userId] forHTTPHeaderField:@"user-id"];
        [request setValue:[_token securityToken] forHTTPHeaderField:@"security-token"];
        
        [request setValue:[self deviceId] forHTTPHeaderField:@"device-id"];
        [request setValue:[self channel] forHTTPHeaderField:@"channel"];
        [request setValue:[self os] forHTTPHeaderField:@"os"];
        [request setValue:[self version] forHTTPHeaderField:@"client-version"];
        [request setValue:[self pushAgency] forHTTPHeaderField:@"push-agency"];
        [request setValue:[self pushToken] forHTTPHeaderField:@"push-token"];
    }
    
    NSURLSessionDataTask* dataTask = [_dataSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger statusCode;
        NSString *errorMessage;
        if (error == nil) {
            statusCode = [(NSHTTPURLResponse *)response statusCode];
            if (statusCode == 400 || statusCode == 401) {
                if (data != nil) {
                    NSError *jsonError = nil;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                    
                    if (jsonError == nil && [jsonObject isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *jsonDictionary = (NSDictionary *)jsonObject;
                        errorMessage = [jsonDictionary objectForKey:@"message"];
                    }
                }
            } else {
                errorMessage = [NSString stringWithFormat:@"%ld", (long)statusCode];
            }
        } else {
            statusCode = error.code;
            errorMessage = error.localizedDescription;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(statusCode, data, errorMessage);
        });
    }];
    [dataTask resume];
    return dataTask;
}


- (NSURLSessionDataTask *)uploadImageWithUrl:(NSString *)url data:(NSData *)data completionHandler:(void (^)(long, NSData *, NSString *))completionHandler {
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[kApiUrl stringByAppendingPathComponent:url]]];
    
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = [[NSUUID UUID] UUIDString];
    // set Content-Type in HTTP header
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField: @"Content-Type"];
    
    if ([self isLoggedIn]) {
        [request setValue:[_token userId] forHTTPHeaderField:@"user-id"];
        [request setValue:[_token securityToken] forHTTPHeaderField:@"security-token"];
        
        [request setValue:[self deviceId] forHTTPHeaderField:@"device-id"];
        [request setValue:[self channel] forHTTPHeaderField:@"channel"];
        [request setValue:[self os] forHTTPHeaderField:@"os"];
        [request setValue:[self version] forHTTPHeaderField:@"client-version"];
        [request setValue:[self pushAgency] forHTTPHeaderField:@"push-agency"];
        [request setValue:[self pushToken] forHTTPHeaderField:@"push-token"];
    }
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@\r\n\r\n", @"key"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", @"value"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // add image data
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=%@; filename=%@\r\n", @"file", @"photo.jpg"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:data];
    [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // body end
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    //NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    //[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    NSURLSessionDataTask* dataTask = [_dataSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        long statusCode;
        NSString *errorMessage;
        if (error == nil) {
            statusCode = [(NSHTTPURLResponse *)response statusCode];
            if (statusCode == 400 || statusCode == 401) {
                if (data != nil) {
                    NSError *jsonError = nil;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                    
                    if (jsonError == nil && [jsonObject isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *jsonDictionary = (NSDictionary *)jsonObject;
                        errorMessage = [jsonDictionary objectForKey:@"message"];
                    }
                }
            } else {
                errorMessage = [NSString stringWithFormat:@"%ld", statusCode];
            }
        } else {
            statusCode = error.code;
            errorMessage = error.localizedDescription;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(statusCode, data, errorMessage);
        });
    }];
    [dataTask resume];
    return dataTask;
}

- (NSURLSessionDataTask *)getUploadImageWithName:(NSString *)name completionHandler:(void (^)(long, NSData *))completionHandler {
    NSString* url = [kImageUrl stringByAppendingPathComponent:[NSString stringWithFormat:@"/upload/%@%@", name, @".jpg"]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    NSURLSessionDataTask* dataTask = [_imageSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger statusCode;
        if (error == nil) {
            statusCode = [(NSHTTPURLResponse *)response statusCode];
        } else {
            statusCode = error.code;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(statusCode, data);
        });
    }];
    [dataTask resume];
    return dataTask;
}

- (NSURLSessionDataTask *)getResizedImageWithName:(NSString *)name dimension:(int)dimension completionHandler:(void (^)(long, NSData *))completionHandler {
    NSString* url = [kImageUrl stringByAppendingPathComponent:[NSString stringWithFormat:@"/resized/%@_%d%@", name, dimension, @".jpg"]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    NSURLSessionDataTask* dataTask = [_imageSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger statusCode;
        if (error == nil) {
            statusCode = [(NSHTTPURLResponse *)response statusCode];
        } else {
            statusCode = error.code;
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
