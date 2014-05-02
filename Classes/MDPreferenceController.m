//
//  MDPreferenceController.m
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

#import "MDPreferenceController.h"


@implementation MDPreferenceController

@synthesize preferencesView;


+ (instancetype)instance {
    static id instanceObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instanceObject = [[self alloc] init];
    });
    
    return instanceObject;
}

- (id)init {
	if ((self = [super init])) {
		// Load the preference NIB
		NSString* nibPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"Preferences" ofType:@"nib"];
		_preferenceWindowController = [[NSWindowController alloc] initWithWindowNibPath:nibPath owner:self];
		[_preferenceWindowController showWindow:self];
		
    }
	return self; 
}


- (void)awakeFromNib {
	[super awakeFromNib];
	
	NSBundle *pluginBundle = [NSBundle bundleForClass:[self class]];
	NSString *version = [[pluginBundle infoDictionary] objectForKey:@"CFBundleVersion"];
	
	NSString *string = [[NSString alloc] initWithFormat:@"TextMateDBGp %@", version];
	[versionTextField setStringValue:string];
}

@end
