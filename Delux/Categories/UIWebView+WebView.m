//
//  UIWebView+WebView.m
//
//  Created by Darktt on 16/1/13.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import "UIWebView+WebView.h"

@implementation UIWebView (WebView)

+ (id)webViewWithFrame:(CGRect)frame URL:(NSURL *)url;
{
    UIWebView *webView = [[[UIWebView alloc] initWithFrame:frame] autorelease];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    return webView;
}

+ (id)webViewWithFrame:(CGRect)frame URL:(NSURL *)url Delegate:(id<UIWebViewDelegate>)delegate
{
    UIWebView *webView = [UIWebView webViewWithFrame:frame URL:url];
    [webView setDelegate:delegate];
    
    return webView;
}

#pragma mark - Get webView in superview

+ (UIWebView *)webViewInView:(UIView *)superview withTag:(NSUInteger)tag
{
    UIWebView *webView = (UIWebView *)[superview viewWithTag:tag];
    
    if (![webView isKindOfClass:[self class]]) {
#ifdef DEBUG
        
        NSLog(@"%s [%d] : WebView not found.", __func__, __LINE__);
        
#endif
        return nil;
    }
    
    return webView;
}

@end
