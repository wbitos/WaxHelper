//
//  WaxCompletionItem.h
//  Wax
//
//  Created by wbitos on 4/16/16.
//  Copyright (c) 2016年 wbitos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDEIndexCompletionItem.h"
#import "IDEIndexCallableSymbol.h"

const static NSString *kJPCompeletionName = @"kJPCName";
const static NSString *kJPCompeletionDisplayText = @"kJPCDplTxt";
const static NSString *kJPCompeletionDisplayType = @"kJPCDplType";
const static NSString *kJPCompeletionText = @"kJPCTxt";
const static NSString *kJPCompeletionKind = @"kJPCKind";

@interface WaxCompletionItem : IDEIndexCompletionItem
@property (nonatomic, strong) NSString *prefix;

- (instancetype)initWithDictinary:(NSDictionary *)dict;

- (NSString *)lowercaseName;

@end
