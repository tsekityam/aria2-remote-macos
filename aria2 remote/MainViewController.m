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
            [[Aria2Helper defaultHelper] tellActive:^(NSArray *downloads) {
                if (_visibleDownloads == _activeDownloads) {

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
                } else {
                    [Aria2Helper updateDownloads:_activeDownloads to:downloads];
                }
            }];
            sleep(1);
        }
    }];

    [_tellWaitingQueue addOperationWithBlock:^{
        while (true) {
            [[Aria2Helper defaultHelper] tellWaiting:^(NSArray *downloads) {
                if (_visibleDownloads == _waitingDownloads) {
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
                } else {
                    [Aria2Helper updateDownloads:_waitingDownloads to:downloads];
                }
            } offset:0 num:100];
            sleep(1);
        }
    }];

    [_tellStoppedQueue addOperationWithBlock:^{
        while (true) {
            [[Aria2Helper defaultHelper] tellStopped:^(NSArray *downloads) {
                if (_visibleDownloads == _stoppedDownloads) {
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
                } else {
                    [Aria2Helper updateDownloads:_stoppedDownloads to:downloads];
                }
            } offset:0 num:100];
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
    result.textField.stringValue = [[_visibleDownloads objectAtIndex:row] objectForKey:[tableColumn identifier]];

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
