//
//  TextMateDBGp.m
//  TextMateDBGp
//
//	Copyright (c) The MissingDrawer authors.
//	Copyright (c) Jon Lee.
//
//	Permission is hereby granted, free of charge, to any person
//	obtaining a copy of this software and associated documentation
//	files (the "Software"), to deal in the Software without
//	restriction, including without limitation the rights to use,
//	copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the
//	Software is furnished to do so, subject to the following
//	conditions:
//
//	The above copyright notice and this permission notice shall be
//	included in all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//	OTHER DEALINGS IN THE SOFTWARE.
//

#import "TextMateDBGp.h"

#import "MDSettings.h"
#import "NSWindowController+MDAdditions.h"
#import "NSWindowController+MDMethodReplacements.h"
#import "JRSwizzle.h"
#import "TDSplitView.h"

@interface TextMateDBGp (PrivateMethods)
- (void)_injectPluginMethods;
- (void)_installMenuItems;
- (void)_injectPreferenceMethods;
@end


@implementation TextMateDBGp

+ (void)load
{
    // Setup defaults
    NSColor *activeColor = [NSColor colorWithCalibratedRed:0.867f green:0.894f blue:0.918f alpha:1.0f];
    NSColor *idleColor = [NSColor colorWithCalibratedRed:0.929f green:0.929f blue:0.929f alpha:1.0f];
    NSDictionary *defaults = @{
                               kMDSidebarBackgroundColorActiveKey: [NSKeyedArchiver archivedDataWithRootObject:activeColor],
                               kMDSidebarBackgroundColorIdleKey: [NSKeyedArchiver archivedDataWithRootObject:idleColor],
                               };
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:defaults];
    
    [OakProjectController jr_swizzleMethod:@selector(windowDidLoad) withMethod:@selector(MD_repl_windowDidLoad) error:NULL];
    [OakProjectController jr_swizzleMethod:@selector(windowWillClose:) withMethod:@selector(MD_repl_windowWillClose:) error:NULL];
    [OakProjectController jr_swizzleMethod:@selector(openProjectDrawer:) withMethod:@selector(MD_repl_openProjectDrawer:) error:NULL];
    [OakProjectController jr_swizzleMethod:@selector(revealInProject:) withMethod:@selector(MD_repl_revealInProject:) error:NULL];
    [OakProjectController jr_swizzleMethod:@selector(validateMenuItem:) withMethod:@selector(TD_validateMenuItem:) error:NULL];
}

#pragma mark Class Methods

+ (NSBundle *)pluginBundle
{
	return [NSBundle bundleForClass:[self class]];
}


+ (NSImage *)bundledImageWithName:(NSString *)imageName
{
	NSBundle *pluginBundle = [[self class] pluginBundle];
	return [[NSImage alloc] initWithContentsOfFile:[pluginBundle pathForResource:imageName ofType:@"png"]];
}


+ (TDSplitView *)makeSplitViewWithMainView:(NSView *)contentView sideView:(TDSidebar *)sideView
{
    TDSplitView *splitView = [[TDSplitView alloc] initWithFrame:[contentView frame] mainView:contentView sideView:sideView];
    return splitView;
}


#pragma mark Plugin Hook

- (id)initWithPlugInController:(id<TMPlugInController>)aController
{
	if (self = [super init]) {
		[[[NSApp mainWindow] windowController] MD_splitWindowIfNeeded];
		[[[NSApp mainWindow] windowController] MD_windowDidBecomeMain:nil];
		[self _installMenuItems];
		[self _injectPreferenceMethods];
    }
    return self;
}


#pragma mark Actions

- (void)toggleSplitViewLayout:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"MDToggleSplitViewLayout" object:nil];
}


#pragma mark Private Methods

- (void)_installMenuItems
{
	NSMenu *viewMenu = [[[NSApp mainMenu] itemWithTitle:@"View"] submenu];
    
	__block NSMenuItem *toggleFileBrowserMenuItem = nil;
	__block NSInteger drawerMenuItemIndex = 0;
	
	MDSettings *settings = [MDSettings defaultSettings];

	[viewMenu.itemArray enumerateObjectsUsingBlock:^(NSMenuItem *menuItem, NSUInteger idx, BOOL *stop) {
		if ([[menuItem title] isEqualToString:@"Toggle File Browser"]) {
			toggleFileBrowserMenuItem = menuItem;
			drawerMenuItemIndex = idx;
		}
    }];
    
    if (!toggleFileBrowserMenuItem) return;
    
	NSMenuItem *debugSubmenuItem =  [[NSMenuItem alloc] initWithTitle:@"Debug panel" action:nil keyEquivalent:@""];
	NSMenu *debugMenu = [[NSMenu alloc] initWithTitle:@"Debug panel"];
    
	[debugSubmenuItem setSubmenu:debugMenu];
//	[debugMenu addItem:settings.toggleSplitViewLayoutMenuItem];
//	[debugMenu addItem:settings.focusSideViewMenuItem];
//  [debugMenu addItem:settings.filterInDrawerMenuItem];
    [debugMenu addItem:[NSMenuItem separatorItem]];
    [debugMenu addItem:settings.navigatorViewMenuItem];
    [debugMenu addItem:settings.debuggerViewMenuItem];
    [debugMenu addItem:settings.breakpointsViewMenuItem];

    [viewMenu insertItem:debugSubmenuItem atIndex:drawerMenuItemIndex + 1];
}


- (void)_injectPreferenceMethods
{
	MDLog("swapping OakPreferencesManager methods");
	
    NSError* error;
    [OakPreferencesManager jr_swizzleMethod:@selector(toolbarAllowedItemIdentifiers:) withMethod:@selector(MD_toolbarAllowedItemIdentifiers:) error:&error];
    [OakPreferencesManager jr_swizzleMethod:@selector(toolbarDefaultItemIdentifiers:) withMethod:@selector(MD_toolbarDefaultItemIdentifiers:) error:&error];
    [OakPreferencesManager jr_swizzleMethod:@selector(toolbarSelectableItemIdentifiers:) withMethod:@selector(MD_toolbarSelectableItemIdentifiers:) error:&error];
    [OakPreferencesManager jr_swizzleMethod:@selector(selectToolbarItem:) withMethod:@selector(MD_selectToolbarItem:) error:&error];
    [OakPreferencesManager jr_swizzleMethod:@selector(toolbar:itemForItemIdentifier:willBeInsertedIntoToolbar:) withMethod:@selector(MD_toolbar:itemForItemIdentifier:willBeInsertedIntoToolbar:) error:&error];
}

@end