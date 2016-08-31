//
//  WaxMethod.m
//  WaxHelper
//
//  Created by wbitos on 16/8/30.
//  Copyright © 2016年 wbitos. All rights reserved.
//

#import "WaxMethod.h"
#import "DVTSourceCodeSymbolKind.h"

@interface WaxMethod ()
@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray  *params;

@property (nonatomic, assign) BOOL      instanceMethod;

@end

@implementation WaxMethod
- (instancetype)initWithMethodName:(NSString *)name params:(NSArray *)params className:(NSString *)className {
    self = [super init];
    if (self) {
        _name = name;
        _params = params;
        _className = className;
        if (className) {
            if ([[params firstObject] isEqualToString:@"self"]) {
                _instanceMethod = YES;
            }
            else {
                _instanceMethod = NO;
            }
        }
    }
    return self;
}

- (NSString *)displayText {
    NSMutableString *str = [_name mutableCopy];
    [str appendString:@"("];
    for (NSString *param in _params) {
        [str appendFormat:@"%@, ", param];
    }
    if (_params.count > 0) {
        [str deleteCharactersInRange:NSMakeRange(str.length - 2, 2)];
    }
    [str appendString:@")"];
    return str;
}

- (NSString *)completionText {
    NSMutableString *str = [_name mutableCopy];
    [str appendString:@"("];
    for (NSString *param in _params) {
        [str appendFormat:@"<#%@#\>, ", param];
    }
    if (_params.count > 0) {
        [str deleteCharactersInRange:NSMakeRange(str.length - 2, 2)];
    }
    [str appendString:@")"];
    return str;
}

- (WaxCompletionItem *)completionItem {
    id kind = [DVTSourceCodeSymbolKind functionSymbolKind];
    if (self.className) {
        _instanceMethod ? [DVTSourceCodeSymbolKind instanceMethodSymbolKind] :[DVTSourceCodeSymbolKind classMethodSymbolKind];
    }
    WaxCompletionItem *item = [[WaxCompletionItem alloc] initWithDictinary:@{
                                                                           kJPCompeletionName: _name,
                                                                           kJPCompeletionDisplayText: [self displayText],
                                                                           kJPCompeletionText: [self completionText],
                                                                           kJPCompeletionDisplayType: @"function",
                                                                           kJPCompeletionKind: kind
                                                                           }];
    return item;
}

@end
