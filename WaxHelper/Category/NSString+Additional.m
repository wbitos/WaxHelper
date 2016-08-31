//
//  NSString+Additional.m
//  Wax
//
//  Created by bang on 4/17/16.
//  Copyright © 2016 bang. All rights reserved.
//

#import "NSString+Additional.h"

@implementation NSString (Additional)

- (NSString *)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end