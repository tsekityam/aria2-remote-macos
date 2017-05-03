//
//  ARAStatus.m
//  ARAJSONRPCClient
//
//  Created by Tse Kit Yam on 5/2/17.
//  Copyright © 2017 Tse Kit Yam. All rights reserved.
//

#import "ARADownload.h"

#import "ARAFile.h"
#import "ARAHelper.h"

@interface ARADownload () {
    NSMutableArray<ARAFile *> *_files;
}

@end

@implementation ARADownload
@synthesize files = _files;

+ (instancetype)downloadWithDictionary:(NSDictionary *)dictionary {
    return [[ARADownload alloc] initWithDictionary:dictionary];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _gid = [dictionary objectForKey:@"gid"] ? [dictionary objectForKey:@"gid"] : @"";
        _status = [dictionary objectForKey:@"status"] ? [dictionary objectForKey:@"status"] : @"";
        _totalLength = [dictionary objectForKey:@"totalLength"] ? [dictionary objectForKey:@"totalLength"] : @"";
        _completedLength = [dictionary objectForKey:@"completedLength"] ? [dictionary objectForKey:@"completedLength"] : @"";
        _uploadLength = [dictionary objectForKey:@"uploadLength"] ? [dictionary objectForKey:@"uploadLength"] : @"";
        _bitfield = [dictionary objectForKey:@"bitfield"] ? [dictionary objectForKey:@"bitfield"] : @"";
        _downloadSpeed = [dictionary objectForKey:@"downloadSpeed"] ? [dictionary objectForKey:@"downloadSpeed"] : @"";
        _uploadSpeed = [dictionary objectForKey:@"uploadSpeed"] ? [dictionary objectForKey:@"uploadSpeed"] : @"";
        _infoHash = [dictionary objectForKey:@"infoHash"] ? [dictionary objectForKey:@"infoHash"] : @"";
        _numSeeders = [dictionary objectForKey:@"numSeeders"] ? [dictionary objectForKey:@"numSeeders"] : @"";
        _seeder = [dictionary objectForKey:@"seeder"] ? [dictionary objectForKey:@"seeder"] : @"";
        _pieceLength = [dictionary objectForKey:@"pieceLength"] ? [dictionary objectForKey:@"pieceLength"] : @"";
        _numPieces = [dictionary objectForKey:@"numPieces"] ? [dictionary objectForKey:@"numPieces"] : @"";
        _connections = [dictionary objectForKey:@"connections"] ? [dictionary objectForKey:@"connections"] : @"";
        _errorCode = [dictionary objectForKey:@"errorCode"] ? [dictionary objectForKey:@"errorCode"] : @"";
        _errorMessage = [dictionary objectForKey:@"errorMessage"] ? [dictionary objectForKey:@"errorMessage"] : @"";
        _following = [dictionary objectForKey:@"following"] ? [dictionary objectForKey:@"following"] : @"";
        _belongsTo = [dictionary objectForKey:@"belongsTo"] ? [dictionary objectForKey:@"belongsTo"] : @"";
        _dir = [dictionary objectForKey:@"dir"] ? [dictionary objectForKey:@"dir"] : @"";
        _files = [NSMutableArray array];
        _verifiedLength = [dictionary objectForKey:@"verifiedLength"] ? [dictionary objectForKey:@"verifiedLength"] : @"";
        _verifyIntegrityPending = [dictionary objectForKey:@"verifyIntegrityPending"] ? [dictionary objectForKey:@"verifyIntegrityPending"] : @"";
        
        if ([dictionary objectForKey:@"files"]) {
            for (NSDictionary *fileDictionary in [dictionary objectForKey:@"files"]) {
                ARAFile *file = [ARAFile fileWithDictionary:fileDictionary];
                [_files addObject:file];
            }
        }
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[ARADownload class]]) {
        return [_gid isEqualToString:[object gid]];
    }
    return [super isEqual:object];
}

- (void)updateToDownload:(ARADownload *)target {
    if (![self isEqual:target]) {
        return;
    }
    _status = [target status];
    _totalLength = [target totalLength];
    _completedLength = [target completedLength];
    _uploadLength = [target uploadLength];
    _bitfield = [target bitfield];
    _downloadSpeed = [target downloadSpeed];
    _uploadSpeed = [target uploadSpeed];
    _infoHash = [target infoHash];
    _numSeeders = [target numSeeders];
    _seeder = [target seeder];
    _pieceLength = [target pieceLength];
    _numPieces = [target numPieces];
    _connections = [target connections];
    _errorCode = [target errorCode];
    _following = [target following];
    _belongsTo = [target belongsTo];
    _dir = [target dir];
    [ARAHelper updateFileList:_files withFileList:[target files]];
    _verifiedLength = [target verifiedLength];
    _verifyIntegrityPending = [target verifiedLength];
}

- (NSString *)name {
    if ([_files count] > 0) {
        NSURL *dirURL = [NSURL URLWithString:_dir];
        NSArray *dirComponents = [dirURL pathComponents];
        
        ARAFile *file = [_files objectAtIndex:0];
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

@end
