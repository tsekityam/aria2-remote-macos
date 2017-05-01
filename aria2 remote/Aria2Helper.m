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
- (NSArray<Aria2Download *> *)downloadsFromResponseObject:(id)responseObject;

@end

@interface Aria2Download ()

- (void)updateStatusTo:(Aria2Download *)target;

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

+ (void)updateDownloads:(NSMutableArray<Aria2Download *> *)sourceDownloads to:(NSArray<Aria2Download *> *)targetDownloads {
    NSArray *tempSourceDownloads = [sourceDownloads copy];
    [sourceDownloads removeAllObjects];

    for (Aria2Download *target in targetDownloads) {
        NSInteger indexOfTarget = [tempSourceDownloads indexOfObject:target];
        if (indexOfTarget != NSNotFound) {
            Aria2Download *source = [tempSourceDownloads objectAtIndex:indexOfTarget];
            [source updateStatusTo:target];
            [sourceDownloads addObject:source];
        } else {
            [sourceDownloads addObject:target];
        }
    }
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

- (void)tell:(void (^)(NSArray *downloads))success failure:(void (^)(NSError *error))failure {
    NSMutableArray *parameters = [NSMutableArray array];

    NSMutableArray *tellWaitingParameters = [self parameters];
    [tellWaitingParameters addObject:[NSNumber numberWithInteger:0]];
    [tellWaitingParameters addObject:[NSNumber numberWithInteger:100]];

    NSMutableArray *tellStoppedParameters = [self parameters];
    [tellStoppedParameters addObject:[NSNumber numberWithInteger:0]];
    [tellStoppedParameters addObject:[NSNumber numberWithInteger:100]];

    NSDictionary *tellActive = @{@"methodName": @"aria2.tellActive", @"params": [self parameters]};
    NSDictionary *tellWaiting = @{@"methodName": @"aria2.tellWaiting", @"params": tellWaitingParameters};
    NSDictionary *tellStopped = @{@"methodName": @"aria2.tellStopped", @"params": tellStoppedParameters};

    [parameters addObject:@[tellActive, tellWaiting, tellStopped]];

    [_client invokeMethod:@"system.multicall" withParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *activateDownloads = [self downloadsFromResponseObject:responseObject[0]];
        NSArray *waitingDownloads = [self downloadsFromResponseObject:responseObject[1]];
        NSArray *stoppedDownloads = [self downloadsFromResponseObject:responseObject[2]];
        success(@[activateDownloads, waitingDownloads, stoppedDownloads]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (NSArray<Aria2Download *> *)downloadsFromResponseObject:(id)responseObject {
    NSMutableArray *downloads = [NSMutableArray array];

    if ([responseObject isKindOfClass:[NSDictionary class]]){
        if ([responseObject objectForKey:@"message"] &&
            [responseObject objectForKey:@"code"]) {
            // TODO: indicate that there is an error
            return downloads;
        }
    } else if ([responseObject isKindOfClass:[NSArray class]]) {
        if ([responseObject[0] isKindOfClass:[NSArray class]]) {
            // the response object may come from system.multicall
            for (id item in responseObject[0]) {
                if ([item isKindOfClass:[NSDictionary class]]) {
                    Aria2Download *download = [Aria2Download downloadWithStatus:item];
                    [downloads addObject:download];
                }
            }
        }
    }

    return downloads;
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

- (void)pause:(void (^)(NSString *))success gid:(NSString *)gid {
    NSMutableArray *parameters = [self parameters];
    [parameters addObject:gid];

    [_client invokeMethod:@"aria2.pause" withParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert runModal];
    }];
}

- (void)unpause:(void (^)(NSString *))success gid:(NSString *)gid {
    NSMutableArray *parameters = [self parameters];
    [parameters addObject:gid];

    [_client invokeMethod:@"aria2.unpause" withParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert runModal];
    }];
}

- (void)remove:(void (^)(NSString *))success gid:(NSString *)gid {
    NSMutableArray *parameters = [self parameters];
    [parameters addObject:gid];

    [_client invokeMethod:@"aria2.remove" withParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert runModal];
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
        _gid = [status objectForKey:@"gid"] ? [status objectForKey:@"gid"] : @"";
        _status = [status objectForKey:@"status"] ? [status objectForKey:@"status"] : @"";
        _totalLength = [status objectForKey:@"totalLength"] ? [status objectForKey:@"totalLength"] : @"";
        _completedLength = [status objectForKey:@"completedLength"] ? [status objectForKey:@"completedLength"] : @"";
        _uploadLength = [status objectForKey:@"uploadLength"] ? [status objectForKey:@"uploadLength"] : @"";
        _bitfield = [status objectForKey:@"bitfield"] ? [status objectForKey:@"bitfield"] : @"";
        _downloadSpeed = [status objectForKey:@"downloadSpeed"] ? [status objectForKey:@"downloadSpeed"] : @"";
        _uploadSpeed = [status objectForKey:@"uploadSpeed"] ? [status objectForKey:@"uploadSpeed"] : @"";
        _infoHash = [status objectForKey:@"infoHash"] ? [status objectForKey:@"infoHash"] : @"";
        _numSeeders = [status objectForKey:@"numSeeders"] ? [status objectForKey:@"numSeeders"] : @"";
        _seeder = [status objectForKey:@"seeder"] ? [status objectForKey:@"seeder"] : @"";
        _pieceLength = [status objectForKey:@"pieceLength"] ? [status objectForKey:@"pieceLength"] : @"";
        _numPieces = [status objectForKey:@"numPieces"] ? [status objectForKey:@"numPieces"] : @"";
        _connections = [status objectForKey:@"connections"] ? [status objectForKey:@"connections"] : @"";
        _errorCode = [status objectForKey:@"errorCode"] ? [status objectForKey:@"errorCode"] : @"";
        _errorMessage = [status objectForKey:@"errorMessage"] ? [status objectForKey:@"errorMessage"] : @"";
        _followedBy = [status objectForKey:@"followedBy"] ? [status objectForKey:@"followedBy"] : @"";
        _following = [status objectForKey:@"following"] ? [status objectForKey:@"following"] : @"";
        _belongsTo = [status objectForKey:@"belongsTo"] ? [status objectForKey:@"belongsTo"] : @"";
        _dir = [status objectForKey:@"dir"] ? [status objectForKey:@"dir"] : @"";
//        _files = [status objectForKey:@"files"] ? [status objectForKey:@"files"] : @[];
        _bittorrent = [status objectForKey:@"bittorrent"] ? [status objectForKey:@"bittorrent"] : @{};
        _verifiedLength = [status objectForKey:@"verifiedLength"] ? [status objectForKey:@"verifiedLength"] : @"";
        _verifyIntegrityPending = [status objectForKey:@"verifyIntegrityPending"] ? [status objectForKey:@"verifyIntegrityPending"] : @"";

        NSMutableArray *files = [NSMutableArray array];
        if ([status objectForKey:@"files"]) {
            for (NSDictionary *dictionary in [status objectForKey:@"files"]) {
                Aria2File *file = [Aria2File fileWithDictionary:dictionary];
                [files addObject:file];
            }
        }
        _files = files;

    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[Aria2Download class]]) {
        return [_gid isEqual:[object gid]];
    }
    return NO;
}

- (NSString *)name {
    if ([_files count] > 0) {
        NSURL *dirURL = [NSURL URLWithString:_dir];
        NSArray *dirComponents = [dirURL pathComponents];

        Aria2File *file = [_files objectAtIndex:0];
        NSString *filePath = [file path];
        NSURL *filePathURL = [NSURL URLWithString:[[file path] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]]];
        NSArray *filePathComponents = [filePathURL pathComponents];

        if ([filePath hasPrefix:_dir]) {
            return [filePathComponents objectAtIndex:[dirComponents count]];
        } else {
            return filePath;
        }
    }

    return @"";
}

- (void)updateStatusTo:(Aria2Download *)target {
    if ([_gid isEqualToString:[target gid]]) {
        _status = [target status];
        _totalLength =[target totalLength];
        _completedLength =[target completedLength];
        _uploadLength = [target uploadLength];
        _bitfield = [target bitfield];
        _downloadSpeed = [target downloadSpeed];
        _uploadSpeed = [target uploadSpeed];
        _infoHash = [target infoHash];
        _numSeeders:[target numSeeders];
        _seeder:[target seeder];
        _pieceLength:[target pieceLength];
        _numPieces:[target numPieces];
        _connections:[target connections];
        _errorCode:[target errorCode];
        _errorMessage:[target errorMessage];
        _followedBy:[target followedBy];
        _following:[target following];
        _belongsTo:[target belongsTo];
        _dir:[target dir];
        _files:[target files];
        _bittorrent:[target bittorrent];
        _verifiedLength:[target verifiedLength];
        _verifyIntegrityPending:[target verifyIntegrityPending];

    }
}

@end

@implementation Aria2File

+ (instancetype)fileWithDictionary:(NSDictionary *)dictionary {
    return [[Aria2File alloc] initWithDictionary:dictionary];
}

- (instancetype)initWithDictionary:(id)dictionary {
    self = [super init];
    if (self) {
        _path = [dictionary objectForKey:@"path"];
        _uris = [dictionary objectForKey:@"uris"];
        _length = [dictionary objectForKey:@"length"];
        _completedLength = [dictionary objectForKey:@"completedLength"];
        _selected = [dictionary objectForKey:@"selected"];
        _index = [dictionary objectForKey:@"index"];
    }
    return self;
}

@end
