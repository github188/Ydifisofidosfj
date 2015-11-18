//
//  HttpTool.m
//  JoJoStory
//
//  Created by pengfeiwang on 14-9-28.
//  Copyright (c) 2014年 WangPengfei. All rights reserved.
//

#import "HttpTool.h"
#import "AFHTTPRequestOperationManager.h"

@implementation HttpTool

static HTTPClient *manager;
static HttpTool *httpTools;

//GCD单例
+(HttpTool *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        httpTools = [[HttpTool alloc]init];
    });
    return httpTools;
}

//GCD单例
+(id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        httpTools = [super allocWithZone:zone];
        [self initManager];
    });
    return httpTools;
}

+(void)initManager
{
    NSURL *url = [NSURL URLWithString:@"http://p.easyn.com"];
    manager = [[HTTPClient alloc] initWithBaseURL:url];
    manager.requestSerializer.timeoutInterval = 10.0f;
    AFSecurityPolicy *securityPolicy = [[AFSecurityPolicy alloc] init];
    [securityPolicy setAllowInvalidCertificates:YES];
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    //[manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    manager.securityPolicy = securityPolicy;
}

-(void)JsonGetRequst:(NSString *)url parameters:(NSDictionary *) parameters
             success:(void(^)(id responseObject)) successed
             failure:(void(^)(NSError *error)) failured
{
    [manager GET:url parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        
        successed(dic);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failured(error);
    }];
}

-(void)JsonPostRequst:(NSString *)url parameters:(NSDictionary *) parameters
              success:(void(^)(id responseObject)) successed
              failure:(void(^)(NSError *error)) failured
{
    [manager POST:url parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
 
              successed(dic);
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              
              failured(error);
              
          }];
}


-(void)dealloc{
    manager = nil;
    httpTools= nil;
}

-(NSString*)dataToJSONString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

@end
