//
//  ARAClient.h
//  ARAJSONRPCClient
//
//  Created by Tse Kit Yam on 5/2/17.
//  Copyright © 2017 Tse Kit Yam. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ARADownloadListsDidUpdateNotification @"ARADownloadListsDidUpdateNotification"

@class ARADownload;
@class ARAFile;
@interface ARAClient : NSObject
@property (readonly) NSArray<ARADownload *> *activeDownloads;
@property (readonly) NSArray<ARADownload *> *waitingDownloads;
@property (readonly) NSArray<ARADownload *> *stoppedDownloads;

+ (instancetype)clientWithURL:(NSURL *)url token:(NSString *)token;
+ (instancetype)clientWithURL:(NSURL *)url;

- (instancetype)initWithURL:(NSURL *)url token:(NSString *)token;
- (instancetype)initWithURL:(NSURL *)url;

- (void)updateDownloadLists;

- (void)addUri:(void (^)(NSString *gid))success failure:(void (^)(NSError *error))failure uris:(NSArray<NSString *> *)uris;
// TODO: aria2.addTorrent
// TODO: aria2.addMetalink

- (void)remove:(void (^)(NSString *gid))success failure:(void (^)(NSError *error))failure gid:(NSString *)gid;
- (void)forceRemove:(void (^)(NSString *gid))success failure:(void (^)(NSError *error))failure gid:(NSString *)gid;
- (void)pause:(void (^)(NSString *gid))success failure:(void (^)(NSError *error))failure gid:(NSString *)gid;
- (void)pauseAll:(void (^)(NSString *result))success failure:(void (^)(NSError *error))failure;
- (void)forcePause:(void (^)(NSString *gid))success failure:(void (^)(NSError *error))failure gid:(NSString *)gid;
- (void)forcePauseAll:(void (^)(NSString *result))success failure:(void (^)(NSError *error))failure;
- (void)unpause:(void (^)(NSString *gid))success failure:(void (^)(NSError *error))failure gid:(NSString *)gid;
- (void)unpauseAll:(void (^)(NSString *result))success failure:(void (^)(NSError *error))failure;

- (void)tellStatus:(void (^)(ARADownload *download))success failure:(void (^)(NSError *error))failure gid:(NSString *)gid;

// TODO: aria2.getUris
// TODO: aria2.getFiles
// TODO: aria2.getPeers
// TODO: aria2.getServers
// TODO: aria2.getUris
// TODO: aria2.getUris
// TODO: aria2.getUris

- (void)tellActive:(void (^)(NSArray *downloads))success failure:(void (^)(NSError *error))failure;
- (void)tellWaiting:(void (^)(NSArray *downloads))success failure:(void (^)(NSError *error))failure offset:(NSInteger)offset num:(NSInteger)num;
- (void)tellStopped:(void (^)(NSArray *downloads))success failure:(void (^)(NSError *error))failure offset:(NSInteger)offset num:(NSInteger)num;

// TODO: aria2.changePosition
// TODO: aria2.changeUri

// TODO: aria2.getOption
// TODO: aria2.changeOption
// TODO: aria2.getGlobalOption
// TODO: aria2.changeGlobalOption
// TODO: aria2.getGlobalStat

// TODO: aria2.purgeDownloadResult
// TODO: aria2.removeDownloadResult

- (void)getVersion:(void (^)(NSString *version, NSArray<NSString *> *enabledFeatures))success failure:(void (^)(NSError *error))failure;
// TODO: aria2.getSessionInfo

// TODO: aria2.shutdown
// TODO: aria2.forceShutdown

// TODO: aria2.saveSession

- (void)multicall:(void (^)(id result))success failure:(void (^)(NSError *error))failure methods:(NSArray<NSDictionary *> *)methods;
// TODO: system.listMethods
// TODO: system.listNotifications

@end
