//
//  CGRectExtension.h
//
//  Created by Darktt on 13/11/5.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#include <CoreGraphics/CGGeometry.h>

CG_INLINE CGPoint CGRectGetCenter(CGRect rect) {
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

CG_INLINE CGRect CGRectScale(CGRect rect, CGFloat wScale, CGFloat hScale) {
    return CGRectInset(rect, CGRectGetWidth(rect) * (wScale - 1), CGRectGetHeight(rect) * (hScale - 1));
}