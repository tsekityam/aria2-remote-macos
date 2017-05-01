//
//  MainTableViewController.h
//  aria2 remote
//
//  Created by Tse Kit Yam on 4/29/17.
//  Copyright © 2017 Tse Kit Yam. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, DownloadType) {
    DownloadTypeActive,
    DownloadTypeWaiting,
    DownloadTypeStopped
};

@class Aria2Download;
@interface MainTableViewController : NSViewController

- (void)setVisibleDownloadType:(DownloadType)type;

- (Aria2Download *)selectedDownload;

@end
