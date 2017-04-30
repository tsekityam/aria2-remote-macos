//
//  MainViewController.m
//  aria2 remote
//
//  Created by Tse Kit Yam on 4/29/17.
//  Copyright © 2017 Tse Kit Yam. All rights reserved.
//

#import "MainViewController.h"

#import "Aria2Helper.h"

@interface MainViewController () <NSTableViewDataSource, NSTableViewDelegate>
@property (weak) IBOutlet NSTableView *mainTableView;

@property NSArray *visibleDownloads;

@property NSMutableArray *activeDownloads;
@property NSMutableArray *waitingDownloads;
@property NSMutableArray *stoppedDownloads;
@property NSOperationQueue *tellActiveQueue;
@property NSOperationQueue *tellWaitingQueue;
@property NSOperationQueue *tellStoppedQueue;

- (void)sourceTreeViewSelectionDidChange:(NSNotification *)notifiication;

@end

@implementation MainViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _activeDownloads = [NSMutableArray array];
        _waitingDownloads = [NSMutableArray array];
        _stoppedDownloads = [NSMutableArray array];
        _tellActiveQueue = [[NSOperationQueue alloc] init];
        _tellWaitingQueue = [[NSOperationQueue alloc] init];
        _tellStoppedQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _activeDownloads = [NSMutableArray array];
        _waitingDownloads = [NSMutableArray array];
        _stoppedDownloads = [NSMutableArray array];
        _tellActiveQueue = [[NSOperationQueue alloc] init];
        _tellWaitingQueue = [[NSOperationQueue alloc] init];
        _tellStoppedQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.

    [_tellActiveQueue addOperationWithBlock:^{
        while (true) {
            if (_visibleDownloads == _activeDownloads) {
                [[Aria2Helper defaultHelper] tellActive:^(NSArray *downloads) {

                    NSInteger selectedRow = [_mainTableView selectedRow];
                    Aria2Download *selectedDownload = nil;

                    if (selectedRow != -1) {
                        selectedDownload = [_activeDownloads objectAtIndex:selectedRow];
                    }

                    [Aria2Helper updateDownloads:_activeDownloads to:downloads];

                    NSInteger indexOfSelectedDownload = [_activeDownloads indexOfObject:selectedDownload];

                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [_mainTableView reloadData];
                        if (indexOfSelectedDownload != NSNotFound) {
                            [_mainTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:indexOfSelectedDownload] byExtendingSelection:NO];
                        }
                    }];
                }];
            }
            sleep(1);
        }
    }];

    [_tellWaitingQueue addOperationWithBlock:^{
        while (true) {
            if (_visibleDownloads == _waitingDownloads) {
                [[Aria2Helper defaultHelper] tellWaiting:^(NSArray *downloads) {
                    NSInteger selectedRow = [_mainTableView selectedRow];
                    Aria2Download *selectedDownload = nil;

                    if (selectedRow != -1) {
                        selectedDownload = [_waitingDownloads objectAtIndex:selectedRow];
                    }

                    [Aria2Helper updateDownloads:_waitingDownloads to:downloads];

                    NSInteger indexOfSelectedDownload = [_waitingDownloads indexOfObject:selectedDownload];

                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [_mainTableView reloadData];
                        if (indexOfSelectedDownload != NSNotFound) {
                            [_mainTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:indexOfSelectedDownload] byExtendingSelection:NO];
                        }
                    }];
                } offset:0 num:100];
            }
            sleep(1);
        }
    }];

    [_tellStoppedQueue addOperationWithBlock:^{
        while (true) {
            if (_visibleDownloads == _stoppedDownloads) {
                [[Aria2Helper defaultHelper] tellStopped:^(NSArray *downloads) {
                    NSInteger selectedRow = [_mainTableView selectedRow];
                    Aria2Download *selectedDownload = nil;

                    if (selectedRow != -1) {
                        selectedDownload = [_stoppedDownloads objectAtIndex:selectedRow];
                    }

                    [Aria2Helper updateDownloads:_stoppedDownloads to:downloads];

                    NSInteger indexOfSelectedDownload = [_stoppedDownloads indexOfObject:selectedDownload];

                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [_mainTableView reloadData];
                        if (indexOfSelectedDownload != NSNotFound) {
                            [_mainTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:indexOfSelectedDownload] byExtendingSelection:NO];
                        }
                    }];
                } offset:0 num:100];
            }
            sleep(1);
        }
    }];

    _visibleDownloads = _activeDownloads;

    [_mainTableView setDataSource:self];
    [_mainTableView setDelegate:self];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sourceTreeViewSelectionDidChange:) name:@"SoureTreeViewControllerSelectionDidChange" object:nil];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_visibleDownloads count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // Retrieve to get the @"MyView" from the pool or,
    // if no version is available in the pool, load the Interface Builder version
    NSTableCellView *result = [tableView makeViewWithIdentifier:[tableColumn identifier] owner:self];

    // Set the stringValue of the cell's text field to the nameArray value at row
    Aria2Download *download = [_visibleDownloads objectAtIndex:row];
    if ([[tableColumn identifier] isEqualToString:@"gid"]) {
        [[result textField] setStringValue:[download gid]];
    } else if ([[tableColumn identifier] isEqualToString:@"status"]) {
        [[result textField] setStringValue:[download status]];
    } else if ([[tableColumn identifier] isEqualToString:@"totalLength"]) {
        [[result textField] setStringValue:[download totalLength]];
    } else if ([[tableColumn identifier] isEqualToString:@"completedLength"]) {
        [[result textField] setStringValue:[download completedLength]];
    } else if ([[tableColumn identifier] isEqualToString:@"uploadLength"]) {
        [[result textField] setStringValue:[download uploadLength]];
    } else if ([[tableColumn identifier] isEqualToString:@"bitfield"]) {
        [[result textField] setStringValue:[download bitfield]];
    } else if ([[tableColumn identifier] isEqualToString:@"downloadSpeed"]) {
        [[result textField] setStringValue:[download downloadSpeed]];
    } else if ([[tableColumn identifier] isEqualToString:@"uploadSpeed"]) {
        [[result textField] setStringValue:[download uploadSpeed]];
    } else if ([[tableColumn identifier] isEqualToString:@"infoHash"]) {
        [[result textField] setStringValue:[download infoHash]];
    } else if ([[tableColumn identifier] isEqualToString:@"numSeeders"]) {
        [[result textField] setStringValue:[download numSeeders]];
    } else if ([[tableColumn identifier] isEqualToString:@"seeder"]) {
        [[result textField] setStringValue:[download seeder]];
    } else if ([[tableColumn identifier] isEqualToString:@"pieceLength"]) {
        [[result textField] setStringValue:[download pieceLength]];
    } else if ([[tableColumn identifier] isEqualToString:@"numPieces"]) {
        [[result textField] setStringValue:[download numPieces]];
    } else if ([[tableColumn identifier] isEqualToString:@"connections"]) {
        [[result textField] setStringValue:[download connections]];
    } else if ([[tableColumn identifier] isEqualToString:@"errorCode"]) {
        [[result textField] setStringValue:[download errorCode]];
    } else if ([[tableColumn identifier] isEqualToString:@"errorMessage"]) {
        [[result textField] setStringValue:[download errorMessage]];
    } else if ([[tableColumn identifier] isEqualToString:@"followedBy"]) {
        [[result textField] setStringValue:[download followedBy]];
    } else if ([[tableColumn identifier] isEqualToString:@"following"]) {
        [[result textField] setStringValue:[download following]];
    } else if ([[tableColumn identifier] isEqualToString:@"belongsTo"]) {
        [[result textField] setStringValue:[download belongsTo]];
    } else if ([[tableColumn identifier] isEqualToString:@"dir"]) {
        [[result textField] setStringValue:[download dir]];
    } else if ([[tableColumn identifier] isEqualToString:@"verifiedLength"]) {
        [[result textField] setStringValue:[download verifiedLength]];
    } else if ([[tableColumn identifier] isEqualToString:@"verifyIntegrityPending"]) {
        [[result textField] setStringValue:[download verifyIntegrityPending]];
    } else if ([[tableColumn identifier] isEqualToString:@"name"]) {
        [[result textField] setStringValue:[download name]];
    }

    // Return the result
    return result;
}

- (void)sourceTreeViewSelectionDidChange:(NSNotification *)notifiication {
    [_mainTableView selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
    switch ([[[notifiication userInfo] objectForKey:@"selectedRow"] integerValue]) {
        case 1:
            _visibleDownloads = _activeDownloads;
            break;
        case 2:
            _visibleDownloads = _waitingDownloads;
            break;
        case 3:
            _visibleDownloads = _stoppedDownloads;
            break;
        default:
            break;
    }
}

@end
