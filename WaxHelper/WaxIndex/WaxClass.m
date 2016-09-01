//
//  WaxClass.m
//  WaxHelper
//
//  Created by wbitos on 16/8/30.
//  Copyright © 2016年 wbitos. All rights reserved.
//

#import "WaxClass.h"
#import "WaxCompletionItem.h"
#import "DVTSourceCodeSymbolKind.h"
#import "WaxMethod.h"

@interface WaxClass ()

@end

@implementation WaxClass
- (instancetype)initWithClass:(NSString *)cls baseClass:(NSString *)baseCls protocols:(NSArray *)protocols properties:(NSArray *)properties methods:(NSArray *)methods {
    self = [super init];
    if (self) {
        _cls = cls;
        _baseCls = baseCls;
        _properties = properties;
        _protocols = protocols;
        _methods = methods;
    }
    return self;
}

- (NSArray *)classCompletionItems {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    if (_cls) {
        WaxCompletionItem *clsCompletionItem = [[WaxCompletionItem alloc] initWithDictinary:@{
                                                                                            kJPCompeletionName: _cls,
                                                                                            kJPCompeletionDisplayText: _cls,
                                                                                            kJPCompeletionText: _cls,
                                                                                            kJPCompeletionDisplayType: @"Class",
                                                                                            kJPCompeletionKind: [DVTSourceCodeSymbolKind classSymbolKind]
                                                                                            }];
        [items addObject:clsCompletionItem];
    }
    
    if (_baseCls) {
        WaxCompletionItem *baseClsCompletionItem = [[WaxCompletionItem alloc] initWithDictinary:@{
                                                                                                kJPCompeletionName: _baseCls,
                                                                                                kJPCompeletionDisplayText: _baseCls,
                                                                                                kJPCompeletionText: _baseCls,
                                                                                                kJPCompeletionDisplayType: @"Class",
                                                                                                kJPCompeletionKind: [DVTSourceCodeSymbolKind classSymbolKind]
                                                                                                }];
        [items addObject:baseClsCompletionItem];
    }
    
    return items;
}

- (NSArray *)methodCompletionItems {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (WaxMethod *m in _methods) {
        WaxCompletionItem *item = [m completionItem];
        if (item) {
            [items addObject:item];
        }
    }
    return items;
}

- (NSArray *)propertyCompletionItems {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (NSString *prop in _properties) {
        WaxCompletionItem *item = [[WaxCompletionItem alloc] initWithDictinary:@{
                                                                               kJPCompeletionName: prop,
                                                                               kJPCompeletionDisplayText: [NSString stringWithFormat:@"%@", prop],
                                                                               kJPCompeletionText: [NSString stringWithFormat:@"%@", prop],
                                                                               kJPCompeletionDisplayType: @"Property",
                                                                               kJPCompeletionKind: [DVTSourceCodeSymbolKind propertySymbolKind]
                                                                               }];
        [items addObject:item];
    }
    return items;
}

- (NSArray *)propertySetterCompletionItems {
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (NSString *prop in _properties) {
        NSString *p = prop;
        if ([prop hasPrefix:@"_"]) {
            p = [prop substringFromIndex:1];
        }
        
        if (p.length > 1) {
            NSString *setName = [NSString stringWithFormat:@"set%@%@", [[p substringToIndex:1] uppercaseString], [p substringFromIndex:1]];
            WaxCompletionItem *itemSet = [[WaxCompletionItem alloc] initWithDictinary:@{
                                                                                        kJPCompeletionName: [NSString stringWithFormat:@"%@()", setName],
                                                                                        kJPCompeletionDisplayText: [NSString stringWithFormat:@"%@( val )", setName],
                                                                                        kJPCompeletionText: [NSString stringWithFormat:@"%@(<# val #\>)", setName],
                                                                                        kJPCompeletionDisplayType: @"Method",
                                                                                        kJPCompeletionKind: [DVTSourceCodeSymbolKind functionSymbolKind]
                                                                                        }];
            [items addObject:itemSet];
        }
    }
    return items;
}
@end
