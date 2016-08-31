//
//  WaxFile.m
//  WaxHelper
//
//  Created by wbitos on 16/8/30.
//  Copyright © 2016年 wbitos. All rights reserved.
//

#import "WaxFile.h"
#import "WaxClass.h"
#import "WaxMethod.h"
#import "DVTSourceCodeSymbolKind.h"
#import "NSString+Additional.h"

@interface WaxFile ()
@property (nonatomic, strong) WaxClass *waxClass;
@property (nonatomic, strong) NSMutableArray *classCompletionItems;
@property (nonatomic, strong) NSMutableArray *methodCompletionItems;
@property (nonatomic, strong) NSMutableArray *propertyCompletionItems;

@property (nonatomic, strong) NSArray *keywords;
@property (nonatomic, strong) NSMutableArray *keywordCompletionItems;
@end

@implementation WaxFile
static NSString *_regexDefineStr = @"waxClass\\s*\\{\\s*\\\"\\w+\\\"\\s*,\\s*\\w+\\s*\\}";
static NSString *_regexMethodStr = @".*function\\s*\\w+\\(.*\\)";
static NSString *_regexKeywordStr = @"([a-zA-Z]|_|$){1}\\w*";

static NSRegularExpression* _regexDefine;
static NSRegularExpression* _regexMethod;
static NSRegularExpression* _regexKeyword;

- (instancetype)initWithContent:(NSString *)content {
    if (self = [super init]) {
        if (!_regexDefine) {
            _regexDefine = [NSRegularExpression regularExpressionWithPattern:_regexDefineStr options:0 error:nil];
        }
        if (!_regexMethod) {
            _regexMethod = [NSRegularExpression regularExpressionWithPattern:_regexMethodStr options:0 error:nil];
        }
        if (!_regexKeyword) {
            _regexKeyword = [NSRegularExpression regularExpressionWithPattern:_regexKeywordStr options:0 error:nil];
        }
        
        _classCompletionItems = [[NSMutableArray alloc] init];
        _propertyCompletionItems = [[NSMutableArray alloc] init];
        NSArray *classes = [self _defineClassesWithContent:content];
        
        _waxClass = [classes firstObject];
        
        for (WaxClass *cls in classes) {
            NSArray *items = [cls classCompletionItems];
            if (items) {
                [_classCompletionItems addObjectsFromArray:items];
            }
            NSArray *propItems = [cls propertyCompletionItems];
            if (propItems) {
                [_propertyCompletionItems addObjectsFromArray:propItems];
            }
        }
        
        _methodCompletionItems = [[NSMutableArray alloc] init];
        NSArray *methods = [self _methodsWithContent:content className:[classes.firstObject cls]];
        for (WaxMethod *method in methods) {
            WaxCompletionItem *item = method.completionItem;
            if (item) {
                [_methodCompletionItems addObject:method.completionItem];
            }
        }
        
        _keywords = [self _keywordsWithContent:content];
    }
    return self;
}

- (NSArray *)_defineClassesWithContent:(NSString *)content {
    NSMutableArray *classes = [[NSMutableArray alloc] init];
    [_regexDefine enumerateMatchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, content.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        if (result) {
            NSString *defineStr = [content substringWithRange:result.range];
            NSScanner *scanner = [NSScanner scannerWithString:defineStr];
            
            NSCharacterSet *quoteSet = [NSCharacterSet characterSetWithCharactersInString:@"\'\""];
            [scanner scanUpToCharactersFromSet:quoteSet intoString:nil];
            [scanner setScanLocation:[scanner scanLocation] + 1];
            
            NSString *className = nil;
            [scanner scanUpToCharactersFromSet:quoteSet intoString:&className];
            
            [scanner scanUpToString:@"," intoString:nil];
            [scanner setScanLocation:[scanner scanLocation] + 1];
            
            NSString *baseClassName = nil;
            [scanner scanUpToString:@"}" intoString:&baseClassName];
            NSLog(@"WaxHelper[WaxFile]- class name:%@ base:%@", className, baseClassName);
            
            WaxClass *cls = [[WaxClass alloc] initWithClass:[className trim] baseClass:[baseClassName trim] properties:nil];
            [classes addObject:cls];
        }
    }];
    return classes;
}

- (NSArray *)_methodsWithContent:(NSString *)content className:(NSString *)className {
    NSMutableArray *methods = [[NSMutableArray alloc] init];
    [_regexMethod enumerateMatchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, content.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        if (result) {
            NSString *defineStr = [[content substringWithRange:result.range] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            NSScanner *scanner = [NSScanner scannerWithString:defineStr];
            [scanner scanUpToString:@"function" intoString:nil];
            [scanner setScanLocation:[scanner scanLocation] + [@"function" length]];
            
            NSString *methodName = nil;
            [scanner scanUpToString:@"(" intoString:&methodName];
            [scanner setScanLocation:[scanner scanLocation] + 1];
            
            NSString *paramString = nil;
            [scanner scanUpToString:@")" intoString:&paramString];
            paramString = [paramString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSMutableArray *params = [NSMutableArray array];
            if ([paramString length] > 0) {
                NSArray *sepArray = [paramString componentsSeparatedByString:@","];
                for (NSString *p in sepArray) {
                    [params addObject:[p stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                }
            }
            WaxMethod *method = [[WaxMethod alloc] initWithMethodName:[methodName trim] params:params className:nil];
            [methods addObject:method];
        }
    }];
    return methods;
}

- (NSArray *)keywordCompletionItems {
    @synchronized(self) {
        if (!_keywordCompletionItems) {
            _keywordCompletionItems = [[NSMutableArray alloc] init];
            NSArray *keywords = _keywords;
            for (NSString *keyword in keywords) {
                WaxCompletionItem *item = [[WaxCompletionItem alloc] initWithDictinary:@{
                                                                                       kJPCompeletionName: keyword,
                                                                                       kJPCompeletionDisplayText: keyword,
                                                                                       kJPCompeletionText: keyword,
                                                                                       kJPCompeletionDisplayType: @"Keyword",
                                                                                       kJPCompeletionKind: [DVTSourceCodeSymbolKind functionSymbolKind],
                                                                                       }];
                [_keywordCompletionItems addObject:item];
            }
        }
        return _keywordCompletionItems;
    }
}

- (NSArray *)_keywordsWithContent:(NSString *)content {
    NSMutableArray *varArr = [[NSMutableArray alloc] init];
    
    [_regexKeyword enumerateMatchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, content.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        if (result) {
            NSString *word = [content substringWithRange:result.range];
            if (![varArr containsObject:word]) {
                [varArr addObject:word];
            }
        }
    }];
    return varArr;
}
@end
