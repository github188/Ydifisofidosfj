//
//  HttpTool.h
//  JoJoStory
//
//  Created by pengfeiwang on 14-9-28.
//  Copyright (c) 2014年 WangPengfei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPClient.h"

@interface HttpTool : NSObject

//http请求单例
+(HttpTool *)shareInstance;

//Get请求JSON数据方法
-(void)JsonGetRequst:(NSString *)url parameters:(NSDictionary *) parameters
             success:(void(^)(id responseObject)) successed
             failure:(void(^)(NSError *error)) failured;

//Post请求JSON数据方法
-(void)JsonPostRequst:(NSString *)url parameters:(NSDictionary *) parameters
              success:(void(^)(id responseObject)) successed
              failure:(void(^)(NSError *error)) failured;



@end