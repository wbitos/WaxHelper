//
//  WaxFile.h
//  WaxHelper
//
//  Created by wbitos on 16/8/30.
//  Copyright © 2016年 wbitos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WaxClass.h"

@interface WaxFile : NSObject
@property (nonatomic, strong, readonly) WaxClass *waxClass;

@property (nonatomic, strong, readonly) NSArray *classCompletionItems;
@property (nonatomic, strong, readonly) NSArray *methodCompletionItems;
@property (nonatomic, strong, readonly) NSArray *propertyCompletionItems;

@property (nonatomic, strong, readonly) NSArray *keywordCompletionItems;

- (instancetype)initWithContent:(NSString *)content;
@end
