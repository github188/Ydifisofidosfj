//
//  NSNumber+Mathematica.m
//
//  Created by Darktt on 13/12/20.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import "NSNumber+Mathematica.h"

@implementation NSNumber (Mathematica)

- (NSArray *)squareFactorization
{
    long long baseNumber = [self longLongValue];
//    NSLog(@"baseNumber: %llu", baseNumber);
    
    double i = round(log2(baseNumber));
    
    if (baseNumber < pow(2, i)) {
        i -= 1;
    }
    
    NSMutableArray *squareComponent = [NSMutableArray array];
	
    do {
        NSInteger result = baseNumber % (NSInteger)pow(2, i);
        if (baseNumber == result) {
            i -= 1;
            continue;
        }
        
        baseNumber -= pow(2, i);
        
        [squareComponent addObject:@(pow(2, i))];
        
        // When weekNumber is 1, mean already calculator done, break while loop.
        if (baseNumber == 1) {
            [squareComponent addObject:@(baseNumber)];
            
            break;
        }
        
        i -= 1;
        
    } while (i >= 0);
    
//    NSLog(@"squareComponent: %@", squareComponent);
    
    return squareComponent;
}

@end
