//
//  ARAHelper.h
//  aria2 remote
//
//  Created by Tse Kit Yam on 5/3/17.
//  Copyright © 2017 Tse Kit Yam. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ARADownload;
@class ARAFile;
@interface ARAHelper : NSObject

+ (void)updateDownlaodList:(NSMutableArray<ARADownload *> *)sourceList withDownloadList:(NSArray<ARADownload *> *)targetList;
+ (void)updateFileList:(NSMutableArray<ARAFile *> *)sourceList withFileList:(NSArray<ARAFile *> *)targetList;

+ (NSArray<ARADownload *> *)downloadsListFromArray:(NSArray<NSDictionary *> *)array;

@end
