//
//  CustomGridTableViewCellStyle1.m
//  PlugCam
//
//  Created by  on 2012/2/20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CustomGridTableViewCellStyle1.h"

@implementation CustomGridTableViewCellStyle1
@synthesize button1,button2,button3,button4;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [button1 release];
    [button2 release];
    [button3 release];
    [button4 release];
    [super dealloc];
}
@end
