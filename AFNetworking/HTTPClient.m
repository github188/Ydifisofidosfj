//
//  HTTPClient.m
//  microcoordinate
//
//  Created by zhou on 15/10/29.
//  Copyright © 2015年 corpro. All rights reserved.
//

#import "HTTPClient.h"

@implementation HTTPClient
//- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)request
//                                                    success:(void (^)(AFHTTPRequestOperation *operation,id responseObject))success
//                                                    failure:(void (^)(AFHTTPRequestOperation *operation,NSError *error))failure{
//    
//    NSLog(@"request--%@",request);
//    
//    NSMutableURLRequest *modifiedRequest = request.mutableCopy;
//    AFNetworkReachabilityManager *reachability = self.reachabilityManager;
//    
//    if (!reachability.isReachable){
//        modifiedRequest.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
//    }else{
//        modifiedRequest.cachePolicy = NSURLRequestReloadIgnoringCacheData;
//    }
//    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    if ([request.HTTPMethod isEqualToString:@"GET"]){
//        
//        NSString* filename= [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",[request.URL baseURL]]];
//        NSString* etag = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
//        if (etag != nil){
//            
//            NSMutableDictionary* mDict = [modifiedRequest.allHTTPHeaderFields mutableCopy];
//            [mDict setObject:etag forKey:@"If-None-Match"];
//            modifiedRequest.allHTTPHeaderFields = mDict;
//        }
//    }
//    
//    return [super HTTPRequestOperationWithRequest:modifiedRequest
//                                          success:success
//                                          failure:failure];
//}
//
//- (id)cachedResponseObject:(AFHTTPRequestOperation *)operation{
//    
//    NSCachedURLResponse* cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:operation.request];
//    AFHTTPResponseSerializer* serializer = [AFJSONResponseSerializer serializer];
//    id responseObject = [serializer responseObjectForResponse:cachedResponse.response data:cachedResponse.data error:nil];
//    return responseObject;
//}

@end
