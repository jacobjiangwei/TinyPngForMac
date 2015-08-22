//
//  AppDelegate.m
//  TinyPng
//
//  Created by Jacob Jiang on 8/3/14.
//  Copyright (c) 2014 Jacob Jiangwei. All rights reserved.
//
#import "Task.h"
#import "AppDelegate.h"
#import "HttpClient.h"
#import "Base64.h"
@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
//    [[HttpClient manager] test];
    // Insert code here to initialize your application
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    if ([userDefaultes stringForKey:@"KEY"]!=nil && ![[userDefaultes stringForKey:@"KEY"] isEqualToString:@""]) {
        self.keyTextfield.stringValue=[userDefaultes stringForKey:@"KEY"];
    }
    if (self.keyTextfield.stringValue == nil || [self.keyTextfield.stringValue isEqualToString:@""]) {
        self.keyTextfield.stringValue=TINYPNGKEY;
    }
    
    taskCount=0;
    [self.logTextView insertText:@"Welcome to use this TinyPng Batch Compress Tool!!\nFeel free to contact me via email: kof2003@126.com wechat: 110773265"];
}

- (IBAction)selectFolder:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    if ([panel runModal] != NSFileHandlingPanelOKButton) return;
    self.folderPathTextfield.stringValue=[[[panel URLs] lastObject] path];
}

- (IBAction)start:(id)sender {
    key=self.keyTextfield.stringValue;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:key forKey:@"KEY"];

    folderPath=self.folderPathTextfield.stringValue;
    
    if (key==nil || [key isEqualToString:@""] || folderPath==nil || [folderPath isEqualToString:@""]) {
        NSAlert *alert =[NSAlert alertWithMessageText:@"Please select folder path" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please select folder path"];
//        [alert runModal];
        [alert beginSheetModalForWindow:self.window completionHandler:nil];
        return;
    }
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:folderPath]) {
        NSAlert *alert =[NSAlert alertWithMessageText:@"Folder not existed" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:nil];
        [alert runModal];
        return;
    }
//    self.logTextField.stringValue=[self.logTextField.stringValue stringByAppendingString:@"\n Start..."];
    [self addLog:@"Start..."];
    NSArray *allPngPath=[[NSArray alloc]initWithArray:[self findAtPath:folderPath]];
    NSLog(@"%@",allPngPath);
    NSString *apikey=[NSString stringWithFormat:@"api:%@",key];
    NSString *base64=[apikey base64EncodedString];
    keyParameter=[NSString stringWithFormat:@"Basic %@",base64];
    
    if (allTasks!=nil) {
        [allTasks removeAllObjects];
        allTasks=nil;
    }
    allTasks=[[NSMutableArray alloc]init];
    

    timer=[NSTimer timerWithTimeInterval:3 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    for (NSString *pngPath in allPngPath) {
        [self uploadPng:pngPath];
    }
}

-(void)refresh
{
    NSLog(@"Current Task : %d",taskCount);
    [self addLog:[NSString stringWithFormat:@"Current Task : %d",taskCount]];
//    self.logTextField.stringValue=[NSString stringWithFormat:@"Current task : %d",taskCount];
    if (taskCount<=0) {
        NSLog(@"目前没任务了");
        [self addLog:@"All Done"];
        for (Task *job in allTasks) {
            if (![job.downloadStatus hasPrefix:@"ok"]) {
                if ([job.remoteURL hasPrefix:@"http"]) {
                    NSLog(@"重新下载文件");
//                    [self addLog:@"Re-download files"];
                    [self downloadImage:job.originalURL remotePath:job.remoteURL];
                }
                else
                {
                    NSLog(@"重新上传文件");
//                    [self addLog:@"Re upload files"];
                    [self uploadPng:job.originalURL];
                }
            }
        }
    }
    [self.resultTableView reloadData];
}

-(NSArray *)findAtPath:(NSString *)path
{
    NSTask *task = [[NSTask alloc] init] ;
    [task setLaunchPath: @"/usr/bin/find"];
    
    NSArray *argvals = [NSArray arrayWithObjects:path,@"-name",@"*.png", nil];
    [task setArguments: argvals];
    
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    // Read the response
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] ;
    
    NSArray *result=[string componentsSeparatedByString:@"\n"];
    return  [NSArray arrayWithArray:result];
}

-(void)uploadPng:(NSString *)filePath
{
    NSData *pngData=[NSData dataWithContentsOfFile:filePath];
    if (pngData==nil) {
        return;
    }
    
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:TINYPNG_URL]];
    [request addValue:keyParameter forHTTPHeaderField:@"Authorization"];
    request.HTTPMethod=@"POST";
    [request addValue:@"image/png" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:pngData];
    taskCount++;
    AFHTTPRequestOperation *op=[[AFHTTPRequestOperationManager manager] HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"POST SUCCESS RESPONSE:\n%@",responseObject);
        NSDictionary *jsonResponse=(NSDictionary *)responseObject;
        NSString *error=[jsonResponse objectForKey:@"error"];
        NSString *message=[jsonResponse objectForKey:@"message"];
        
        Task *job=nil;
        for (Task *everyJob in allTasks) {
            if ([everyJob.originalURL isEqualToString:filePath]) {
                job=everyJob;
            }
        }
        if (job==nil) {
            job=[[Task alloc]init];
            job.originalURL=filePath;
        }
        
        if (error!=nil && ![error isEqualToString:@""]) {
            NSString *result=[NSString stringWithFormat:@"%@ %@",error,message];
            job.remoteURL=result;
        }
        else
        {
            NSDictionary *output=[jsonResponse objectForKey:@"output"];
            NSString *downloadURL=[output objectForKey:@"url"];
            NSString *ratio=[output objectForKey:@"ratio"];
            job.remoteURL=downloadURL;
            job.compressRatio=ratio;
            [self downloadImage:filePath remotePath:downloadURL];
        }
        if (![allTasks containsObject:job]) {
            [allTasks addObject:job];
        }
        taskCount--;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"POST FAIL RESPONSE:\n%ld\n%@",(long)[error code] ,operation.responseObject);
        NSDictionary *jsonResponse=(NSDictionary *)operation.responseObject;
        NSString *message=[jsonResponse objectForKey:@"message"];
        
        Task *job=nil;
        for (Task *everyJob in allTasks) {
            if ([everyJob.originalURL isEqualToString:filePath]) {
                job=everyJob;
            }
        }
        if (job==nil) {
            job=[[Task alloc]init];
            job.originalURL=filePath;
        }
        job.remoteURL=[NSString stringWithFormat:@"Upload failed: %@",message];
        if (![allTasks containsObject:job]) {
            [allTasks addObject:job];
        }
        taskCount--;
    }];

    [[AFHTTPRequestOperationManager manager].operationQueue addOperation:op];
    
}

-(void)downloadImage:(NSString *)orignalPath remotePath:(NSString *)remotePath
{
    taskCount++;
    NSMutableURLRequest *downloadRequest=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:remotePath]];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:downloadRequest];
    //requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Download Success %@ Write to %@",remotePath,orignalPath);
        NSData *newFileData=(NSData *)responseObject;
        [newFileData writeToFile:orignalPath atomically:YES];
        Task *job=nil;
        for (Task *everyJob in allTasks) {
            if ([everyJob.originalURL isEqualToString:orignalPath]) {
                job=everyJob;
            }
        }
        job.downloadStatus=[NSString stringWithFormat:@"ok: %@",job.compressRatio];
        taskCount--;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Download %@ Error : %@", remotePath ,error);
        Task *job=nil;
        for (Task *everyJob in allTasks) {
            if ([everyJob.originalURL isEqualToString:orignalPath]) {
                job=everyJob;
            }
        }
        job.downloadStatus=@"下载失败";
        taskCount--;
    }];

    [[AFHTTPRequestOperationManager manager].operationQueue addOperation:requestOperation];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [allTasks count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    Task *job=[allTasks objectAtIndex:row];
    NSString * identifier=    [tableColumn identifier];
    if (identifier.intValue==0) {
        return job.originalURL;
    }
    else if (identifier.intValue==1)
    {
        return job.remoteURL;
    }
    else
    {
        return job.downloadStatus;
    }
}

//- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
//{
//    NSLog(@"点击行数 %d",row);
//    Task *job=[allTasks objectAtIndex:row];
//    if ([job.remoteURL hasPrefix:@"http"]) {
//        NSLog(@"重新下载文件");
//        [self downloadImage:job.originalURL remotePath:job.remoteURL];
//    }
//    else
//    {
//        NSLog(@"重新上传文件");
//        [self uploadPng:job.originalURL];
//    }
//    return YES;
//}

-(void)addLog:(NSString *)log
{
    [self.logTextView insertText:[NSString stringWithFormat:@"\n%@",log]];
}
- (IBAction)signUpDeveloper:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://www.tinypng.com/developers"]];
}

@end
