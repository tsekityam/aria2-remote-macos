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

@property NSArray *activeDownloads;
@property NSArray *waitingDownloads;
@property NSArray *stoppedDownloads;
@property NSOperationQueue *tellActiveQueue;
@property NSOperationQueue *tellWaitingQueue;
@property NSOperationQueue *tellStoppedQueue;

- (void)sourceTreeViewSelectionDidChange:(NSNotification *)notifiication;

@end

@implementation MainViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _tellActiveQueue = [[NSOperationQueue alloc] init];
        _tellWaitingQueue = [[NSOperationQueue alloc] init];
        _tellStoppedQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
                _activeDownloads = downloads;
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [_mainTableView reloadData];
                }];
            }];
            sleep(1);
        }
    }];

    [_tellWaitingQueue addOperationWithBlock:^{
        while (true) {
            [[Aria2Helper defaultHelper] tellWaiting:^(NSArray *downloads) {
                _waitingDownloads = downloads;
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [_mainTableView reloadData];
                }];
            } offset:0 num:100];
            sleep(1);
        }
    }];

    [_tellStoppedQueue addOperationWithBlock:^{
        while (true) {
            [[Aria2Helper defaultHelper] tellStopped:^(NSArray *downloads) {
                _stoppedDownloads = downloads;
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [_mainTableView reloadData];
                }];
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
