//
//  UIImage+resizeImage.m
//
//  Created by Darktt on 13/4/3.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import "UIImage+ResizeImage.h"
#import <ImageIO/ImageIO.h>

//#define UES_IMAGEIO_FRAMEWORK

@implementation UIImage (ResizeImage)

+ (UIImage *)resizeImageWithSourceImageName:(NSString *)sourceName forMaxSize:(CGFloat)maxSize
{
#ifdef UES_IMAGEIO_FRAMEWORK
    NSURL *sourceUrl = [NSURL fileURLWithPath:sourceName];
    CFURLRef sourceUrlRef = (CFURLRef)sourceUrl;
    
    CGImageSourceRef src = CGImageSourceCreateWithURL(sourceUrlRef, NULL);
    
    CFDictionaryRef options = (CFDictionaryRef)[[NSDictionary alloc] initWithObjectsAndKeys:
                                                (id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailWithTransform,
                                                (id)kCFBooleanTrue, (id)kCGImageSourceCreateThumbnailFromImageIfAbsent,
                                                (id)[NSNumber numberWithFloat:maxSize], (id)kCGImageSourceThumbnailMaxPixelSize,
                                                nil];
    
    CGImageRef thumbnail = CGImageSourceCreateThumbnailAtIndex(src, 0, options); // Create scaled image
    CFRelease(options);
    CFRelease(src);
    UIImage *image = [[[UIImage alloc] initWithCGImage:thumbnail] autorelease];
    
    CGImageRelease(thumbnail);
    
    return image;
#else
    return nil;
#endif
}

@end
