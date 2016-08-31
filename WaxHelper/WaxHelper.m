//
//  WaxHelper.m
//  WaxHelper
//
//  Created by wbitos on 16/8/30.
//  Copyright © 2016年 wbitos. All rights reserved.
//

#import "WaxHelper.h"

@interface WaxHelper()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end

@implementation WaxHelper

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    return self;
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
    //removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
//    // Create menu items, initialize UI, etc.
//    // Sample Menu Item:
//    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
//    if (menuItem) {
//        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
//        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Do Action" action:@selector(doMenuAction) keyEquivalent:@""];
//        //[actionMenuItem setKeyEquivalentModifierMask:NSAlphaShiftKeyMask | NSControlKeyMask];
//        [actionMenuItem setTarget:self];
//        [[menuItem submenu] addItem:actionMenuItem];
//    }
}

//// Sample Action, for menu item:
//- (void)doMenuAction {
//    NSLog(@"doMenuAction");
//    NSAlert *alert = [[NSAlert alloc] init];
//    [alert setMessageText:@"Hello, World"];
//    [alert runModal];
//}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
