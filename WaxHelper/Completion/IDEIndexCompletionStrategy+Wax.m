//
//  IDEIndexCompletionStrategy+Wax.m
//  WaxHelper
//
//  Created by wbitos on 16/8/30.
//  Copyright © 2016年 wbitos. All rights reserved.
//

#import "IDEIndexCompletionStrategy+Wax.h"
#import "MethodSwizzle.h"
#import "DVTSourceTextView.h"
#import "IDEWorkspace.h"
#import "IDEEditorDocument.h"
#import "DVTFilePath.h"
#import "IDEWorkspace+Wax.h"
#import "DVTTextDocumentLocation.h"
#import "WaxIndex.h"
#import "NSString+Additional.h"

@implementation IDEIndexCompletionStrategy (Wax)
+ (void)load {
    NSLog(@"WaxHelper[IDEIndexCompletionStrategy]- load");

    SWIZZLE(completionItemsForDocumentLocation:context:highlyLikelyCompletionItems:areDefinitive:);
}

- (id)wax_swizzle_completionItemsForDocumentLocation:(id)arg1 context:(id)arg2 highlyLikelyCompletionItems:(id *)arg3 areDefinitive:(char *)arg4 {
    NSLog(@"WaxHelper[IDEIndexCompletionStrategy]- wax_swizzle_completionItemsForDocumentLocation:%@ context:%@ highlyLikelyCompletionItems:%@ areDefinitive:%s", arg1, arg2, *arg3, arg4);
    
    DVTSourceTextView* sourceTextView = [arg2 objectForKey:@"DVTTextCompletionContextTextView"];
    DVTTextStorage *textStorage= [arg2 objectForKey:@"DVTTextCompletionContextTextStorage"];
    DVTTextDocumentLocation *location = (DVTTextDocumentLocation *)arg1;
    IDEWorkspace *workspace = [arg2 objectForKey:@"IDETextCompletionContextWorkspaceKey"];
    IDEEditorDocument *document = [arg2 objectForKey:@"IDETextCompletionContextDocumentKey"];
    
    if (textStorage && [[document.filePath.pathString lowercaseString] hasSuffix:@".lua"]) {
        return [self genCompletionItems:sourceTextView loc:location workSpace:workspace strFilePath:document.filePath.pathString];
    }else{
        return [self wax_swizzle_completionItemsForDocumentLocation:arg1 context:arg2 highlyLikelyCompletionItems:arg3 areDefinitive:arg4];
    }
}

- (NSArray *)genCompletionItems:(DVTSourceTextView *)txtView loc:(DVTTextDocumentLocation *)location workSpace:(IDEWorkspace *)wspace strFilePath:(NSString *)filePath {
    NSLog(@"WaxHelper[IDEIndexCompletionStrategy]- genCompletionItems:%@ loc:%ld workSpace:%@ strFilePath:%@", txtView, (long)location.characterRange.location, wspace, filePath);
    NSMutableArray *items = [NSMutableArray array];
    NSInteger loc = 0;
    
    EWaxIndexType e = eWaxIndexTypeUnknown;
    
    NSString *preWord = nil;

    loc = location.characterRange.location - 1;
    if (loc >= 0) {
        NSString *prevChar = [txtView.textStorage.string substringWithRange:NSMakeRange(loc,1)];
        if ([prevChar isEqualToString:@"."]) {
            // next property
            e = eWaxIndexTypeProperty;
        }
        else if ([prevChar isEqualToString:@":"]) {
            // next method
            e = eWaxIndexTypeMethod;
        }
        else if ([prevChar isEqualToString:@" "]) {
            e = eWaxIndexTypeFunction;
        }
        
        if (loc > 0) {
            preWord = [[[[txtView.textStorage.string substringToIndex:loc] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lastObject] trim];
        }
    }
    
    NSLog(@"WaxHelper[WaxIndex]- preWord:%@", preWord);

    if ([preWord length] > 0 && e != eWaxIndexTypeUnknown) {
        NSArray *fileItems = [wspace.waxIndex completionItemsForFile:filePath preWord:preWord indexType:e];
        [items addObjectsFromArray:fileItems];
    }

    if ([[preWord trim] isEqualToString:@"function"]) {
        NSLog(@"WaxHelper[WaxIndex]- function");

        NSArray *protocolItems = [wspace.waxIndex protocolCompletionItemsForFile:filePath];
        [items addObjectsFromArray:protocolItems];
    }
    
    NSArray *templateKeywordItems = [wspace.waxIndex suggestQuickCompletionTemplate];
    [items addObjectsFromArray:templateKeywordItems];

    NSArray *keywordItems = [wspace.waxIndex keywordCompletionItemsWithFilePath:filePath];
    [items addObjectsFromArray:keywordItems];
    return items;
}
@end
