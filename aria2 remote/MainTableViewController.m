//
//  MainTableViewController.m
//  aria2 remote
//
//  Created by Tse Kit Yam on 4/29/17.
//  Copyright © 2017 Tse Kit Yam. All rights reserved.
//

#import "MainTableViewController.h"

#import <ARAJSONRPCClient/ARAJSONRPCClient.h>

@interface MainTableViewController () <NSTableViewDataSource, NSTableViewDelegate>
@property (weak) IBOutlet NSTableView *mainTableView;
@property NSArray *visibleDownloads;
@property ARAClient *client;

- (void)reloadMainTableView;

@end

@implementation MainTableViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    // Register the preference defaults early.
    NSDictionary *appDefaults = @{@"server": @"http://localhost:6800/jsonrpc",
                                  @"token": @""};
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];

    NSString *server = [[NSUserDefaults standardUserDefaults] stringForKey:@"server"];
    NSString *token= [[NSUserDefaults standardUserDefaults] stringForKey:@"token"];
    
    _client = [ARAClient clientWithURL:[NSURL URLWithString:server] token:token];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        while (true) {
            [_client updateDownloadLists];
            sleep(1);
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadMainTableView) name:ARADownloadListsDidUpdateNotification object:_client];
    
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
    ARADownload *download = [_visibleDownloads objectAtIndex:row];
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

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if ([_delegate respondsToSelector:@selector(mainTableViewController:selectedDownloadDidChangeTo:)]) {
        NSInteger selectedRow = [_mainTableView selectedRow];
        ARADownload *selectedDownload = nil;
        if (selectedRow != -1) {
            selectedDownload = [_visibleDownloads objectAtIndex:selectedRow];
        }
        [_delegate mainTableViewController:self selectedDownloadDidChangeTo:selectedDownload];
    }
}

- (void)setVisibleDownloadType:(DownloadType)type {
    if ([_delegate respondsToSelector:@selector(mainTableViewController:selectedDownloadDidChangeTo:)]) {
        [_delegate mainTableViewController:self selectedDownloadDidChangeTo:nil];
    }
    [_mainTableView selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
    switch (type) {
        case DownloadTypeActive:
            _visibleDownloads = [_client activeDownloads];
            break;
        case DownloadTypeWaiting:
            _visibleDownloads = [_client waitingDownloads];
            break;
        case DownloadTypeStopped:
            _visibleDownloads = [_client stoppedDownloads];
            break;
        default:
            break;
    }
    
    [_mainTableView reloadData];
}

- (void)reloadMainTableView {
    ARADownload *selectedDownload = [[self dataSource] mainTableViewControllerSelectedDownload:self];
    [_mainTableView reloadData];
    NSInteger indexOfSelectedDownload = [_visibleDownloads indexOfObject:selectedDownload];
    if (indexOfSelectedDownload != NSNotFound) {
        [_mainTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:indexOfSelectedDownload] byExtendingSelection:NO];
    }
}

@end
