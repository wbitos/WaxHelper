//
//  WaxMethod.h
//  WaxHelper
//
//  Created by wbitos on 16/8/30.
//  Copyright © 2016年 wbitos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WaxCompletionItem.h"

@interface WaxMethod : NSObject
- (instancetype)initWithMethodName:(NSString *)name params:(NSArray *)params className:(NSString *)className;

- (WaxCompletionItem *)completionItem;
@end
