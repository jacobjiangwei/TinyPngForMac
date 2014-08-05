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
                                                  NSLog(@"POST FAIL RESPONSE:\n%d\n%@",[error code] ,operation.responseObject);
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

-(void)test
{
    NSURL *imageURL=[[NSBundle mainBundle] URLForImageResource:@"120.png"];
    NSData *imageData=[[NSData alloc]initWithContentsOfURL:imageURL];
    NSString *apikey=[NSString stringWithFormat:@"api:A18RvHJ69RisHnwg9xuTELOuUDfZIg9-"];
    NSString *base64=[apikey base64EncodedString];
    NSString *basic64=[NSString stringWithFormat:@"Basic %@",base64];
    NSDictionary *parameter=@{@"Authorization": basic64};
    
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:TINYPNG_URL]];
    [request addValue:basic64 forHTTPHeaderField:@"Authorization"];
    request.HTTPMethod=@"POST";
    [request addValue:@"image/png" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:imageData];
    
    
    AFHTTPRequestOperation *op=[[AFHTTPRequestOperationManager manager] HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"POST SUCCESS RESPONSE:\n%@",responseObject);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"POST FAIL RESPONSE:\n%d\n%@",[error code] ,operation.responseObject);
    }];
    [[AFHTTPRequestOperationManager manager].operationQueue addOperation:op];
//    
//    [self requestWithBaseURL:TINYPNG_URL para:parameter httpMethod:HttpMethodPost success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"POST SUCCESS RESPONSE:\n%@",responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"POST FAIL RESPONSE:\n%d\n%@",[error code] ,operation.responseObject);
//    }];
//
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    [manager POST:TINYPNG_URL parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        [formData appendPartWithFileData:imageData name:@"--data-binary" fileName:@"120.png" mimeType:@"image/png"];
//    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"POST SUCCESS RESPONSE:\n%@",responseObject);
//
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"POST FAIL RESPONSE:\n%d\n%@",[error code] ,operation.responseObject);
//    }];
    
}


-(void)uploadPng:(NSString *)filePath withKey:(NSString *)key
{
    NSData *pngData=[NSData dataWithContentsOfFile:filePath];
    if (pngData==nil) {
        return;
    }
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:TINYPNG_URL]];
    [request addValue:self.key forHTTPHeaderField:@"Authorization"];
    request.HTTPMethod=@"POST";
    [request addValue:@"image/png" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:pngData];
    
    
    AFHTTPRequestOperation *op=[[AFHTTPRequestOperationManager manager] HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"POST SUCCESS RESPONSE:\n%@",responseObject);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"POST FAIL RESPONSE:\n%d\n%@",[error code] ,operation.responseObject);
    }];
    [[AFHTTPRequestOperationManager manager].operationQueue addOperation:op];

}

@end
