//
//  ARAFile.h
//  ARAJSONRPCClient
//
//  Created by Tse Kit Yam on 5/2/17.
//  Copyright © 2017 Tse Kit Yam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARAFile : NSObject
@property (readonly) NSString *path;
// TODO: uris
@property (readonly) NSString *length;
@property (readonly) NSString *completedLength;
@property (readonly) NSString *selected;
@property (readonly) NSString *index;

+ (instancetype)fileWithDictionary:(NSDictionary *)dictionary;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (void)updateToFile:(ARAFile *)target;

@end
