//
//  CustomTableViewCellStyle1.h
//  PlugCam
//
//  Created by ZINWELL on 2012/1/4.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomTableViewCellStyle1 : UITableViewCell {
	UIImageView *imageView;
	UILabel *textLabel;
	UILabel *detailTextLabel;
}
@property (nonatomic,retain)IBOutlet UIImageView *imageView;
@property (nonatomic,retain)IBOutlet UILabel *textLabel;
@property (nonatomic,retain)IBOutlet UILabel *detailTextLabel;
@end
