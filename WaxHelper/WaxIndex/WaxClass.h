//
//  WaxClass.h
//  WaxHelper
//
//  Created by wbitos on 16/8/30.
//  Copyright © 2016年 wbitos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WaxClass : NSObject
@property (nonatomic, strong) NSString *cls;
@property (nonatomic, strong) NSString *baseCls;
@property (nonatomic, strong) NSArray *protocols;
@property (nonatomic, strong) NSArray *methods;
@property (nonatomic, strong) NSArray *properties;

- (instancetype)initWithClass:(NSString *)cls baseClass:(NSString *)baseCls protocols:(NSArray *)protocols properties:(NSArray *)properties methods:(NSArray *)methods;
- (NSArray *)classCompletionItems;
- (NSArray *)propertyCompletionItems;
- (NSArray *)propertySetterCompletionItems;
- (NSArray *)methodCompletionItems;
@end
