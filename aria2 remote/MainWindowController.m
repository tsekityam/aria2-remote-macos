//
//  MainWindowController.m
//  aria2 remote
//
//  Created by Tse Kit Yam on 2/4/2017.
//  Copyright © 2017 Tse Kit Yam. All rights reserved.
//

#import "MainWindowController.h"

#import "SourceTreeViewController.h"
#import "MainTableViewController.h"

#import <ARAJSONRPCClient/ARAJSONRPCClient.h>

@interface MainWindowController () <SourceTreeViewControllerDelegate, MainTableViewControllerDelegate, MainTableViewControllerDataSource, NSUserNotificationCenterDelegate>
@property (weak) IBOutlet NSToolbarItem *addButton;
@property (weak) IBOutlet NSToolbarItem *continueButton;
@property (weak) IBOutlet NSToolbarItem *pauseButton;
@property (weak) IBOutlet NSToolbarItem *stopButton;
@property SourceTreeViewController *sourceTreeViewController;
@property MainTableViewController *mainTableViewController;
@property ARADownload *selectedDownload;

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
            [_mainTableViewController setDelegate:self];
            [_mainTableViewController setDataSource:self];
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

            NSString *server = [[NSUserDefaults standardUserDefaults] stringForKey:@"server"];
            NSString *token= [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
            
            ARAClient *client = [ARAClient clientWithURL:[NSURL URLWithString:server] token:token];

            [client addUri:^(NSString *gid) {
                NSUserNotification *notification = [[NSUserNotification alloc] init];
                [notification setTitle:@"Add uri succeeded"];
                [notification setInformativeText:[NSString stringWithFormat:@"%@", uri]];
                [notification setDeliveryDate:[NSDate date]];
                [[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:notification];
            } failure:^(NSError *error) {
                NSAlert *alert = [NSAlert alertWithError:error];
                [alert runModal];
            } uris:@[uri]];
        }
    }];
}

- (IBAction)continueButtonDidClick:(id)sender {
    if (_selectedDownload == nil) {
        return;
    }
    
    NSString *server = [[NSUserDefaults standardUserDefaults] stringForKey:@"server"];
    NSString *token= [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
    
    ARAClient *client = [ARAClient clientWithURL:[NSURL URLWithString:server] token:token];
    
    [client unpause:^(NSString *gid) {
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        [notification setTitle:@"unpause succeeded"];
        [notification setInformativeText:[NSString stringWithFormat:@"%@", gid]];
        [notification setDeliveryDate:[NSDate date]];
        [[NSUserNotificationCenter defaultUserNotificationCenter] scheduleNotification:notification];

    } failure:^(NSError *error) {
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert runModal];
    } gid:[_selectedDownload gid]];
}

- (IBAction)pauseButtonDidClick:(id)sender {
    if (_selectedDownload == nil) {
        return;
    }

    NSString *server = [[NSUserDefaults standardUserDefaults] stringForKey:@"server"];
    NSString *token= [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
    
    ARAClient *client = [ARAClient clientWithURL:[NSURL URLWithString:server] token:token];

    [client pause:^(NSString *gid) {
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        [notification setTitle:@"Pause succeeded"];
        [notification setInformativeText:[NSString stringWithFormat:@"%@", gid]];
        [notification setDeliveryDate:[NSDate date]];
        NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
        [center scheduleNotification:notification];
    } failure:^(NSError *error) {
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert runModal];
    } gid:[_selectedDownload gid]];
}

- (IBAction)stopButtonDidClick:(id)sender {
    if (_selectedDownload == nil) {
        return;
    }
    
    NSString *server = [[NSUserDefaults standardUserDefaults] stringForKey:@"server"];
    NSString *token= [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
    
    ARAClient *client = [ARAClient clientWithURL:[NSURL URLWithString:server] token:token];
    [client remove:^(NSString *gid) {
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        [notification setTitle:@"Remove succeeded"];
        [notification setInformativeText:[NSString stringWithFormat:@"%@", gid]];
        [notification setDeliveryDate:[NSDate date]];
        NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
        [center scheduleNotification:notification];
    } failure:^(NSError *error) {
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert runModal];
    } gid:[_selectedDownload gid]];
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

- (void)mainTableViewController:(MainTableViewController *)controller selectedDownloadDidChangeTo:(ARADownload *)download {
    _selectedDownload = download;
    [_continueButton setEnabled:([[_selectedDownload status] isEqualToString:@"paused"])];
    [_pauseButton setEnabled:([[_selectedDownload status] isEqualToString:@"active"] || [[_selectedDownload status] isEqualToString:@"waiting"])];
    [_stopButton setEnabled:(![[_selectedDownload status] isEqualToString:@"removed"])];
}

- (ARADownload *)mainTableViewControllerSelectedDownload:(MainTableViewController *)controller {
    return _selectedDownload;
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

@end
