//
//  AppDelegate.h
//  TinyPng
//
//  Created by Jacob Jiang on 8/3/14.
//  Copyright (c) 2014 Jacob Jiangwei. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate,NSTableViewDataSource,NSTableViewDelegate>
{
    NSString                    *folderPath;
    NSString                    *key;
    NSString                    *keyParameter;
    NSMutableArray         *allTasks;
    NSTimer *timer;
    int                             taskCount;
}
@property (weak) IBOutlet NSTextField *folderPathTextfield;
@property (weak) IBOutlet NSTextField *keyTextfield;
//@property (weak) IBOutlet NSTextField *errorMsgLabel;
//@property (weak) IBOutlet NSProgressIndicator *activity;
@property (weak) IBOutlet NSTableView *resultTableView;
//@property (weak) IBOutlet NSTextField *logTextField;
@property (unsafe_unretained) IBOutlet NSTextView *logTextView;


@property (assign) IBOutlet NSWindow *window;
- (IBAction)selectFolder:(id)sender;
- (IBAction)start:(id)sender;

@end
