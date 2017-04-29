//
//  PreferencesViewController.m
//  aria2 remote
//
//  Created by Tse Kit Yam on 2/4/2017.
//  Copyright © 2017 Tse Kit Yam. All rights reserved.
//

#import "PreferencesViewController.h"

#import "Aria2Helper.h"

@interface PreferencesViewController ()
@property (weak) IBOutlet NSTextField *serverTextField;
@property (weak) IBOutlet NSSecureTextField *tokenTextField;
- (IBAction)testConnectionButtonDidClick:(id)sender;
- (IBAction)cancelButtonDidClick:(id)sender;
- (IBAction)okButtonDidClick:(id)sender;

@end

@implementation PreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [_serverTextField setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"server"]];
    [_tokenTextField setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"token"]];
}

- (IBAction)testConnectionButtonDidClick:(id)sender {
    NSString *server = [_serverTextField stringValue];
    NSString *token = [_tokenTextField stringValue];
    
    Aria2Helper *helper = [[Aria2Helper alloc] initWithServer:server token:token];
    [helper getVersion:^(NSString *version, NSArray *enabledFeatures) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Success"];
        [alert setInformativeText:[NSString stringWithFormat:@"version: %@\nenabled features: %@", version, [enabledFeatures componentsJoinedByString:@", "]]];
        [alert runModal];
    }];
}

- (IBAction)cancelButtonDidClick:(id)sender {
    [[[self view] window] close];
}

- (IBAction)okButtonDidClick:(id)sender {
    NSString *server = [_serverTextField stringValue];
    NSString *token = [_tokenTextField stringValue];

    [[NSUserDefaults standardUserDefaults] setValue:server forKey:@"server"];
    [[NSUserDefaults standardUserDefaults] setValue:token forKey:@"token"];
    
    [[Aria2Helper defaultHelper] setServer:server token:token];

    [[[self view] window] close];
}

@end
