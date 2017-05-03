//
//  ARAStatus.h
//  ARAJSONRPCClient
//
//  Created by Tse Kit Yam on 5/2/17.
//  Copyright © 2017 Tse Kit Yam. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ARAFile;
@interface ARADownload : NSObject
@property (readonly) NSString *gid;
@property (readonly) NSString *status;
@property (readonly) NSString *totalLength;
@property (readonly) NSString *completedLength;
@property (readonly) NSString *uploadLength;
@property (readonly) NSString *bitfield;
@property (readonly) NSString *downloadSpeed;
@property (readonly) NSString *uploadSpeed;
@property (readonly) NSString *infoHash;
@property (readonly) NSString *numSeeders;
@property (readonly) NSString *seeder;
@property (readonly) NSString *pieceLength;
@property (readonly) NSString *numPieces;
@property (readonly) NSString *connections;
@property (readonly) NSString *errorCode;
@property (readonly) NSString *errorMessage;
// TODO: followedBy
@property (readonly) NSString *following;
@property (readonly) NSString *belongsTo;
@property (readonly) NSString *dir;
@property (readonly) NSArray<ARAFile *> *files;
// TODO: bittorrent
@property (readonly) NSString *verifiedLength;
@property (readonly) NSString *verifyIntegrityPending;

+ (instancetype)downloadWithDictionary:(NSDictionary *)dictionary;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (void)updateToDownload:(ARADownload *)target;

- (NSString *)name;

@end
