//
//  SourceTreeViewController.h
//  aria2 remote
//
//  Created by Tse Kit Yam on 2/4/2017.
//  Copyright © 2017 Tse Kit Yam. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define ROW_HEADER_DOWNLOADS 0
#define ROW_ACTIVE_DOWNLOADS 1
#define ROW_WAITING_DOWNLOADS 2
#define ROW_STOPPED_DOWNLOADS 3
#define MAX_NUM_ROWS 4

@class SourceTreeViewController;
@protocol SourceTreeViewControllerDelegate <NSObject>
@optional
- (void)sourceTreeViewController:(SourceTreeViewController *)controller selectedRowDidChangeTo:(NSInteger)row;

@end

@interface SourceTreeViewController : NSViewController
@property (weak) id<SourceTreeViewControllerDelegate> delegate;

@end
