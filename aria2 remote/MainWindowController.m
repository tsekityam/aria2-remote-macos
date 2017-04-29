//
//  MainWindowController.m
//  aria2 remote
//
//  Created by Tse Kit Yam on 2/4/2017.
//  Copyright © 2017 Tse Kit Yam. All rights reserved.
//

#import "MainWindowController.h"

#import "Aria2Helper.h"

@interface MainWindowController ()
- (IBAction)addButtonDidClick:(id)sender;

@end

@implementation MainWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
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
@end
