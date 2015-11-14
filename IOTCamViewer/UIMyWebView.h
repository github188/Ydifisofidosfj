//
//  UIMyWebView.h
//  YoleDdz
//
//  Created by Lee Aru on 12-11-12.
//
//

#import <UIKit/UIKit.h>
/*
 *自定义UIWebView,影藏垂直水平滚动条，去掉拖动出现的阴影。注意再加载的html页面中页面设置成背景透明
 *设置方法：<body style=“background-color:rgba(0,0,0,0);”>
 */
@interface UIMyWebView : UIWebView

-(void)loadLocalHtmlFile:(NSString *)fileName;
@end
