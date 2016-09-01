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
#import "RegexKitLite.h"

@interface WaxFile ()
@property (nonatomic, strong) WaxClass *waxClass;

@property (nonatomic, strong) NSArray *keywords;
@property (nonatomic, strong) NSMutableArray *keywordCompletionItems;
@property (nonatomic, strong) NSMutableArray *methodCompletionItems;

@end

@implementation WaxFile
//static NSString *_regexDefineStr = @"waxClass\\s*\\{\\s*\\\"\\w+\\\"\\s*,\\s*\\w+\\s*\\}";
static NSString *_regexWaxClassDefineStr = @"waxClass\\s*\\{\\s*\\\"(\\w+)\\\"\\s*(,\\s*\\w+\\s*){0,1}(,\\s*protocols\\s*=\\s*\\{(\\s*\\\"\\S+\\\"\\s*,{0,1})*\\}){0,1}\\s*\\}";
static NSString *_regexMethodStr = @".*function\\s*(\\w+)\\s*\\((.*)\\)";
static NSString *_regexKeywordStr = @"([a-zA-Z]|_|$){1}\\w*";
static NSString *_regexPropertyStr = @"self.(\\w+)\\s*=";

static NSRegularExpression* _regexMethod;
static NSRegularExpression* _regexKeyword;

- (instancetype)initWithContent:(NSString *)content {
    if (self = [super init]) {
        if (!_regexKeyword) {
            _regexKeyword = [NSRegularExpression regularExpressionWithPattern:_regexKeywordStr options:0 error:nil];
        }
                
        _waxClass = [self _defineClasseWithContent:content];
        _keywords = [self _keywordsWithContent:content];
    }
    return self;
}

- (WaxClass *)_defineClasseWithContent:(NSString *)content {
    NSDictionary *matches = [content dictionaryByMatchingRegex:_regexWaxClassDefineStr withKeysAndCaptures:@"className", 1, @"baseClassName", 2, @"protocols", 3, nil];
    NSString *classNameString = matches[@"className"];
    NSString *baseClassNameString = matches[@"baseClassName"];
    if (baseClassNameString) {
        if ([baseClassNameString hasPrefix:@","]) {
            baseClassNameString = [baseClassNameString substringFromIndex:1];
        }
    }
    NSMutableArray *protocols = [NSMutableArray array];
    NSString *protocolsString = matches[@"protocols"];
    if (protocolsString) {
        NSScanner *scanner = [[NSScanner alloc] initWithString:protocolsString];
        [scanner scanUpToString:@"{" intoString:nil];
        [scanner setScanLocation:[scanner scanLocation] + 1];
        [scanner scanUpToString:@"}" intoString:&protocolsString];
        
        for (NSString *s in [protocolsString componentsSeparatedByString:@","]) {
            NSString *protocol = [[s stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
            [protocols addObject:protocol];
        }
    }
    
    NSString *className = [classNameString trim];
    
    NSArray *methodMatches = [content arrayOfDictionariesByMatchingRegex:_regexMethodStr withKeysAndCaptures:@"methodName", 1, @"parameters", 2, nil];
    NSMutableArray *methods = [NSMutableArray array];
    for (NSDictionary *methodMatch in methodMatches) {
        NSString *methodName = methodMatch[@"methodName"];
        NSString *parameterString = methodMatch[@"parameters"];
        NSMutableArray *parameters = [NSMutableArray array];
        for (NSString *p in [parameterString componentsSeparatedByString:@","]) {
            [parameters addObject:[p stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        }
        WaxMethod *method = [[WaxMethod alloc] initWithMethodName:[methodName trim] params:parameters className:className];
        [methods addObject:method];
    }
    
    NSArray *propertyMatches = [content arrayOfDictionariesByMatchingRegex:_regexPropertyStr withKeysAndCaptures:@"propertyName", 1, nil];
    NSMutableArray *properties = [NSMutableArray array];
    [properties addObject:@"super"];

    for (NSDictionary *propertyMatch in propertyMatches) {
        NSString *propertyName = propertyMatch[@"propertyName"];
        if (![properties containsObject:propertyName]) {
            [properties addObject:propertyName];
        }
    }

    WaxClass *cls = [[WaxClass alloc] initWithClass:className baseClass:[baseClassNameString trim] protocols:protocols properties:properties methods:methods];
    return cls;
}

- (NSArray *)methodCompletionItems {
    @synchronized(self) {
        if (_methodCompletionItems == nil) {
            _methodCompletionItems = [NSMutableArray array];
            
            for (WaxMethod *method in _waxClass.methods) {
                WaxCompletionItem *item = [method completionItem];
                if (item) {
                    [_methodCompletionItems addObject:item];
                }
            }
        }
        return _methodCompletionItems;
    }
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
