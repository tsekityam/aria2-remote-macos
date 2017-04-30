//
//  Aria2Helper.h
//  aria2 remote
//
//  Created by Tse Kit Yam on 4/29/17.
//  Copyright © 2017 Tse Kit Yam. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Aria2Download;
@interface Aria2Helper : NSObject

+ (instancetype)defaultHelper;

+ (instancetype)helperWithServer:(NSString *)server;
+ (instancetype)helperWithServer:(NSString *)server token:(NSString *)token;

+ (void)updateDownloads:(NSMutableArray<Aria2Download *> *)sourceDownloads to:(NSArray<Aria2Download *> *)targetDownloads;

- (instancetype)initWithServer:(NSString *)server;
- (instancetype)initWithServer:(NSString *)server token:(NSString *)token;

- (void)setServer:(NSString *)server token:(NSString *)token;

- (void)addUri:(void (^)(NSString *gid))success uris:(NSArray *)uris;
- (void)getVersion:(void (^)(NSString *version, NSArray *enabledFeatures))success;
- (void)tellActive:(void (^)(NSArray *downloads))success failure:(void (^)(NSError *error))failure;
- (void)tellWaiting:(void (^)(NSArray *downloads))success failure:(void (^)(NSError *error))failure offset:(NSInteger)offset num:(NSInteger)num;
- (void)tellStopped:(void (^)(NSArray *downloads))success failure:(void (^)(NSError *error))failure offset:(NSInteger)offset num:(NSInteger)num;

@end

@class Aria2File;
@interface Aria2Download : NSObject
@property NSString *gid;
@property NSString *status;
@property NSString *totalLength;
@property NSString *completedLength;
@property NSString *uploadLength;
@property NSString *bitfield;
@property NSString *downloadSpeed;
@property NSString *uploadSpeed;
@property NSString *infoHash;
@property NSString *numSeeders;
@property NSString *seeder;
@property NSString *pieceLength;
@property NSString *numPieces;
@property NSString *connections;
@property NSString *errorCode;
@property NSString *errorMessage;
@property NSString *followedBy;
@property NSString *following;
@property NSString *belongsTo;
@property NSString *dir;
@property NSArray<Aria2File *> *files;
@property NSDictionary *bittorrent;
@property NSString *verifiedLength;
@property NSString *verifyIntegrityPending;

+ (instancetype)downloadWithStatus:(id)status;

- (instancetype)initWithStatus:(id)status;

- (NSString *)name;

@end

@interface Aria2File : NSObject
@property NSString *path;
@property NSArray *uris;
@property NSString *length;
@property NSString *completedLength;
@property NSString *selected;
@property NSString *index;

+ (instancetype)fileWithDictionary:(NSDictionary *)dictionary;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
