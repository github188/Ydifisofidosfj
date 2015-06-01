//
//  AppGuidViewController.m
//  Aztech IPCam
//
//  Created by fourones on 15/3/6.
//  Copyright (c) 2015年 TUTK. All rights reserved.
//

#import "AppGuidViewController.h"

@interface AppGuidViewController ()

@end

@implementation AppGuidViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    customButton.frame = CGRectMake(0, 0, 44, 44);
    [customButton setBackgroundImage:[UIImage imageNamed:@"cam_back" ] forState:UIControlStateNormal];
    [customButton setBackgroundImage:[UIImage imageNamed:@"cam_back_clicked"] forState:UIControlStateHighlighted];
    [customButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:customButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -16;
    
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, backButton, nil];
    [backButton release];
    
    self.navigationItem.title = NSLocalizedString(@"用户手册", @"");
    [self.skipBtn setTitle:NSLocalizedString(@"GuidSkip", @"") forState:UIControlStateNormal];
    
    

    
}
-(void)viewWillAppear:(BOOL)animated{
    
    //动态布局
    self.skipBtn.frame=CGRectMake(self.skipBtn.frame.origin.x, self.view.frame.size.height-self.skipBtn.frame.size.height-6, self.skipBtn.frame.size.width, self.skipBtn.frame.size.height);
    self.pageControl.frame=CGRectMake(self.pageControl.frame.origin.x, self.view.frame.size.height-self.pageControl.frame.size.height, self.pageControl.frame.size.width, self.pageControl.frame.size.height);
    self.scollerView.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    
    
    self.pageControl.numberOfPages=4;
    self.scollerView.pagingEnabled=YES;
    self.scollerView.delegate=self;
    self.scollerView.frame=CGRectMake(0, 0, self.scollerView.frame.size.width, self.scollerView.frame.size.height);
    self.scollerView.contentSize=CGSizeMake(self.scollerView.frame.size.width*self.pageControl.numberOfPages, 0);
    
    for (NSInteger i=0; i<self.pageControl.numberOfPages; i++) {
        NSString *f=[NSString stringWithFormat:@"page%ld",i+1];
        NSString *n=NSLocalizedString(f, @"");
        UIImageView *imgView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:n]];
        imgView.contentMode=UIViewContentModeScaleAspectFit;
        imgView.frame=CGRectMake(self.scollerView.frame.size.width*i, 0, self.scollerView.frame.size.width, self.scollerView.frame.size.height-110);
        [self.scollerView addSubview:imgView];
        [imgView release];
    }
    [super viewWillAppear:animated];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat pageWidth = self.scollerView.frame.size.width;
    int p = floor((self.scollerView.contentOffset.x - pageWidth / 4) / pageWidth) + 1;
    if(p<0) return;
    self.pageControl.currentPage=p;
    if(p+1>self.pageControl.numberOfPages)
    {
        //self.scollerView.delegate=nil;
        //[self back:self.skipBtn];
    }
}
- (void)back:(id)sender {
    self.scollerView.delegate=nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [_pageControl release];
    [_skipBtn release];
    [_scollerView release];
    [super dealloc];
}
- (IBAction)skipBtnAction:(id)sender {
    [self back:self.skipBtn];
}
@end
