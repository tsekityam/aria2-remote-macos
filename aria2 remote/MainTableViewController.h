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

@class ARADownload;
@class MainTableViewController;
@protocol MainTableViewControllerDelegate <NSObject>
@optional
- (void)mainTableViewController:(MainTableViewController *)controller selectedDownloadDidChangeTo:(ARADownload *)download;

@end

@protocol MainTableViewControllerDataSource <NSObject>
@required
- (ARADownload *)mainTableViewControllerSelectedDownload:(MainTableViewController *)controller;

@end

@interface MainTableViewController : NSViewController
@property (weak) id<MainTableViewControllerDelegate> delegate;
@property (weak) id<MainTableViewControllerDataSource> dataSource;

- (void)setVisibleDownloadType:(DownloadType)type;

@end
