//
//  NSArray+AroundArray.h
//
//  Created by Darktt on 13/3/22.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^NSArrayEnumerateBlock) (id obj, NSUInteger idx, BOOL *stop);

@interface NSArray (AroundArray)

// Get object of index for infinity index.
- (id)aroundObjectAtIndex:(NSInteger)index;

// Revert array content object.
- (NSArray *)revertArray;

@end
