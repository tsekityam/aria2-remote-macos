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

- (void)getVersion {
    [_client invokeMethod:@"aria2.getVersion" withParameters:[self parameters] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Success"];
        [alert runModal];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert runModal];
    }];
}

@end
