//
//  JPObjcMethod.h
//  Wax
//
//  Created by louis on 4/16/16.
//  Copyright © 2016 louis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WaxCompletionItem.h"

@interface JPObjcMethod : NSObject

@property (nonatomic, strong) NSMutableArray *args;
@property (nonatomic, strong) NSString *methodName;
@property (nonatomic, assign) BOOL isClassMethod;
@property (nonatomic, strong) NSString *returnType;
@property (nonatomic, strong) NSString *className;

-(instancetype)initWithParseResult:(void *)result;
-(NSString *)displayString;
-(NSString *)completionString;
- (WaxCompletionItem *)completionItem;
@end
