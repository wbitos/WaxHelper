//
//  WaxHelper.h
//  WaxHelper
//
//  Created by wbitos on 16/8/30.
//  Copyright © 2016年 wbitos. All rights reserved.
//

#import <AppKit/AppKit.h>

@class WaxHelper;

static WaxHelper *sharedPlugin;

@interface WaxHelper : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end