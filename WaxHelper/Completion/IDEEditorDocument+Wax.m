//
//  IDEEditorDocument+Wax.m
//  WaxHelper
//
//  Created by wbitos on 16/8/30.
//  Copyright © 2016年 wbitos. All rights reserved.
//

#import "IDEEditorDocument+Wax.h"
#import "MethodSwizzle.h"
#import "DVTFilePath.h"

@implementation IDEEditorDocument (Wax)
+(void)load {
    NSLog(@"WaxHelper[IDEEditorDocument]- load");
    SWIZZLE(ide_finishSaving:forSaveOperation:previousPath:);
}

- (void)wax_swizzle_ide_finishSaving:(BOOL)arg1 forSaveOperation:(unsigned long long)arg2 previousPath:(id)arg3 {
    DVTFilePath *filePath = arg3;
    NSLog(@"WaxHelper[IDEEditorDocument]- wax_swizzle_ide_finishSaving:%@", filePath);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WaxFileSaved" object:filePath.pathString];
    [self wax_swizzle_ide_finishSaving:arg1 forSaveOperation:arg2 previousPath:arg3];
}
@end
