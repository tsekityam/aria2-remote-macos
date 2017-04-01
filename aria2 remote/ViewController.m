//
//  ViewController.m
//  aria2 remote
//
//  Created by Tse Kit Yam on 1/4/2017.
//  Copyright © 2017 Tse Kit Yam. All rights reserved.
//

#import "ViewController.h"

#import <AFJSONRPCClient/AFJSONRPCClient.h>

@interface ViewController ()
@property (weak) IBOutlet NSTextField *urlTextField;
- (IBAction)getVersion:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


- (IBAction)getVersion:(id)sender {
    AFJSONRPCClient *client = [AFJSONRPCClient clientWithEndpointURL:[NSURL URLWithString:[_urlTextField stringValue]]];
    
    [client invokeMethod:@"aria2.getVersion" success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Success"];
        [alert setInformativeText:[NSString stringWithFormat:@"%@", responseObject]];
        [alert runModal];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSAlert *alert = [NSAlert alertWithError:error];
        [alert runModal];
    }];
}
@end
