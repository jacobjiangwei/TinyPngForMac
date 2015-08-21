//
//  HttpClient.m
//  Xici
//
//  Created by XICI-Jacob on 10/31/13.
//
//

#import "HttpClient.h"
#import "Base64.h"
static HttpClient *_sharedMangaer=nil;

@implementation HttpClient


+(HttpClient *)manager
{
    if (!_sharedMangaer) {
        _sharedMangaer=[[HttpClient alloc]init];
    }
    return _sharedMangaer;
}

- (id)init
{
    self = [super init];
    if(self)
    {
    }
    return self;
}

-(void)requestWithBaseURL:(NSString *)url
                     para:(NSDictionary *)parameters
               httpMethod:(HttpMethod)httpMethod
                  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    if (httpMethod==HttpMethodPost) {
        [[AFHTTPRequestOperationManager manager] POST:url
                                           parameters:parameters
                                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                  NSLog(@"POST SUCCESS RESPONSE:\n%@",responseObject);
                                                  success(operation,responseObject);
                                              }
                                              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                  NSLog(@"POST FAIL RESPONSE:\n%ld\n%@",(long)[error code] ,operation.responseObject);
                                                  failure(operation,error);
                                              }];
    }else if (httpMethod==HttpMethodGet)
    {
        [[AFHTTPRequestOperationManager manager] GET:url
                                          parameters:parameters
                                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                 NSLog(@"GET SUCCESS RESPONSE:\n%@",responseObject);
                                                 success(operation,responseObject);
                                             }
                                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 NSLog(@"GET FAIL RESPONSE:\n%@\n%@",[error description] ,operation.responseObject);
                                                 failure(operation,error);
                                             }];
    }
}


@end
