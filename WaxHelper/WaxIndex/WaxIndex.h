//
//  WaxIndex.h
//  WaxHelper
//
//  Created by wbitos on 16/8/30.
//  Copyright © 2016年 wbitos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDEWorkspace.h"

@interface WaxIndex : NSObject
- (instancetype)initWithWorkspace:(IDEWorkspace *)workspace;
- (NSDictionary *)completionItemsInProject;
- (NSDictionary *)completionItemsForFile:(NSString *)filePath;
- (NSArray *)keywordCompletionItemsWithFilePath:(NSString *)filePath;

@end
