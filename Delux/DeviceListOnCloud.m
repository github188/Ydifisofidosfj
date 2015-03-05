//
//  DeviceListOnCloud.m
//  IOTCamViewer
//
//  Created by TUTK_MacMini2 on 14/4/22.
//  Copyright (c) 2014年 TUTK. All rights reserved.
//

#import "DeviceListOnCloud.h"

@implementation DeviceListOnCloud

-(void)uploadDeviceList:(NSMutableArray *)dev_list userID:(NSString *)user_id userPWD:(NSString *)user_pwd {

    NSDictionary *requestDic = [[NSDictionary alloc] initWithObjectsAndKeys:
                                dev_list,@"RECORD",
                                nil];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requestDic
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *hostString = @"https://p2pcamweb.tutk.com/P2PCamWeb/upList.php";
    
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL URLWithString:hostString]];

    NSString *post = [NSString stringWithFormat: @"account=%@&passwd=%@&upjson=%@", user_id, user_pwd, jsonString];
    NSData *postData = [post dataUsingEncoding: NSUTF8StringEncoding];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

-(void)downloadDeviceList_id:(NSString *)user_id userPWD:(NSString *)user_pwd {
    
    NSString *hostString = @"https://p2pcamweb.tutk.com/P2PCamWeb/downList.php";
    
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL URLWithString:hostString]];
    
    NSString *post = [NSString stringWithFormat: @"account=%@&passwd=%@", user_id, user_pwd];
    NSData *postData = [post dataUsingEncoding: NSUTF8StringEncoding];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

-(void)syncDeviceUID:(NSString *)cameraUID deviceName:(NSString *)cameraName userID:(NSString *)userID PWD:(NSString*)userPWD {
    NSDictionary *dict = @{@"cmd": @"update", @"usr": userID, @"pwd": userPWD, @"uid": cameraUID, @"name":cameraName};
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *hostString = @"http://p2pcamweb.tutk.com/DeviceCloud/api.php";
    
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL URLWithString:hostString]];
    
    NSString *post = [NSString stringWithFormat: @"upjson=%@", jsonString];
    NSData *postData = [post dataUsingEncoding: NSUTF8StringEncoding];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    [NSURLConnection connectionWithRequest:request delegate:self];
}
-(void)addDeviceUID:(NSString *)cameraUID deviceName:(NSString *)cameraName userID:(NSString *)userID PWD:(NSString*)userPWD {
    
    NSDictionary *dict = @{@"cmd": @"create", @"usr": userID, @"pwd": userPWD, @"uid": cameraUID, @"name":cameraName, @"type": @"IP Camera"};

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *hostString = @"http://p2pcamweb.tutk.com/DeviceCloud/api.php";
    
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL URLWithString:hostString]];
    
    NSString *post = [NSString stringWithFormat: @"upjson=%@", jsonString];
    NSData *postData = [post dataUsingEncoding: NSUTF8StringEncoding];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

-(void)downloadDeviceListID:(NSString *)userID PWD:(NSString*)userPWD {
    
    NSDictionary *dict = @{@"cmd": @"readall", @"usr": userID, @"pwd": userPWD};

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSLog(@"JSON:%@",jsonString);
    
    NSString *hostString = @"http://p2pcamweb.tutk.com/DeviceCloud/api.php";
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL URLWithString:hostString]];
    
    NSString *post = [NSString stringWithFormat: @"upjson=%@", jsonString];
    NSData *postData = [post dataUsingEncoding: NSUTF8StringEncoding];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)theData {
    
    [self.delegate connection:connection didReceiveData:theData];
    
//    NSLog(@"String sent from server %@",[[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding]);
//    NSError *error;
//    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:theData options:NSJSONWritingPrettyPrinted error:&error];
//    NSMutableArray *tempArray = [dictionary valueForKey:@"upjson"];
//    
//    if (tempArray){
//        for (NSDictionary *tempDic in tempArray){
//            NSString* cameraName = [tempDic valueForKey:@"name"];
//            NSLog(@"EXCHANGE:%@",cameraName);
//        }
//    }
}

@end
