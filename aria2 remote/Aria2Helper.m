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

- (void)addUri:(void (^)(NSString *))success uris:(NSArray *)uris {
    NSMutableArray *parameters = [self parameters];
    [parameters addObject:uris];

    [_client invokeMethod:@"aria2.addUri" withParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert runModal];
    }];
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

- (void)tellActive:(void (^)(NSArray *))success {
    [_client invokeMethod:@"aria2.tellActive" withParameters:[self parameters] success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSMutableArray *downloads = [NSMutableArray array];
        for (id element in responseObject) {
            Aria2Download *download = [Aria2Download downloadWithStatus:element];
            [downloads addObject:download];
        }
        success(downloads);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // TODO: notify user if fail to get active list
    }];
}

- (void)tellWaiting:(void (^)(NSArray *))success offset:(NSInteger)offset num:(NSInteger)num {
    NSMutableArray *parameters = [self parameters];
    [parameters addObject:[NSNumber numberWithInteger:offset]];
    [parameters addObject:[NSNumber numberWithInteger:num]];

    [_client invokeMethod:@"aria2.tellWaiting" withParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSMutableArray *downloads = [NSMutableArray array];
        for (id element in responseObject) {
            Aria2Download *download = [Aria2Download downloadWithStatus:element];
            [downloads addObject:download];
        }
        success(downloads);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // TODO: notify user if fail to get active list
    }];
}

- (void)tellStopped:(void (^)(NSArray *))success offset:(NSInteger)offset num:(NSInteger)num {
    NSMutableArray *parameters = [self parameters];
    [parameters addObject:[NSNumber numberWithInteger:offset]];
    [parameters addObject:[NSNumber numberWithInteger:num]];

    [_client invokeMethod:@"aria2.tellStopped" withParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSMutableArray *downloads = [NSMutableArray array];
        for (id element in responseObject) {
            Aria2Download *download = [Aria2Download downloadWithStatus:element];
            [downloads addObject:download];
        }
        success(downloads);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // TODO: notify user if fail to get active list
    }];
}

@end

@implementation Aria2Download

+ (instancetype)downloadWithStatus:(id)status {
    return [[Aria2Download alloc] initWithStatus:status];
}

- (instancetype)initWithStatus:(id)status {
    self = [super init];
    if (self) {
        _statusDictionay = status;

        _gid = [status objectForKey:@"gid"];
        _status = [status objectForKey:@"status"];
        _totalLength = [status objectForKey:@"totalLength"];
        _completedLength = [status objectForKey:@"completedLength"];
        _uploadLength = [status objectForKey:@"uploadLength"];
        _bitfield = [status objectForKey:@"bitfield"];
        _downloadSpeed = [status objectForKey:@"downloadSpeed"];
        _uploadSpeed = [status objectForKey:@"uploadSpeed"];
        _infoHash = [status objectForKey:@"infoHash"];
        _numSeeders = [status objectForKey:@"numSeeders"];
        _seeder = [status objectForKey:@"seeder"];
        _pieceLength = [status objectForKey:@"pieceLength"];
        _numPieces = [status objectForKey:@"numPieces"];
        _connections = [status objectForKey:@"connections"];
        _errorCode = [status objectForKey:@"errorCode"];
        _errorMessage = [status objectForKey:@"errorMessage"];
        _followedBy = [status objectForKey:@"followedBy"];
        _following = [status objectForKey:@"following"];
        _belongsTo = [status objectForKey:@"belongsTo"];
        _dir = [status objectForKey:@"dir"];
        _files = [status objectForKey:@"files"];
        _bittorrent = [status objectForKey:@"bittorrent"];
        _verifiedLength = [status objectForKey:@"verifiedLength"];
        _verifyIntegrityPending = [status objectForKey:@"verifyIntegrityPending"];
    }
    return self;
}

- (id)objectForKey:(id)key {
    return [_statusDictionay objectForKey:key];
}

@end
