//
//  WaxIndex.m
//  WaxHelper
//
//  Created by wbitos on 16/8/30.
//  Copyright © 2016年 wbitos. All rights reserved.
//

#import "WaxIndex.h"
#import "IDEWorkspace.h"
#import "IDEWorkspace+Wax.h"
#import "WaxFile.h"
#import "WaxObjcIndex.h"
#import "WaxCompletionItem.h"
#import "DVTSourceCodeSymbolKind.h"
#import "WaxClass.h"
#import "WaxMethod.h"

@interface WaxIndex ()
@property (nonatomic, strong) IDEWorkspace *workspace;
@property (nonatomic, strong) NSDictionary *allCompletionItemsCache;
@property (nonatomic, strong) NSArray *keywordCompletionItemsCache;
@property (nonatomic, strong) NSMutableDictionary *waxFileCache;

@end

@implementation WaxIndex
- (instancetype)initWithWorkspace:(IDEWorkspace *)workspace {
    self = [super init];
    if (self) {
        _workspace = workspace;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFileSaved:) name:@"WaxFileSaved" object:nil];
    }
    return self;
}

- (void)handleFileSaved:(NSNotification *)notification {
    NSLog(@"WaxHelper[WaxIndex]- handleFileSaved:");
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @synchronized(self) {
            NSString *filePath = notification.object;
            if ([filePath hasSuffix:@".lua"]) {
                if (_waxFileCache) {
                    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
                    WaxFile *file = [[WaxFile alloc] initWithContent:content];
                    [_waxFileCache setObject:file forKey:filePath];
                }
                if (_allCompletionItemsCache) {
                    _allCompletionItemsCache = nil;
                }
            }
        }
    });
}

- (NSArray *)completionItemsForFile:(NSString *)filePath preWord:(NSString *)preWord indexType:(EWaxIndexType)eType {
    @synchronized(self) {
        if (!_waxFileCache) {
            _waxFileCache = [self _scanProjectWax];
        }
    }
    NSLog(@"WaxHelper[WaxIndex]- completionItemsForFile:%@ preWord:%@ indexType:%ld", filePath, preWord, (long)eType);
    NSMutableArray *completionItems = [[NSMutableArray alloc] init];
    WaxFile *file = _waxFileCache[filePath];
    
    if (file.waxClass) {
        if (eType == eWaxIndexTypeProperty) {
            NSArray *propertyItems = [file.waxClass propertyCompletionItems];
            NSLog(@"WaxHelper[WaxIndex]- propertyItems:%@ for:%@", propertyItems, file.waxClass.className);
            [self _addItemsFrom:propertyItems to:completionItems];
        }
        else if (eType == eWaxIndexTypeMethod) {
            NSArray *propertySetterItems = [file.waxClass propertySetterCompletionItems];
            NSLog(@"WaxHelper[WaxIndex]- propertySetterItems:%@ for:%@", propertySetterItems, file.waxClass.className);
            [self _addItemsFrom:propertySetterItems to:completionItems];
            
            NSArray *methodItems = [file.waxClass methodCompletionItems];
            NSLog(@"WaxHelper[WaxIndex]- methodItems:%@ for:%@", methodItems, file.waxClass.className);
            [self _addItemsFrom:methodItems to:completionItems];
        }
    }
    
    if (eType == eWaxIndexTypeMethod) {
        if (file.waxClass.className) {
            NSArray *ocMethodItems = [_workspace.objcIndex methodCompletionItemsWithClasses:@[file.waxClass.className]];
            NSLog(@"WaxHelper[WaxIndex]- ocMethodItems:%@ for:%@", ocMethodItems, file.waxClass.className);
            [self _addItemsFrom:ocMethodItems to:completionItems];
        }
        
        if (file.waxClass.baseCls) {
            NSArray *ocBaseMethodItems = [_workspace.objcIndex methodCompletionItemsWithClasses:@[file.waxClass.baseCls]];
            NSLog(@"WaxHelper[WaxIndex]- ocBaseMethodItems:%@ for:%@", ocBaseMethodItems, file.waxClass.baseCls);
            [self _addItemsFrom:ocBaseMethodItems to:completionItems];
        }
    }
    if (eType == eWaxIndexTypeUnknown) {
        
    }
    [self _addItemsFrom:[file.waxClass classCompletionItems] to:completionItems];
    [self _addItemsFrom:[_workspace.objcIndex protocolCompletionItems] to:completionItems];
    
    return completionItems;
}

-(NSArray *)suggestQuickCompletionTemplate {
    if (!_keywordCompletionItemsCache) {
        NSMutableArray *items = [[NSMutableArray alloc] init];
        NSArray *symbols = [self _loadKeywordTemplates];
        for (int i = 0; i < symbols.count; ++i) {
            NSDictionary *dict = [symbols objectAtIndex:i];
            [items addObject:[[WaxCompletionItem alloc] initWithDictinary:dict]];
        }
        _keywordCompletionItemsCache = items;
    }
    return _keywordCompletionItemsCache;
}

-(NSArray *)_loadKeywordTemplates {
    NSString * fpath = [[NSBundle bundleForClass:[WaxIndex class]] pathForResource:@"keywordTemplate" ofType:@"plist"];
    NSDictionary *dc = [NSDictionary dictionaryWithContentsOfFile:fpath];
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i = 0; i < dc.allValues.count; ++i) {
        NSDictionary *item = [dc.allValues objectAtIndex:i];
        NSMutableDictionary *newItem = [NSMutableDictionary dictionaryWithDictionary:item];
        [newItem setObject:[DVTSourceCodeSymbolKind classMethodTemplateSymbolKind] forKey:@"kJPCompeletionKind"];
        [arr addObject:newItem];
    }
    
    return arr;
}

- (void)_addItemsFrom:(NSArray *)fromItems to:(NSMutableArray *)toItems {
    for (WaxCompletionItem *fromItem in fromItems) {
        BOOL exist = NO;
        for (WaxCompletionItem *toItem in toItems) {
            if ([toItem.name isEqualToString:fromItem.name]) {
                exist = YES;
                break;
            }
        }
        if (!exist) [toItems addObject:fromItem];
    }
}

- (NSMutableDictionary *)_scanProjectWax {
    NSMutableDictionary *fileCache = [[NSMutableDictionary alloc] init];
    NSString *folder = [_workspace currentProjectFolder];
    if (folder.length) {
        NSArray *fileList = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:folder error:nil];
        for (NSString *file in fileList) {
            if ([file hasSuffix:@".lua"]) {
                NSString *filePath = [NSString stringWithFormat:@"%@/%@", folder, file];
                NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
                WaxFile *file = [[WaxFile alloc] initWithContent:content];
                [fileCache setObject:file forKey:filePath];
            }
        }
    }
    return fileCache;
}

- (NSArray *)methodCompletionItemsWithFilePath:(NSString *)filePath {
    NSLog(@"WaxHelper[WaxIndex]- methodCompletionItemsWithFilePath:%@", filePath);
    @synchronized(self) {
        if (_waxFileCache && _waxFileCache[filePath]) {
            WaxFile *file = _waxFileCache[filePath];
            return nil;
        }
        return nil;
    }
}

- (NSArray *)keywordCompletionItemsWithFilePath:(NSString *)filePath {
    NSLog(@"WaxHelper[WaxIndex]- keywordCompletionItemsWithFilePath:%@", filePath);
    @synchronized(self) {
        if (_waxFileCache && _waxFileCache[filePath]) {
            WaxFile *file = _waxFileCache[filePath];
            return file.keywordCompletionItems;
        }
        return nil;
    }
}
@end
