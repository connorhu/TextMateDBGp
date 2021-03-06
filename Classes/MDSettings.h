//
//  MDSettings.h
//  TextMateDBGp
//
//	Copyright (c) The MissingDrawer authors.
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

@interface MDSettings : NSObject {

}

@property (nonatomic, readonly) NSMenuItem *toggleSplitViewLayoutMenuItem;
@property (nonatomic, readonly) NSMenuItem *focusSideViewMenuItem;
@property (nonatomic, readonly) NSMenuItem *filterInDrawerMenuItem;
@property (nonatomic, readonly) NSMenuItem *navigatorViewMenuItem;
@property (nonatomic, readonly) NSMenuItem *debuggerViewMenuItem;
@property (nonatomic, readonly) NSMenuItem *breakpointsViewMenuItem;
@property BOOL showSideViewOnLeft;
@property NSRect sideViewLayout;
@property NSRect mainViewLayout;
@property (nonatomic, retain) NSColor *bgColor;
@property (nonatomic, retain) NSColor *bgColorInactive;
@property (nonatomic, readonly) NSDictionary *namedColors;

+ (MDSettings *)defaultSettings;

- (void)save;
- (IBAction)toggleSideViewLayout:(id)sender;
- (IBAction)focusSideView:(id)sender;
- (IBAction)filterInDrawer:(id)sender;
- (IBAction)showView:(id)sender;
@end
