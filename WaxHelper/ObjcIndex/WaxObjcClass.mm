//
//  WaxObjcClass.m
//  Wax
//
//  Created by louis on 4/16/16.
//  Copyright © 2016 louis. All rights reserved.
//

#import "WaxObjcClass.h"
#import "objcParser.h"
#import "WaxObjcMethod.h"
#import "WaxObjcArg.h"

@implementation WaxObjcClass {
    NSMutableArray *_methods;
    BOOL _isCategory;
    NSString *_cateName;
    NSString *_clsName;
    NSString *_superClsName;
}

-(instancetype)initWithParseResult:(void *)result{
    if (self = [super init]) {
        InterfaceSymbol *itfsym = (InterfaceSymbol *)result;
        _methods = [[NSMutableArray alloc] initWithCapacity:itfsym->methods.size()];
        _isCategory = itfsym->isCategory != 0;
        _cateName = [NSString stringWithUTF8String:itfsym->cateName.c_str()];
        _clsName = [NSString stringWithUTF8String:itfsym->clsName.c_str()];
        _superClsName = [NSString stringWithUTF8String:itfsym->superClsName.c_str()];
        for (int idx = 0; idx < itfsym->methods.size(); ++idx) {
            MethodSymbol *msym = itfsym->methods[idx];
            WaxObjcMethod *objcMethod = [[WaxObjcMethod alloc] initWithParseResult:msym];
            objcMethod.className = _clsName;
            [_methods addObject:objcMethod];
        }
        
        for (int idx = 0; idx < itfsym->properties.size(); ++idx) {
            PropertySymbol *propsym = itfsym->properties[idx];
            
            //getter
            WaxObjcMethod *objcMethodGetter = [[WaxObjcMethod alloc] init];
            objcMethodGetter.methodName = [NSString stringWithUTF8String:propsym->propertyName.c_str()];
            objcMethodGetter.returnType = [NSString stringWithUTF8String:propsym->propertyType.c_str()];
            objcMethodGetter.className = _clsName;
            [_methods addObject:objcMethodGetter];
            
            if (![self isPropertyReadOnly:propsym]) {
                //setter
                WaxObjcMethod *objcMethodSetter = [[WaxObjcMethod alloc] init];
                objcMethodSetter.methodName = [NSString stringWithFormat:@"set%@",[NSString stringWithUTF8String:propsym->propertyName.c_str()]];
                if (objcMethodSetter.methodName.length > 3) {
                    NSString *c = [objcMethodSetter.methodName substringWithRange:NSMakeRange(3, 1)];
                    objcMethodSetter.methodName = [objcMethodSetter.methodName stringByReplacingCharactersInRange:NSMakeRange(3,1) withString:c.uppercaseString];
                }
                objcMethodSetter.returnType = @"void";
                
                
                WaxObjcArg *objcArg = [[WaxObjcArg alloc] init];
                objcArg.argName = [NSString stringWithUTF8String:propsym->propertyName.c_str()];
                objcArg.selector = objcMethodSetter.methodName;
                objcArg.argType = objcMethodGetter.returnType;
                
                objcMethodSetter.args = [NSMutableArray arrayWithObject:objcArg];
                objcMethodSetter.className = _clsName;
                [_methods addObject:objcMethodSetter];
            }
        }
        
        
    }
    return self;
}

-(BOOL)isPropertyReadOnly:(PropertySymbol *)props{
    for (int i = 0; i < props->attributes.size(); ++i){
        if (props->attributes[i] == "readonly") {
            return YES;
        }
    }
    return NO;
}
@end
