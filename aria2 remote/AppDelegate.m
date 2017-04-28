//
//  AppDelegate.m
//  aria2 remote
//
//  Created by Tse Kit Yam on 1/4/2017.
//  Copyright © 2017 Tse Kit Yam. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    // Register the preference defaults early.
    NSDictionary *appDefaults = @{@"Host": @"http://localhost:6800/jsonrpc",
                                  @"Token": @""};
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
