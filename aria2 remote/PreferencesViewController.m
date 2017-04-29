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
@property (weak) IBOutlet NSTextField *serverTextField;
@property (weak) IBOutlet NSSecureTextField *tokenTextField;
- (IBAction)testConnectionButtonDidClick:(id)sender;

@end

@implementation PreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [_serverTextField setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Server"]];
    [_tokenTextField setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"Token"]];
}

- (IBAction)testConnectionButtonDidClick:(id)sender {
    NSString *server = [_serverTextField stringValue];
    NSString *token = [_tokenTextField stringValue];
    
    NSMutableArray *parameters = [NSMutableArray array];
    
    if ([token length] > 0) {
        [parameters addObject:[NSString stringWithFormat:@"token:%@", token]];
    }
    
    AFJSONRPCClient *client = [AFJSONRPCClient clientWithEndpointURL:[NSURL URLWithString:server]];
    [client invokeMethod:@"aria2.getVersion" withParameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Success"];
        [alert runModal];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert runModal];
    }];
}
@end
