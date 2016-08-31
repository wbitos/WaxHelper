//
//  IDEWorkspace+Wax.h
//  WaxHelper
//
//  Created by wbitos on 16/8/30.
//  Copyright © 2016年 wbitos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDEWorkspace.h"
#import "WaxIndex.h"
#import "WaxObjcIndex.h"
#import "PBXProject.h"

@interface IDEWorkspace (Wax)

- (WaxIndex *)waxIndex;

- (WaxObjcIndex *)objcIndex;

- (NSString *)currentProjectFolder;

- (NSArray *)defaultScanHeaderDirs;

- (NSArray *)SDKDirs;

- (NSString *)xcprojFile;
@end
