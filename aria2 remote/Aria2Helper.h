//
//  Aria2Helper.h
//  aria2 remote
//
//  Created by Tse Kit Yam on 4/29/17.
//  Copyright © 2017 Tse Kit Yam. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Aria2Helper : NSObject

+ (instancetype)helperWithServer:(NSString *)server;
+ (instancetype)helperWithServer:(NSString *)server token:(NSString *)token;

- (instancetype)initWithServer:(NSString *)server;
- (instancetype)initWithServer:(NSString *)server token:(NSString *)token;

- (void)getVersion;
@end
