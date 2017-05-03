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
    NSView *view = [tableView makeViewWithIdentifier:[tableColumn identifier] owner:self];
    
    // Set the stringValue of the cell's text field to the nameArray value at row
    ARADownload *download = [_visibleDownloads objectAtIndex:row];
    if ([[tableColumn identifier] isEqualToString:@"gid"]) {
        [[(NSTableCellView *)view textField] setStringValue:[download gid]];
    } else if ([[tableColumn identifier] isEqualToString:@"status"]) {
        [[(NSTableCellView *)view textField] setStringValue:[download status]];
    } else if ([[tableColumn identifier] isEqualToString:@"totalLength"]) {
        [[(NSTableCellView *)view textField] setStringValue:[download totalLength]];
    } else if ([[tableColumn identifier] isEqualToString:@"completedLength"]) {
        [[(NSTableCellView *)view textField] setStringValue:[download completedLength]];
    } else if ([[tableColumn identifier] isEqualToString:@"uploadLength"]) {
        [[(NSTableCellView *)view textField] setStringValue:[download uploadLength]];
    } else if ([[tableColumn identifier] isEqualToString:@"bitfield"]) {
        [[(NSTableCellView *)view textField] setStringValue:[download bitfield]];
    } else if ([[tableColumn identifier] isEqualToString:@"downloadSpeed"]) {
        [[(NSTableCellView *)view textField] setStringValue:[download downloadSpeed]];
    } else if ([[tableColumn identifier] isEqualToString:@"uploadSpeed"]) {
        [[(NSTableCellView *)view textField] setStringValue:[download uploadSpeed]];
    } else if ([[tableColumn identifier] isEqualToString:@"infoHash"]) {
        [[(NSTableCellView *)view textField] setStringValue:[download infoHash]];
    } else if ([[tableColumn identifier] isEqualToString:@"numSeeders"]) {
        [[(NSTableCellView *)view textField] setStringValue:[download numSeeders]];
    } else if ([[tableColumn identifier] isEqualToString:@"seeder"]) {
        [[(NSTableCellView *)view textField] setStringValue:[download seeder]];
    } else if ([[tableColumn identifier] isEqualToString:@"pieceLength"]) {
        [[(NSTableCellView *)view textField] setStringValue:[download pieceLength]];
    } else if ([[tableColumn identifier] isEqualToString:@"numPieces"]) {
        [[(NSTableCellView *)view textField] setStringValue:[download numPieces]];
    } else if ([[tableColumn identifier] isEqualToString:@"connections"]) {
        [[(NSTableCellView *)view textField] setStringValue:[download connections]];
    } else if ([[tableColumn identifier] isEqualToString:@"errorCode"]) {
        [[(NSTableCellView *)view textField] setStringValue:[download errorCode]];
    } else if ([[tableColumn identifier] isEqualToString:@"errorMessage"]) {
        [[(NSTableCellView *)view textField] setStringValue:[download errorMessage]];
    } else if ([[tableColumn identifier] isEqualToString:@"following"]) {
        [[(NSTableCellView *)view textField] setStringValue:[download following]];
    } else if ([[tableColumn identifier] isEqualToString:@"belongsTo"]) {
        [[(NSTableCellView *)view textField] setStringValue:[download belongsTo]];
    } else if ([[tableColumn identifier] isEqualToString:@"dir"]) {
        [[(NSTableCellView *)view textField] setStringValue:[download dir]];
    } else if ([[tableColumn identifier] isEqualToString:@"verifiedLength"]) {
        [[(NSTableCellView *)view textField] setStringValue:[download verifiedLength]];
    } else if ([[tableColumn identifier] isEqualToString:@"verifyIntegrityPending"]) {
        [[(NSTableCellView *)view textField] setStringValue:[download verifyIntegrityPending]];
    } else if ([[tableColumn identifier] isEqualToString:@"name"]) {
        [[(NSTableCellView *)view textField] setStringValue:[download name]];
    } else if ([[tableColumn identifier] isEqualToString:@"completedPercentage"]) {
        [(NSProgressIndicator *)view setMaxValue:[[download totalLength] doubleValue]];
        [(NSProgressIndicator *)view setDoubleValue:[[download completedLength] doubleValue]];
    }
    
    // Return the result
    return view;
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
