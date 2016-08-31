//
//  WaxClass.h
//  WaxHelper
//
//  Created by wbitos on 16/8/30.
//  Copyright © 2016年 wbitos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WaxClass : NSObject
@property (nonatomic, strong, readonly) NSString *cls;
@property (nonatomic, strong, readonly) NSString *baseCls;
@property (nonatomic, strong, readonly) NSArray  *properties;

- (instancetype)initWithClass:(NSString *)cls baseClass:(NSString *)baseCls properties:(NSArray *)properties;
- (NSArray *)classCompletionItems;
- (NSArray *)propertyCompletionItems;
@end
