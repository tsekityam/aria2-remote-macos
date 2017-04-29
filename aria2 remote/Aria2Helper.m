//
//  Aria2Helper.m
//  aria2 remote
//
//  Created by Tse Kit Yam on 4/29/17.
//  Copyright © 2017 Tse Kit Yam. All rights reserved.
//

#import "Aria2Helper.h"

#import <AFJSONRPCClient/AFJSONRPCClient.h>
#import <Cocoa/Cocoa.h>

@interface Aria2Helper ()
@property AFJSONRPCClient *client;
@property NSString *token;

- (NSMutableArray *)parameters;

@end

@implementation Aria2Helper

+ (instancetype)defaultHelper {
    static Aria2Helper *defaultHelper = nil;
    if (defaultHelper == nil) {
        NSString *server = [[NSUserDefaults standardUserDefaults] stringForKey:@"server"];
        NSString *token= [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
        defaultHelper = [Aria2Helper helperWithServer:server token:token];
    }
    return defaultHelper;
}

+ (instancetype)helperWithServer:(NSString *)server {
    return [[Aria2Helper alloc] initWithServer:server];
}

+ (instancetype)helperWithServer:(NSString *)server token:(NSString *)token
{
    return [[Aria2Helper alloc] initWithServer:server token:token];
}

- (instancetype)initWithServer:(NSString *)server {
    return [self initWithServer:server token:@""];
}

- (instancetype)initWithServer:(NSString *)server token:(NSString *)token {
    self = [super init];
    if (self) {
        _token = token;
        _client = [AFJSONRPCClient clientWithEndpointURL:[NSURL URLWithString:server]];
    }
    return self;
}

- (NSMutableArray *)parameters {
    NSMutableArray *parameters = [NSMutableArray array];
    if ([_token length] > 0) {
        [parameters addObject:[NSString stringWithFormat:@"token:%@", _token]];
    }
    return parameters;
}

- (void)setServer:(NSString *)server token:(NSString *)token {
    _token = token;
    _client = [AFJSONRPCClient clientWithEndpointURL:[NSURL URLWithString:server]];
}

- (void)getVersion:(void (^)(NSString *, NSArray *))success {
    [_client invokeMethod:@"aria2.getVersion" withParameters:[self parameters] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *version = [responseObject objectForKey:@"version"];
        NSArray *enabledFeatures = [responseObject objectForKey:@"enabledFeatures"];
        
        success(version, enabledFeatures);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert runModal];
    }];
}

@end
