//
//  MKHorizMenu.m
//  MKHorizMenuDemo
//  Created by Mugunth on 09/05/11.
//  Copyright 2011 Steinlogic. All rights reserved.
//  Permission granted to do anything, commercial/non-commercial with this file apart from removing the line/URL above
//  Read my blog post at http://mk.sg/8h on how to use this code

//  As a side note on using this code, you might consider giving some credit to me by
//	1) linking my website from your app's website 
//	2) or crediting me inside the app's credits page 
//	3) or a tweet mentioning @mugunthkumar
//	4) A paypal donation to mugunth.kumar@gmail.com
//
//  A note on redistribution
//	While I'm ok with modifications to this source code, 
//	if you are re-publishing after editing, please retain the above copyright notices

#import "MKHorizMenu.h"
#define kButtonBaseTag 10000
#define kLeftOffset 5

@implementation MKHorizMenu

@synthesize titles = _titles;
@synthesize selectedImage = _selectedImage;

@synthesize itemSelectedDelegate;
@synthesize dataSource;
@synthesize itemCount = _itemCount;

-(void) awakeFromNib
{
    self.bounces = YES;
    self.scrollEnabled = YES;
    self.alwaysBounceHorizontal = YES;
    self.alwaysBounceVertical = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    [self reloadData];
}

-(void) reloadSoundBtn {
    
}
     
-(void) reloadData
{
    NSArray *viewsToRemove = [self subviews];
	for (UIView *v in viewsToRemove) {
		[v removeFromSuperview];
	}
    
    self.itemCount = [dataSource numberOfItemsForMenu:self];
    self.backgroundColor = [dataSource backgroundColorForMenu:self];
    //self.selectedImage = [dataSource selectedItemImageForMenu:self];

    UIFont *buttonFont = [UIFont boldSystemFontOfSize:15];
    int buttonPadding = 5;
    
    int tag = kButtonBaseTag;    
    int xPos = kLeftOffset;
    
    CGFloat btnTotalWidth=0.0f;
    for(int i = 0 ; i < self.itemCount; i ++){
        UIImage *bgImg=[UIImage imageNamed:[dataSource horizMenu:self titleForItemAtIndex:i]];
        btnTotalWidth+=bgImg.size.width;
        if(i==3){
            NSLog(@"OK");
        }
    }
    
    //计算左右变距
    CGFloat totalLen=(self.itemCount-1)*buttonPadding+btnTotalWidth;
    CGFloat leftX=(self.superview.frame.size.width-totalLen)/2;
    if(leftX<0) leftX=xPos;
    xPos=leftX;
    

    for(int i = 0 ; i < self.itemCount; i ++)
    {
        NSString *title = @"";
        UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [customButton setTitle:title forState:UIControlStateNormal];
        customButton.titleLabel.font = buttonFont;
        
        UIImage *bgImg=[UIImage imageNamed:[dataSource horizMenu:self titleForItemAtIndex:i]];
        
        [customButton setBackgroundImage:bgImg forState:UIControlStateNormal];
        [customButton setBackgroundImage:[UIImage imageNamed:[dataSource selectedItemImageForMenu:self itemAtIndex:i]] forState:UIControlStateSelected];
        [customButton setBackgroundImage:[UIImage imageNamed:[dataSource selectedItemImageForMenu:self itemAtIndex:i]] forState:UIControlStateHighlighted];
        
        customButton.tag = tag++;
        [customButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [customButton addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
        
        customButton.frame = CGRectMake(xPos, 3, bgImg.size.width, 38);
        xPos += bgImg.size.width;
        if(i+1<self.itemCount){
            xPos += buttonPadding;
        }
        [self addSubview:customButton];
    }
    
    xPos += leftX;

    if(xPos<self.frame.size.width) xPos=self.frame.size.width;
    self.contentSize = CGSizeMake(xPos, self.frame.size.height);
    
    [self layoutSubviews];  
}


-(void) setSelectedIndex:(int)index animated:(BOOL) animated
{
    UIButton *thisButton = (UIButton*) [self viewWithTag:index + kButtonBaseTag];    
    thisButton.selected = YES;
    //[self setContentOffset:CGPointMake(thisButton.frame.origin.x - kLeftOffset, 0) animated:animated];
    //[self.itemSelectedDelegate horizMenu:self itemSelectedAtIndex:index];
}

- (void)setUnselectedIndex:(int)index animated:(BOOL)animated {
    UIButton *thisButton = (UIButton*) [self viewWithTag:index + kButtonBaseTag];
    thisButton.selected = NO;
    //[self setContentOffset:CGPointMake(thisButton.frame.origin.x - kLeftOffset, 0) animated:animated];
}
-(void)buttonTouchDown:(id)sender{
    UIButton *button = (UIButton*) sender;
    
    for(int i = 0; i < self.itemCount; i++)
    {
        UIButton *thisButton = (UIButton*) [self viewWithTag:i + kButtonBaseTag];
        if(i + kButtonBaseTag == button.tag){
            /*if (thisButton.selected == NO) {
                thisButton.selected = YES;
            } else {
                thisButton.selected = NO;
            }*/
        }
        else{
                thisButton.selected = NO;
        }
    }
    NSLog(@"Item TouchDown");
    if([self.itemSelectedDelegate respondsToSelector:@selector(horizMenu:itemTouchDownAtIndex:)]){
        [self.itemSelectedDelegate horizMenu:self itemTouchDownAtIndex:button.tag - kButtonBaseTag];
    }
}
-(void) buttonTapped:(id) sender
{
    UIButton *button = (UIButton*) sender;
    
    for(int i = 0; i < self.itemCount; i++)
    {
        UIButton *thisButton = (UIButton*) [self viewWithTag:i + kButtonBaseTag];
        if(i + kButtonBaseTag == button.tag)
            if (thisButton.selected == NO) {
                thisButton.selected = YES;
            } else {
                thisButton.selected = NO;
            }
        else
            thisButton.selected = NO;
    }
    NSLog(@"Item TouchUp");
    [self.itemSelectedDelegate horizMenu:self itemSelectedAtIndex:button.tag - kButtonBaseTag];
}


- (void)dealloc
{
    [_selectedImage release];
    _selectedImage = nil;
    [_titles release];
    _titles = nil;
    
    [super dealloc];
}

@end
