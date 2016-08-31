//
//  IDEWorkspace+Wax.m
//  WaxHelper
//
//  Created by wbitos on 16/8/30.
//  Copyright © 2016年 wbitos. All rights reserved.
//

#import "IDEWorkspace+Wax.h"
#import <objc/runtime.h>
#import "DVTFilePath.h"
#import "XCBuildConfiguration.h"
#import "XCConfigurationList.h"
#import "DVTMacroDefinitionTable.h"
#import "PBXTarget.h"

@implementation IDEWorkspace (Wax)

- (WaxObjcIndex *)objcIndex {
    WaxObjcIndex *objcIndex = objc_getAssociatedObject(self, @"_objcIndex");
    if (!objcIndex) {
        objcIndex = [[WaxObjcIndex alloc] initWithWorkspace:self];
        objc_setAssociatedObject(self, @"_objcIndex", objcIndex, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return objcIndex;
}

- (WaxIndex *)waxIndex {
    WaxIndex *waxIndex = objc_getAssociatedObject(self, @"_waxIndex");
    if (!waxIndex) {
        waxIndex = [[WaxIndex alloc] initWithWorkspace:self];
        objc_setAssociatedObject(self, @"_waxIndex", waxIndex, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return waxIndex;
}

-(PBXProject *)_currentProject {
    NSArray *projects = [PBXProject openProjects];
    PBXProject *currentProject;
    for (int i = 0; i < projects.count; ++i) {
        PBXProject *proj = projects[i];
        if ([proj.path isEqualToString:self.xcprojFile]) {
            currentProject = proj;
            break;
        }
    }
    return currentProject;
}

- (NSString *)currentProjectFolder {
    return [self.representingFilePath.pathString stringByDeletingLastPathComponent];
}

- (NSArray *)defaultScanHeaderDirs {
    NSString * fpath = [[NSBundle bundleForClass:[WaxObjcIndex class]] pathForResource:@"defScanFramwork" ofType:@"plist"];
    NSDictionary *dc = [NSDictionary dictionaryWithContentsOfFile:fpath];
    
    NSMutableArray * dirs = [[NSMutableArray alloc] init];
    NSArray * sdks = [self _allCurProjFramworkSearchPaths:[self _currentProject]];
    NSLog(@"WaxHelper[IDEWorkspace]- defaultScanHeaderDirs: %@", sdks);
    for (NSString *sdk in sdks) {
        for (NSString * framwork in dc.allKeys) {
            NSString * headerDir = [NSString stringWithFormat:@"%@/System/Library/Frameworks/%@/Headers", sdk, framwork];
            if (![dirs containsObject:headerDir]) {
                [dirs addObject:headerDir];
            }
        }
    }
    
    return dirs;
}

- (NSString *)xcprojFile {
    if ([self respondsToSelector:@selector(wrappedXcode3ProjectPath)]) {
        return self.wrappedXcode3ProjectPath.pathString;
    }else if ([self respondsToSelector:@selector(wrappedContainerPath)]){
        return self.wrappedContainerPath.pathString;
    }
    return @"";
}

-(NSArray *)SDKDirs {
    NSMutableArray * dirs = [[NSMutableArray alloc] init];
    NSArray * sdks = [self _allCurProjFramworkSearchPaths:[self _currentProject]];
    for (NSString *sdk in sdks) {
        NSString * headerDir = [NSString stringWithFormat:@"%@/System/Library/Frameworks/", sdk];
        if (![dirs containsObject:headerDir]) {
            [dirs addObject:headerDir];
        }
    }
    return dirs;
}

-(NSArray *)_allCurProjFramworkSearchPaths:(PBXProject *)proj{
    NSArray * targets = [proj targets];
    NSMutableArray *paths = [[NSMutableArray alloc] init];
    
    //read project configuration
    XCConfigurationList *configs = proj.buildConfigurationList;
    for (XCBuildConfiguration * config in configs.buildConfigurations) {
        NSString *sdkspec = [self _sdkPathOfConfiguration:config];
        if (sdkspec && ![paths containsObject:sdkspec]) {
            [paths addObject:sdkspec];
        }
    }
    
    for (PBXTarget * target in targets) {
        XCConfigurationList *clist = target.buildConfigurationList;
        
        for (XCBuildConfiguration * config in clist.buildConfigurations) {
            NSString *sdkspec = [self _sdkPathOfConfiguration:config];
            if (sdkspec && ![paths containsObject:sdkspec]) {
                [paths addObject:sdkspec];
            }
        }
    }
    return paths;
}

-(NSString *)_sdkPathOfConfiguration:(XCBuildConfiguration *)config {
    DVTMacroDefinitionTable * macroTable = [config buildSettings];
    NSString * sdkfmt = @"/Applications/Xcode.app/Contents/Developer/Platforms/%@.platform/Developer/SDKs";
    NSString * sdk;
    NSString * platform;
    NSString * sdkVersion;
    if (macroTable) {
        NSString *sdkroot = [macroTable valueForKey:@"SDKROOT"];
        if (!sdkroot.length) {
            return nil;
        }
        
        if ([sdkroot.lowercaseString hasPrefix:@"iphoneos"]) {
            platform = @"iPhoneOS";
        }else if ([sdkroot.lowercaseString hasPrefix:@"macosx"]) {
            platform = @"MacOSX";
        }else{
            //not support
            return nil;
        }
        sdkVersion = [sdkroot substringFromIndex:platform.length];
        NSString *sdkParentDir = [NSString stringWithFormat:sdkfmt, platform];
        NSString *lastSDK = [self _lastVersionSDK:sdkParentDir paltform:platform];
        
        if (sdkVersion.length == 0) {
            return lastSDK;
        }else{
            //check spec version sdk exist
            sdk = [NSString stringWithFormat:@"%@/%@%@.sdk", sdkParentDir, platform, sdkVersion];
            if ([[NSFileManager defaultManager] fileExistsAtPath:sdk]) {
                return sdk;
            }else{
                return lastSDK;
            }
        }
    }
    
    return sdk;
}

-(NSString *)_lastVersionSDK:(NSString *)sdkParentDir paltform:(NSString *)platform{
    NSFileManager *fsmanager = [NSFileManager defaultManager];
    
    if (![fsmanager fileExistsAtPath:sdkParentDir]) {
        //not install xcode.app
        return nil;
    }
    
    NSError *err;
    NSArray * sdks = [fsmanager contentsOfDirectoryAtPath:sdkParentDir error:&err];
    if (sdks.count == 0) {
        //not install sdk
        return nil;
    }
    
    NSString *lastMainVer = @"";
    NSString *lastSubVer = @"";
    NSString *lastVersionStr = @"";
    for (NSString * sdk in sdks) {
        if (![sdk hasPrefix:platform]) {
            continue;
        }
        NSString *mv;
        NSString *sv;
        
        if ([self _versionOfSDKName:sdk platform:platform mainVer:&mv subver:&sv]) {
            if (mv.integerValue > lastMainVer.integerValue) {
                lastMainVer = mv;
                lastSubVer = sv;
                lastVersionStr = sdk;
            }else if (mv.integerValue == lastMainVer.integerValue){
                if (sv.integerValue > lastSubVer.integerValue) {
                    lastMainVer = mv;
                    lastSubVer = sv;
                    lastVersionStr = sdk;
                }
            }
        }
    }
    
    return [NSString stringWithFormat:@"%@/%@", sdkParentDir, lastVersionStr];
}

//iPhoneOS8.2.sdk
//MacOSX10.10.sdk
-(BOOL)_versionOfSDKName:(NSString*)sdkname platform:(NSString *)platform mainVer:(NSString **)mainver subver:(NSString **)subver {
    if (sdkname.length == 0) {
        return NO;
    }
    
    if (![sdkname hasPrefix:platform]) {
        return NO;
    }
    
    NSArray *tokens = [[sdkname substringFromIndex:platform.length] componentsSeparatedByString:@"."];
    
    if (tokens.count == 3) {
        *mainver = tokens[0];
        *subver = tokens[1];
        return YES;
    }
    
    return NO;
}
@end
