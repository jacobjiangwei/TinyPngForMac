//
//  Task.h
//  TinyPng
//
//  Created by Jiang Jacob on 8/5/14.
//  Copyright (c) 2014 Jacob Jiangwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Task : NSObject


@property (nonatomic,strong)        NSString *originalURL;
@property (nonatomic,strong)        NSString *remoteURL;
@property (nonatomic,strong)        NSString *downloadStatus;
@property (nonatomic,strong)        NSString *compressRatio;

@end
