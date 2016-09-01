//
//  DVTTextCompletionSession+Wax.m
//  WaxHelper
//
//  Created by wbitos on 16/8/30.
//  Copyright © 2016年 wbitos. All rights reserved.
//

#import "DVTTextCompletionSession+Wax.h"
#import "MethodSwizzle.h"
#import "DVTTextCompletionListWindowController.h"
#import "DVTTextCompletionInlinePreviewController.h"
#import "DVTSourceCodeLanguage.h"
#import "DVTSourceTextView.h"
#import "DVTSourceModel.h"
#import <objc/runtime.h>
#import "WaxCompletionItem.h"

@implementation DVTTextCompletionSession (Wax)
+ (void)load {
    NSLog(@"WaxHelper[DVTTextCompletionSession]- load");

    SWIZZLE(_setFilteringPrefix:forceFilter:);
    SWIZZLE(initWithTextView:atLocation:cursorLocation:);
}

- (void)wax_swizzle__setFilteringPrefix:(id)arg1 forceFilter:(BOOL)arg2 {
    NSLog(@"WaxHelper[DVTTextCompletionSession]- wax_swizzle__setFilteringPrefix:%@ forceFilter:%ld", arg1, (long)arg2);
    
    BOOL isWax = [objc_getAssociatedObject(self, @"isWax") boolValue] ;
    if (!isWax) {
        [self wax_swizzle__setFilteringPrefix:arg1 forceFilter:arg2];
        return;
    }
    NSCharacterSet *sepSet = [NSCharacterSet characterSetWithCharactersInString:@":."];
    NSString *comparePrefix = [[[arg1 lowercaseString] componentsSeparatedByCharactersInSet:sepSet] lastObject];

    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    @try {
        NSLog(@"WaxHelper[DVTTextCompletionSession]- comparePrefix:%@ completions:%@", comparePrefix, self.allCompletions);

        for (WaxCompletionItem * compitem in self.allCompletions) {
            if ([compitem.lowercaseName hasPrefix:comparePrefix]) {
                NSInteger toIndex = [arg1 length] - [comparePrefix length];
                if ([arg1 length] > 0 && toIndex > 0) {
                    compitem.prefixText = [arg1 substringToIndex:toIndex];
                }
                else {
                    compitem.prefixText = @"";
                }
                [arr addObject:compitem];
            }
        }
        
        if (0 == arr.count) {
            [self wax_swizzle__setFilteringPrefix:arg1 forceFilter:arg2];
            return;
        }
    }@catch(NSException *exception) {
        NSLog(@"WaxHelper[DVTTextCompletionSession]- exception %@", exception);
    }
    
    @try {
        
        [self willChangeValueForKey:@"filteredCompletionsAlpha"];
        [self willChangeValueForKey:@"selectedCompletionIndex"];
        
        [self setValue: arr forKey: @"_filteredCompletionsAlpha"];
        [self setValue: @(0) forKey: @"_selectedCompletionIndex"];
        
        [self didChangeValueForKey:@"filteredCompletionsAlpha"];
        [self didChangeValueForKey:@"selectedCompletionIndex"];
        
    }@catch(NSException *exception) {
        NSLog(@"WaxHelper[DVTTextCompletionSession]- exception %@", exception);
    }
}

- (id)wax_swizzle_initWithTextView:(id)arg1 atLocation:(unsigned long long)arg2 cursorLocation:(unsigned long long)arg3 {
    DVTSourceTextView *txtView = (DVTSourceTextView *)arg1;
    NSLog(@"WaxHelper[DVTTextCompletionSession]- language identifire:%@", txtView.textStorage.language.identifier);
    if ([[txtView.textStorage.language.identifier lowercaseString] hasSuffix:@".lua"]) {
        objc_setAssociatedObject(self, @"isWax", @(YES), OBJC_ASSOCIATION_ASSIGN);
    }else{
        objc_setAssociatedObject(self, @"isWax", @(NO), OBJC_ASSOCIATION_ASSIGN);
    }
    
    id obj = [self wax_swizzle_initWithTextView:arg1 atLocation:arg2 cursorLocation:arg3];
    return obj;
}

- (BOOL)isJSSession {
    return [objc_getAssociatedObject(self, @"isWax") boolValue];
}
@end
