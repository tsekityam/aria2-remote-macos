//
//  ARAFile.m
//  ARAJSONRPCClient
//
//  Created by Tse Kit Yam on 5/2/17.
//  Copyright © 2017 Tse Kit Yam. All rights reserved.
//

#import "ARAFile.h"

@implementation ARAFile

+ (instancetype)fileWithDictionary:(NSDictionary *)dictionary {
    return [[ARAFile alloc] initWithDictionary:dictionary];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _path = [dictionary objectForKey:@"path"];
        _length = [dictionary objectForKey:@"length"];
        _completedLength = [dictionary objectForKey:@"completedLength"];
        _selected = [dictionary objectForKey:@"selected"];
        _index = [dictionary objectForKey:@"index"];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[ARAFile class]]) {
        return [_path isEqualToString:[object path]];
    }
    return [super isEqual:object];
}

- (void)updateToFile:(ARAFile *)target {
    if (![self isEqual:target]) {
        return;
    }
    _length = [target length];
    _completedLength = [target completedLength];
    _selected = [target selected];
    _index = [target index];
}

@end
