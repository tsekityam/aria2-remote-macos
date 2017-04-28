//
//  PreferencesViewController.m
//  aria2 remote
//
//  Created by Tse Kit Yam on 2/4/2017.
//  Copyright © 2017 Tse Kit Yam. All rights reserved.
//

#import "PreferencesViewController.h"

#import <AFJSONRPCClient/AFJSONRPCClient.h>

@interface PreferencesViewController ()
@property (weak) IBOutlet NSTextField *uriTextField;
@property (weak) IBOutlet NSSecureTextField *tokenTextField;
- (IBAction)testConnectionButtonDidClick:(id)sender;

@end

@implementation PreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [_uriTextField setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Host"]];
    [_tokenTextField setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Token"]];
}

- (IBAction)testConnectionButtonDidClick:(id)sender {
    AFJSONRPCClient *client = [AFJSONRPCClient clientWithEndpointURL:[NSURL URLWithString:[_uriTextField stringValue]]];
    
    [client invokeMethod:@"aria2.getVersion" success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Success"];
        [alert runModal];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert runModal];
    }];
}
@end
