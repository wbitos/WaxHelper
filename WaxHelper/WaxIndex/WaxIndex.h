//
//  WaxIndex.h
//  WaxHelper
//
//  Created by wbitos on 16/8/30.
//  Copyright © 2016年 wbitos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDEWorkspace.h"

typedef enum : NSUInteger {
    eWaxIndexTypeUnknown,
    eWaxIndexTypeMethod,
    eWaxIndexTypeClassMethod,
    eWaxIndexTypeProperty,
    eWaxIndexTypeClassProperty,
} EWaxIndexType;

@interface WaxIndex : NSObject
- (instancetype)initWithWorkspace:(IDEWorkspace *)workspace;

- (NSArray *)completionItemsForFile:(NSString *)filePath preWord:(NSString *)preWord indexType:(EWaxIndexType)eType;
-(NSArray *)suggestQuickCompletionTemplate;

- (NSArray *)keywordCompletionItemsWithFilePath:(NSString *)filePath;

@end
