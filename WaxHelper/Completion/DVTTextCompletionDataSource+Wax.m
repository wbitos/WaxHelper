//
//  DVTTextCompletionDataSource+Wax.m
//  WaxHelper
//
//  Created by wbitos on 16/8/30.
//  Copyright © 2016年 wbitos. All rights reserved.
//

#import "DVTTextCompletionDataSource+Wax.h"
#import "MethodSwizzle.h"
#import "DVTSourceCodeLanguage.h"
#import "IDEIndexCompletionStrategy.h"

@implementation DVTTextCompletionDataSource (Wax)
+ (void)load {
    NSLog(@"WaxHelper[DVTTextCompletionDataSource]- load");
    SWIZZLE(strategies);
}

- (NSArray*)swizzle_strategies {
    NSLog(@"WaxHelper[DVTTextCompletionDataSource]- language identifire:%@", self.language.identifier);
    if ([[self.language.identifier lowercaseString] hasSuffix:@".lua"]) {
        return [NSArray arrayWithObject:[[IDEIndexCompletionStrategy alloc] init]];
    }else{
        return [self swizzle_strategies];
    }
}
@end
