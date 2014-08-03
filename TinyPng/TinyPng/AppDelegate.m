//
//  AppDelegate.m
//  TinyPng
//
//  Created by Jacob Jiang on 8/3/14.
//  Copyright (c) 2014 Jacob Jiangwei. All rights reserved.
//

#import "AppDelegate.h"
#import "HttpClient.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[HttpClient manager] test];
    // Insert code here to initialize your application
}

@end
