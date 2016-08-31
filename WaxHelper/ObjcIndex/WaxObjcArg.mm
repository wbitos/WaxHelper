//
//  WaxObjcArg.m
//  Wax
//
//  Created by louis on 4/16/16.
//  Copyright © 2016 louis. All rights reserved.
//

#import "WaxObjcArg.h"
#import "objcParser.h"
#import "NSString+Additional.h"

@implementation WaxObjcArg 

- (instancetype)initWithParseResult:(void *)result
{
    if (self = [super init]) {
        ArgSymbol * argsym = (ArgSymbol *)result;
        _selector = [NSString stringWithUTF8String:argsym->selector.c_str()];
        _argName  = [[NSString stringWithUTF8String:argsym->argName.c_str()] trim];
        _argType  = [[NSString stringWithUTF8String:argsym->argType.c_str()] trim];
    }
    return self;
}


@end
