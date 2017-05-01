//
//  MainWindowController.m
//  aria2 remote
//
//  Created by Tse Kit Yam on 2/4/2017.
//  Copyright © 2017 Tse Kit Yam. All rights reserved.
//

#import "MainWindowController.h"

#import "Aria2Helper.h"
#import "SourceTreeViewController.h"
#import "MainTableViewController.h"

@interface MainWindowController () <SourceTreeViewControllerDelegate>
@property SourceTreeViewController *sourceTreeViewController;
@property MainTableViewController *mainTableViewController;

- (IBAction)addButtonDidClick:(id)sender;
- (IBAction)continueButtonDidClick:(id)sender;
- (IBAction)pauseButtonDidClick:(id)sender;

@end

@implementation MainWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    for (id viewController in [[self contentViewController] childViewControllers]) {
        if ([viewController isKindOfClass:[SourceTreeViewController class]]) {
            _sourceTreeViewController = viewController;
            [_sourceTreeViewController setDelegate:self];
        } else if ([viewController isKindOfClass:[MainTableViewController class]]) {
            _mainTableViewController = viewController;
        }
    }
    
    [[self window] setTitleVisibility:NSWindowTitleHidden];
}

- (IBAction)addButtonDidClick:(id)sender {
    NSTextField *accessoryView = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 192*2, 22*5)];

    NSString *candidate = [[NSPasteboard generalPasteboard] stringForType:NSPasteboardTypeString];
    NSURL *candidateURL = [NSURL URLWithString:candidate];
    if (candidateURL && [candidateURL scheme]) {
        [accessoryView setStringValue:candidate];
    }

    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Add Uri"];
    [alert setAccessoryView:accessoryView];
    [alert beginSheetModalForWindow:[self window] completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            NSString *uri = [accessoryView stringValue];

            [[Aria2Helper defaultHelper] addUri:^(NSString *gid) {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:@"Success"];
                [alert setInformativeText:[NSString stringWithFormat:@"gid: %@", gid]];
                [alert runModal];
            } uris:@[uri]];
        }
    }];
}

- (IBAction)continueButtonDidClick:(id)sender {
    [[Aria2Helper defaultHelper] unpause:^(NSString *gid) {
        // TODO: handle result
    } gid:[_mainTableViewController selectedDownloadGID]];
}

- (IBAction)pauseButtonDidClick:(id)sender {
    [[Aria2Helper defaultHelper] pause:^(NSString *gid) {
        // TODO: handle result
    } gid:[_mainTableViewController selectedDownloadGID]];
}

- (void)sourceTreeViewController:(SourceTreeViewController *)controller selectedRowDidChangeTo:(NSInteger)row {
    switch (row) {
        case ROW_ACTIVE_DOWNLOADS:
            [_mainTableViewController setVisibleDownloadType:DownloadTypeActive];
            break;
        case ROW_WAITING_DOWNLOADS:
            [_mainTableViewController setVisibleDownloadType:DownloadTypeWaiting];
            break;
        case ROW_STOPPED_DOWNLOADS:
            [_mainTableViewController setVisibleDownloadType:DownloadTypeStopped];
            break;
        default:
            break;
    }
}

@end
