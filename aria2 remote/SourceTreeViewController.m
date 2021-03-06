//
//  SourceTreeViewController.m
//  aria2 remote
//
//  Created by Tse Kit Yam on 2/4/2017.
//  Copyright © 2017 Tse Kit Yam. All rights reserved.
//

#import "SourceTreeViewController.h"

@interface SourceTreeViewController () <NSOutlineViewDataSource, NSOutlineViewDelegate>
@property (weak) IBOutlet NSOutlineView *outlineView;

@end

@implementation SourceTreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.

    [_outlineView setDataSource:self];
    [_outlineView setDelegate:self];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return NO;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    return MAX_NUM_ROWS;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    return [NSNumber numberWithInteger:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    if ([item integerValue] == ROW_HEADER_DOWNLOADS) {
        return NO;
    }

    return YES;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    NSTableCellView *cellView = nil;
    
    switch ([item integerValue]) {
        case ROW_HEADER_DOWNLOADS:
            cellView = [_outlineView makeViewWithIdentifier:@"HeaderCell" owner:self];
            [[cellView textField] setStringValue:@"Downloads"];
            break;
        case ROW_ACTIVE_DOWNLOADS:
            cellView = [_outlineView makeViewWithIdentifier:@"DataCell" owner:self];
            [[cellView textField] setStringValue:@"Active Downloads"];
            [[cellView imageView] setImage:[NSImage imageNamed:@"ic_play_arrow"]];
            break;
        case ROW_WAITING_DOWNLOADS:
            cellView = [_outlineView makeViewWithIdentifier:@"DataCell" owner:self];
            [[cellView textField] setStringValue:@"Waiting Downloads"];
            [[cellView imageView] setImage:[NSImage imageNamed:@"ic_pause"]];
            break;
        case ROW_STOPPED_DOWNLOADS:
            cellView = [_outlineView makeViewWithIdentifier:@"DataCell" owner:self];
            [[cellView textField] setStringValue:@"Stopped Downloads"];
            [[cellView imageView] setImage:[NSImage imageNamed:@"ic_stop"]];
            break;
        default:
            break;
    }
    return cellView;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    if ([[self delegate] respondsToSelector:@selector(sourceTreeViewController:selectedRowDidChangeTo:)]) {
        NSInteger selectedRow = [[notification object] selectedRow];
        [[self delegate] sourceTreeViewController:self selectedRowDidChangeTo:selectedRow];
    }
}

@end
