//
//  UIMyWebView.m
//  YoleDdz
//
//  Created by Lee Aru on 12-11-12.
//
//

#import "UIMyWebView.h"

@implementation UIMyWebView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor=[UIColor clearColor];
        self.opaque=NO;
        for (UIView *subView in [self subviews]) {
            if ([subView isKindOfClass:[UIScrollView class]]) {
                [(UIScrollView *)subView setShowsVerticalScrollIndicator:NO]; //右侧的滚动条
                [(UIScrollView *)subView setShowsHorizontalScrollIndicator:NO]; //下侧的滚动条
                for (UIView *shadowView in [subView subviews]) {
                    if ([shadowView isKindOfClass:[UIImageView class]]) {
                        shadowView.hidden = YES;
                    }
                }
            }
        }
    }
    return self;
}
-(void)loadLocalHtmlFile:(NSString *)fileName{
    NSString *Path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    [self loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:Path]]];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
