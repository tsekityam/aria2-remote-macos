//
//  ARAHelper.m
//  aria2 remote
//
//  Created by Tse Kit Yam on 5/3/17.
//  Copyright © 2017 Tse Kit Yam. All rights reserved.
//

#import "ARAHelper.h"

#import "ARADownload.h"
#import "ARAFile.h"

@implementation ARAHelper

+ (void)updateDownlaodList:(NSMutableArray *)sourceList withDownloadList:(NSArray *)targetList {
    NSArray *tempSourceList = [sourceList copy];
    [sourceList removeAllObjects];
    
    for (ARADownload *target in targetList) {
        NSInteger indexOfTarget = [tempSourceList indexOfObject:target];
        if (indexOfTarget != NSNotFound) {
            ARADownload *source = [tempSourceList objectAtIndex:indexOfTarget];
            [source updateToDownload:target];
            [sourceList addObject:source];
        } else {
            [sourceList addObject:target];
        }
    }
}

+ (void)updateFileList:(NSMutableArray<ARAFile *> *)sourceList withFileList:(NSArray<ARAFile *> *)targetList {
    NSArray *tempSourceList = [sourceList copy];
    [sourceList removeAllObjects];
    
    for (ARAFile *target in targetList) {
        NSInteger indexOfTarget = [tempSourceList indexOfObject:target];
        if (indexOfTarget != NSNotFound) {
            ARAFile *source = [tempSourceList objectAtIndex:indexOfTarget];
            [source updateToFile:target];
            [sourceList addObject:source];
        } else {
            [sourceList addObject:target];
        }
    }
}

+ (NSArray<ARADownload *> *)downloadsListFromArray:(NSArray<NSDictionary *> *)array {
    NSMutableArray *downloads = [NSMutableArray array];
    
    if ([array isKindOfClass:[NSArray class]]) {
        if ([array[0] isKindOfClass:[NSArray class]]) {
            // the response object may come from system.multicall
            for (id item in array[0]) {
                if ([item isKindOfClass:[NSDictionary class]]) {
                    ARADownload *download = [ARADownload downloadWithDictionary:item];
                    [downloads addObject:download];
                }
            }
        }
    }
    
    return downloads;
}

@end
