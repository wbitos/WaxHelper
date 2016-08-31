//
//  WaxObjcArg.h
//  Wax
//
//  Created by louis on 4/16/16.
//  Copyright © 2016 louis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WaxObjcArg : NSObject

@property (nonatomic, retain) NSString * selector;
@property (nonatomic, retain) NSString * argName;
@property (nonatomic, retain) NSString * argType;

- (instancetype)initWithParseResult:(void *)result;
@end
