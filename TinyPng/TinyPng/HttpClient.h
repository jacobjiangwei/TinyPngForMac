//
//  HttpClient.h
//  Xici
//
//  Created by XICI-Jacob on 10/31/13.
//
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
typedef enum HttpMethod{
    HttpMethodGet,
    HttpMethodPost,
}HttpMethod;



@interface HttpClient : NSObject
{
}

@property (nonatomic,strong)        NSString            *key;

+(HttpClient *)manager;

-(void)requestWithBaseURL:(NSString *)url
                     para:(NSDictionary *)parameters
               httpMethod:(HttpMethod)httpMethod
                  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

-(void)uploadPng:(NSString *)filePath withKey:(NSString *)key;

@end
