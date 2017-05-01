//
//  MainTableViewController.m
//  aria2 remote
//
//  Created by Tse Kit Yam on 4/29/17.
//  Copyright © 2017 Tse Kit Yam. All rights reserved.
//

#import "MainTableViewController.h"

#import "Aria2Helper.h"

@interface MainTableViewController () <NSTableViewDataSource, NSTableViewDelegate>
@property (weak) IBOutlet NSTableView *mainTableView;

@property NSArray *visibleDownloads;

@property NSMutableArray *activeDownloads;
@property NSMutableArray *waitingDownloads;
@property NSMutableArray *stoppedDownloads;
@property NSOperationQueue *tellQueue;

@end

@implementation MainTableViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _activeDownloads = [NSMutableArray array];
        _waitingDownloads = [NSMutableArray array];
        _stoppedDownloads = [NSMutableArray array];
        _tellQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _activeDownloads = [NSMutableArray array];
        _waitingDownloads = [NSMutableArray array];
        _stoppedDownloads = [NSMutableArray array];
        _tellQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [_tellQueue addOperationWithBlock:^{
        while (true) {
            [[Aria2Helper defaultHelper] tell:^(NSArray *downloads) {
                NSInteger selectedRow = [_mainTableView selectedRow];
                Aria2Download *selectedDownload = nil;

                if (selectedRow != -1) {
                    selectedDownload = [_visibleDownloads objectAtIndex:selectedRow];
                }

                [Aria2Helper updateDownloads:_activeDownloads to:downloads[0]];
                [Aria2Helper updateDownloads:_waitingDownloads to:downloads[1]];
                [Aria2Helper updateDownloads:_stoppedDownloads to:downloads[2]];

                NSInteger indexOfSelectedDownload = [_visibleDownloads indexOfObject:selectedDownload];

                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [_mainTableView reloadData];
                    if (indexOfSelectedDownload != NSNotFound) {
                        [_mainTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:indexOfSelectedDownload] byExtendingSelection:NO];
                    }
                }];
            } failure:^(NSError *error) {
            }];
            sleep(1);
        }
    }];

    _visibleDownloads = _activeDownloads;

    [_mainTableView setDataSource:self];
    [_mainTableView setDelegate:self];
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

- (void)setVisibleDownloadType:(DownloadType)type {
    switch (type) {
        case DownloadTypeActive:
            _visibleDownloads = _activeDownloads;
            break;
        case DownloadTypeWaiting:
            _visibleDownloads = _waitingDownloads;
            break;
        case DownloadTypeStopped:
            _visibleDownloads = _stoppedDownloads;
            break;
        default:
            break;
    }
}

- (NSString *)selectedDownloadGID {
    return [[_visibleDownloads objectAtIndex:[_mainTableView selectedRow]] gid];
}

@end
