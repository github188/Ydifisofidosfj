//
//  UIImage+Resize.h
//
//  Created by Darktt on 13/3/28.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface UIImage(Resize)

- (UIImage *)croppedImage:(CGRect)bounds;

- (UIImage *)thumbnailImage:(NSInteger)thumbnailSize
       interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)scaleImageToSize:(CGSize)scaleSize;

@end
