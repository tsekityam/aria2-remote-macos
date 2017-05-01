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

@interface MainWindowController () <SourceTreeViewControllerDelegate, NSUserNotificationCenterDelegate>
@property SourceTreeViewController *sourceTreeViewController;
@property MainTableViewController *mainTableViewController;

- (IBAction)addButtonDidClick:(id)sender;
- (IBAction)continueButtonDidClick:(id)sender;
- (IBAction)pauseButtonDidClick:(id)sender;
- (IBAction)stopButtonDidClick:(id)sender;

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
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
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
                NSUserNotification *notification = [[NSUserNotification alloc] init];
                [notification setTitle:@"Success - add"];
                [notification setInformativeText:[NSString stringWithFormat:@"%@ is added", uri]];
                [notification setDeliveryDate:[NSDate date]];
                [[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:notification];
            } uris:@[uri]];
        }
    }];
}

- (IBAction)continueButtonDidClick:(id)sender {
    Aria2Download *selectedDownload = [_mainTableViewController selectedDownload];
    [[Aria2Helper defaultHelper] unpause:^(NSString *gid) {
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        [notification setTitle:@"Success - continue"];
        [notification setInformativeText:[NSString stringWithFormat:@"%@ will be continued", [selectedDownload name]]];
        [notification setDeliveryDate:[NSDate date]];
        [[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:notification];
    } gid:[selectedDownload gid]];
}

- (IBAction)pauseButtonDidClick:(id)sender {
    Aria2Download *selectedDownload = [_mainTableViewController selectedDownload];
    [[Aria2Helper defaultHelper] pause:^(NSString *gid) {
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        [notification setTitle:@"Success - pause"];
        [notification setInformativeText:[NSString stringWithFormat:@"%@ will be paused", [selectedDownload name]]];
        [notification setDeliveryDate:[NSDate date]];
        NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
        [center scheduleNotification:notification];
    } gid:[selectedDownload gid]];
}

- (IBAction)stopButtonDidClick:(id)sender {
    Aria2Download *selectedDownload = [_mainTableViewController selectedDownload];
    [[Aria2Helper defaultHelper] remove:^(NSString *gid) {
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        [notification setTitle:@"Success - stop"];
        [notification setInformativeText:[NSString stringWithFormat:@"%@ will be stopped", [selectedDownload name]]];
        [notification setDeliveryDate:[NSDate date]];
        NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
        [center scheduleNotification:notification];
    } gid:[selectedDownload gid]];
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

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

@end
