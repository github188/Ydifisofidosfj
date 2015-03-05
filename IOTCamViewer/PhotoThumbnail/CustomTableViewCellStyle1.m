//
//  CustomTableViewCellStyle1.m
//  PlugCam
//
//  Created by ZINWELL on 2012/1/4.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomTableViewCellStyle1.h"


@implementation CustomTableViewCellStyle1
@synthesize imageView;
@synthesize textLabel;
@synthesize detailTextLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
    [imageView release];
    [textLabel release];
    [detailTextLabel release];
    [super dealloc];
}


@end
