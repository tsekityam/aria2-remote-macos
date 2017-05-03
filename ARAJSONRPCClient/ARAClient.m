//
//  ARAClient.m
//  ARAJSONRPCClient
//
//  Created by Tse Kit Yam on 5/2/17.
//  Copyright © 2017 Tse Kit Yam. All rights reserved.
//

#import "ARAClient.h"

#import "ARADownload.h"
#import "ARAHelper.h"

#import <AFJSONRPCClient/AFJSONRPCClient.h>

@interface ARAClient () {
    NSMutableArray<ARADownload *>* _activeDownloads;
    NSMutableArray<ARADownload *>* _waitingDownloads;
    NSMutableArray<ARADownload *>* _stoppedDownloads;
}
@property AFJSONRPCClient *client;
@property NSString *token;

- (NSArray *)defaultParameters;

@end

@implementation ARAClient
@synthesize activeDownloads = _activeDownloads;
@synthesize waitingDownloads = _waitingDownloads;
@synthesize stoppedDownloads = _stoppedDownloads;

+ (instancetype)clientWithURL:(NSURL *)url token:(NSString *)token {
    return [[ARAClient alloc] initWithURL:url token:token];
}

+ (instancetype)clientWithURL:(NSURL *)url {
    return [[ARAClient alloc] initWithURL:url token:nil];
}

- (instancetype)initWithURL:(NSURL *)url {
    return [self initWithURL:url token:nil];
}

- (instancetype)initWithURL:(NSURL *)url token:(NSString *)token {
    self = [super init];
    if (self) {
        _token = token;
        _client = [AFJSONRPCClient clientWithEndpointURL:url];
        
        _activeDownloads = [NSMutableArray array];
        _waitingDownloads = [NSMutableArray array];
        _stoppedDownloads = [NSMutableArray array];
        
    }
    return self;
}

- (void)updateDownloadLists {
    NSMutableArray *methods = [NSMutableArray array];
    
    NSMutableArray *tellWaitingParameters = [NSMutableArray arrayWithArray:[self defaultParameters]];
    [tellWaitingParameters addObject:[NSNumber numberWithInteger:0]];
    [tellWaitingParameters addObject:[NSNumber numberWithInteger:100]];
    
    NSMutableArray *tellStoppedParameters = [NSMutableArray arrayWithArray:[self defaultParameters]];
    [tellStoppedParameters addObject:[NSNumber numberWithInteger:0]];
    [tellStoppedParameters addObject:[NSNumber numberWithInteger:100]];
    
    NSDictionary *tellActive = @{@"methodName": @"aria2.tellActive", @"params": [self defaultParameters]};
    NSDictionary *tellWaiting = @{@"methodName": @"aria2.tellWaiting", @"params": tellWaitingParameters};
    NSDictionary *tellStopped = @{@"methodName": @"aria2.tellStopped", @"params": tellStoppedParameters};
    
    [methods addObject:@[tellActive, tellWaiting, tellStopped]];
    
    [self multicall:^(id result) {
        [ARAHelper updateDownlaodList:_activeDownloads withDownloadList:[ARAHelper downloadsListFromArray:result[0]]];
        [ARAHelper updateDownlaodList:_waitingDownloads withDownloadList:[ARAHelper downloadsListFromArray:result[1]]];
        [ARAHelper updateDownlaodList:_stoppedDownloads withDownloadList:[ARAHelper downloadsListFromArray:result[2]]];
        [[NSNotificationCenter defaultCenter] postNotificationName:ARADownloadListsDidUpdateNotification object:self];
    } failure:^(NSError *error) {
        // TODO: show the error
    } methods:methods];
}

- (NSArray *)defaultParameters {
    NSMutableArray *parameters = [NSMutableArray array];
    if (_token && [_token length] > 0) {
        [parameters addObject:[NSString stringWithFormat:@"token:%@", _token]];
    }
    return parameters;
}

- (void)addUri:(void (^)(NSString *))success failure:(void (^)(NSError *))failure uris:(NSArray<NSString *> *)uris {
    NSMutableArray *parameters = [NSMutableArray arrayWithArray:[self defaultParameters]];
    [parameters addObject:uris];
    
    [_client invokeMethod:@"aria2.addUri" withParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)remove:(void (^)(NSString *))success failure:(void (^)(NSError *))failure gid:(NSString *)gid {
    NSMutableArray *parameters = [NSMutableArray arrayWithArray:[self defaultParameters]];
    [parameters addObject:gid];
    
    [_client invokeMethod:@"aria2.remove" withParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)forceRemove:(void (^)(NSString *))success failure:(void (^)(NSError *))failure gid:(NSString *)gid {
    NSMutableArray *parameters = [NSMutableArray arrayWithArray:[self defaultParameters]];
    [parameters addObject:gid];
    
    [_client invokeMethod:@"aria2.forceRemove" withParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)pause:(void (^)(NSString *))success failure:(void (^)(NSError *))failure gid:(NSString *)gid {
    NSMutableArray *parameters = [NSMutableArray arrayWithArray:[self defaultParameters]];
    [parameters addObject:gid];
    
    [_client invokeMethod:@"aria2.pause" withParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)pauseAll:(void (^)(NSString *))success failure:(void (^)(NSError *))failure {
    [_client invokeMethod:@"aria2.pauseAll" withParameters:[self defaultParameters] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)forcePause:(void (^)(NSString *))success failure:(void (^)(NSError *))failure gid:(NSString *)gid {
    NSMutableArray *parameters = [NSMutableArray arrayWithArray:[self defaultParameters]];
    [parameters addObject:gid];
    
    [_client invokeMethod:@"aria2.forcePause" withParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)forcePauseAll:(void (^)(NSString *))success failure:(void (^)(NSError *))failure {
    [_client invokeMethod:@"aria2.forcePauseAll" withParameters:[self defaultParameters] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)unpause:(void (^)(NSString *))success failure:(void (^)(NSError *))failure gid:(NSString *)gid {
    NSMutableArray *parameters = [NSMutableArray arrayWithArray:[self defaultParameters]];
    [parameters addObject:gid];
    
    [_client invokeMethod:@"aria2.unpause" withParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)unpauseAll:(void (^)(NSString *))success failure:(void (^)(NSError *))failure {
    [_client invokeMethod:@"aria2.unpauseAll" withParameters:[self defaultParameters] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)tellStatus:(void (^)(ARADownload *))success failure:(void (^)(NSError *))failure gid:(NSString *)gid {
    NSMutableArray *parameters = [NSMutableArray arrayWithArray:[self defaultParameters]];
    [parameters addObject:gid];
    
    [_client invokeMethod:@"aria2.tellStatus" withParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        ARADownload *download = [ARADownload downloadWithDictionary:responseObject];
        success(download);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)tellActive:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure {
    [_client invokeMethod:@"aria2.tellActive" withParameters:[self defaultParameters] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *downloads = [NSMutableArray array];
        for (id dictionary in responseObject) {
            ARADownload *download = [ARADownload downloadWithDictionary:dictionary];
            [downloads addObject:download];
        }
        success(downloads);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)tellWaiting:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure offset:(NSInteger)offset num:(NSInteger)num {
    NSMutableArray *parameters = [NSMutableArray arrayWithArray:[self defaultParameters]];
    [parameters addObject:[NSNumber numberWithInteger:offset]];
    [parameters addObject:[NSNumber numberWithInteger:num]];

    [_client invokeMethod:@"aria2.tellWaiting" withParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *downloads = [NSMutableArray array];
        for (id dictionary in responseObject) {
            ARADownload *download = [ARADownload downloadWithDictionary:dictionary];
            [downloads addObject:download];
        }
        success(downloads);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)tellStopped:(void (^)(NSArray *))success failure:(void (^)(NSError *))failure offset:(NSInteger)offset num:(NSInteger)num {
    NSMutableArray *parameters = [NSMutableArray arrayWithArray:[self defaultParameters]];
    [parameters addObject:[NSNumber numberWithInteger:offset]];
    [parameters addObject:[NSNumber numberWithInteger:num]];
    
    [_client invokeMethod:@"aria2.tellStopped" withParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *downloads = [NSMutableArray array];
        for (id dictionary in responseObject) {
            ARADownload *download = [ARADownload downloadWithDictionary:dictionary];
            [downloads addObject:download];
        }
        success(downloads);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)getVersion:(void (^)(NSString *, NSArray<NSString *> *))success failure:(void (^)(NSError *))failure {
    [_client invokeMethod:@"aria2.getVersion" withParameters:[self defaultParameters] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *version = [responseObject objectForKey:@"version"];
        NSArray<NSString *> *enabledFeatures = [responseObject objectForKey:@"enabledFeatures"];
        success(version, enabledFeatures);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)multicall:(void (^)(id))success failure:(void (^)(NSError *))failure methods:(NSArray<NSDictionary *> *)methods {
    [_client invokeMethod:@"system.multicall" withParameters:methods success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

@end
