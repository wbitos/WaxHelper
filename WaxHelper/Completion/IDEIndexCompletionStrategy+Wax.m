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

@implementation IDEIndexCompletionStrategy (Wax)
+ (void)load {
    NSLog(@"WaxHelper[IDEIndexCompletionStrategy]- load");

    SWIZZLE(completionItemsForDocumentLocation:context:highlyLikelyCompletionItems:areDefinitive:);
}

- (id)swizzle_completionItemsForDocumentLocation:(id)arg1 context:(id)arg2 highlyLikelyCompletionItems:(id *)arg3 areDefinitive:(char *)arg4 {
    NSLog(@"WaxHelper[IDEIndexCompletionStrategy]- swizzle_completionItemsForDocumentLocation:%@ context:%@ highlyLikelyCompletionItems:%@ areDefinitive:%s", arg1, arg2, *arg3, arg4);
    
    DVTSourceTextView* sourceTextView = [arg2 objectForKey:@"DVTTextCompletionContextTextView"];
    DVTTextStorage *textStorage= [arg2 objectForKey:@"DVTTextCompletionContextTextStorage"];
    DVTTextDocumentLocation *location = (DVTTextDocumentLocation *)arg1;
    IDEWorkspace *workspace = [arg2 objectForKey:@"IDETextCompletionContextWorkspaceKey"];
    IDEEditorDocument *document = [arg2 objectForKey:@"IDETextCompletionContextDocumentKey"];
    
    if (textStorage && [[document.filePath.pathString lowercaseString] hasSuffix:@".lua"]) {
        return [self genCompletionItems:sourceTextView loc:location workSpace:workspace strFilePath:document.filePath.pathString];
    }else{
        return [self swizzle_completionItemsForDocumentLocation:arg1 context:arg2 highlyLikelyCompletionItems:arg3 areDefinitive:arg4];
    }
}

- (NSArray *)genCompletionItems:(DVTSourceTextView *)txtView loc:(DVTTextDocumentLocation *)location workSpace:(IDEWorkspace *)wspace strFilePath:(NSString *)filePath {
    NSLog(@"WaxHelper[IDEIndexCompletionStrategy]- genCompletionItems:%@ loc:%@ workSpace:%@ strFilePath:%@", txtView, location, wspace, filePath);
    NSDictionary *itemsDict = [wspace.waxIndex completionItemsForFile:filePath];
    NSArray *keywordItems = [wspace.waxIndex keywordCompletionItemsWithFilePath:filePath];

    NSMutableArray *items = [NSMutableArray array];
    [items addObjectsFromArray:itemsDict[@"methods"]];
    [items addObjectsFromArray:itemsDict[@"keywords"]];
    [items addObjectsFromArray:keywordItems];

    return items;
}
@end
