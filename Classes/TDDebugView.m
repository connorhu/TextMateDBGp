//
//  TDDebugView.m
//  TextMateDBGp
//
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

#import "TDDebugView.h"

#import "TDDebugSession.h"
#import "TDDebugStackFrameCellView.h"
#import "TextMateDBGp.h"
#import "TDNetworkController.h"
#import "TDPlaceholderVariable.h"
#import "TDProject.h"
#import "TDSplitView.h"
#import "TDSidebar.h"
#import "TDStackContext.h"
#import "TDStackFrame.h"
#import "TDStackVariable.h"

@interface TDDebugView (PrivateMethods)
- (void)didAcceptNewSocket:(NSNotification*)notification;
- (void)didDisconnectSocket:(NSNotification*)notification;
- (void)sessionUpdated:(NSNotification*)notification;
- (void)sessionLoadedVariables:(NSNotification*)notification;
- (void)sessionUpdatedVariable:(NSNotification*)notification;
- (void)setToolbarDisabled:(BOOL)disabled;
@end

@implementation TDDebugView

// This is called when the nib is loaded.
- (id)initWithFrame:(NSRect)frameRect {
  if (!(self = [super initWithFrame:frameRect]))
    return nil;
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAcceptNewSocket:) name:TDNetworkControllerDidAcceptNewSocketNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDisconnectSocket:) name:TDNetworkControllerDidDisconnectSocketNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionUpdated:) name:TDDebugSessionDidBreakNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionLoadedVariables:) name:TDDebugSessionDidLoadVariablesNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionUpdatedVariable:) name:TDDebugSessionDidUpdateVariableNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionUpdated:) name:TDDebugSessionDidStopNotification object:nil];
  return self;
}

- (void)drawRect:(NSRect)dirtyRect {
  // set any NSColor for filling, say white:
  if (!_backgroundColor)
    return;
  [_backgroundColor setFill];
  NSRectFill(dirtyRect);
}

#pragma mark Notification
- (void)didAcceptNewSocket:(NSNotification*)notification {
  if ([_project.networkController currentOpenSession])
    [_connectionLabel setStringValue:@"1 cxn"];
  else
    [_connectionLabel setStringValue:@"? cxn"];
}
- (void)didDisconnectSocket:(NSNotification*)notification {
  if (![_project.networkController currentOpenSession])
    [_connectionLabel setStringValue:@""];
  else
    [_connectionLabel setStringValue:@"? dcxn"];
}
- (void)sessionUpdated:(NSNotification*)notification {
  TDDebugSession* session = [notification object];
  [_statusLabel setStringValue:[NSString stringWithFormat:@"%@/%@", session.lastReason, session.lastStatus]];
  [_stackTableView deselectAll:self];
  [_stackTableView reloadData];
  if ([session.lastStatus isEqualToString:DBGpStatusBreak]) {
    [NSApp activateIgnoringOtherApps:YES];
    [_sidebar selectTab:SidebarTabDebugger];
    
    [self setToolbarDisabled:NO];
    [_debugPlayButton.cell setImage:[TextMateDBGp bundledImageWithName:@"DebugPlay"]];
    [_stackTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
  }
  else {
    [self setToolbarDisabled:YES];
    // clear out the variable view
    [_variableOutlineView reloadData];
  }
}
- (void)sessionLoadedVariables:(NSNotification*)notification {
  [_variableOutlineView reloadData];
}
- (void)sessionUpdatedVariable:(NSNotification *)notification {
  id variable = [notification object];
  [_variableOutlineView reloadData];
  [_variableOutlineView expandItem:variable expandChildren:NO];
}
- (void)setToolbarDisabled:(BOOL)disabled {
  [_debugPlayButton setEnabled:!disabled];
  [_debugStepInButton setEnabled:!disabled];
  [_debugStepOutButton setEnabled:!disabled];
  [_debugStepOverButton setEnabled:!disabled];
  if (disabled)
    [_debugPlayButton.cell setImage:[TextMateDBGp bundledImageWithName:@"DebugPause"]];
}

#pragma mark Actions
- (void)toggleListener:(id)sender {
  NSButton* button = (NSButton*)sender;
  TDNetworkController* nc = _project.networkController;
  if ([nc.socket isDisconnected]) {
    [button setTitle:@"Disconnect"];
    [button setToolTip:@"Stop debugging session"];
    [nc startListening];
  }
  else {
    [button setTitle:@"Connect"];
    [button setToolTip:@"Listen for incoming connections"];
    [nc stopListening];
    [_statusLabel setStringValue:@""];
  }
}

- (void)debugButtonPressed:(id)sender {
  TDDebugSession* session = [_project.networkController currentOpenSession];
  if (sender == _debugPlayButton) {
    [session continueDebugSession];
  }
  else if (sender == _debugStepInButton) {
    [session stepIn];
  }
  else if (sender == _debugStepOutButton) {
    [session stepOut];
  }
  else if (sender == _debugStepOverButton) {
    [session stepOver];
  }
  [self setToolbarDisabled:YES];
}

- (void)toggleEnableBookmarks:(id)sender {
  _project.networkController.bookmarksEnabled = [(NSCell*)[sender cell] state] == NSOnState;
}

- (void)toggleFirstLine:(id)sender {
  _project.networkController.firstLineBreak = [(NSCell*)[sender cell] state] == NSOnState;
}

#pragma mark NSTableViewDataSource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  TDDebugSession* openSession = [_project.networkController currentOpenSession];
  if (!openSession || openSession.state != Paused)
    return 0;
  if (![openSession.lastStatus isEqualToString:DBGpStatusBreak])
    return 0;
  return [openSession.stackFrames count];
  
}
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  return [[_project.networkController currentOpenSession].stackFrames objectAtIndex:row];
}

#pragma mark NSTableViewDelegate
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  TDDebugStackFrameCellView* view = [tableView makeViewWithIdentifier:@"StackFrameCell" owner:self];
  TDStackFrame* stackFrame = [tableView.dataSource tableView:tableView objectValueForTableColumn:tableColumn row:row];
  view.textField.stringValue = [stackFrame stackFunction];
  view.filenameTextField.stringValue = [NSString stringWithFormat:@"%@:%d", [[stackFrame fileName] lastPathComponent], [stackFrame lineNumber]];
  view.stackDepthTextField.stringValue = [NSString stringWithFormat:@"%d", [stackFrame stackLevel]];
  return view;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
  NSTableView* tableView = [notification object];
  if ([tableView selectedRow] < 0)
    return;
  
  TDStackFrame* stackFrame = [tableView.dataSource tableView:tableView objectValueForTableColumn:nil row:[tableView selectedRow]];
  [_project openFile:[stackFrame fileName] atLineNumber:[stackFrame lineNumber]];
  [[_project.networkController currentOpenSession] loadVariablesAtStackLevel:[stackFrame stackLevel]];
}

#pragma mark NSOutlineViewDataSource
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
  if (item == nil) {
    int selectedRow = [_stackTableView selectedRow];
    if (selectedRow < 0)
      return nil;
    TDStackFrame* stackFrame = [self tableView:nil objectValueForTableColumn:nil row:selectedRow];
    return [stackFrame outlineViewItemForRow:index];
  }
  return [[(TDStackVariable*)item variables] objectAtIndex:index];
}
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
  if (item == nil) {
    int selectedRow = [_stackTableView selectedRow];
    if (selectedRow < 0)
      return 0;
    TDStackFrame* stackFrame = [self tableView:nil objectValueForTableColumn:nil row:selectedRow];
    if (stackFrame)
      return [stackFrame outlineViewItemCount];
    return 0;
  }
  else if ([item isMemberOfClass:[TDStackVariable class]]) {
    return [[(TDStackVariable*)item variables] count];
  }
  return 0;
}
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
  return [item isMemberOfClass:[TDStackVariable class]] && [(TDStackVariable*)item hasChildren];
}
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
  if ([item isMemberOfClass:[TDPlaceholderVariable class]]) {
    return @"Loading...";
  }
  if ([item isMemberOfClass:[TDStackContext class]]) {
    TDStackContext* context = item;
    if ([[tableColumn identifier] isEqualToString:@"Outline"])
      return context.name;
    return nil;
  }

  NSAttributedString* s = [(TDStackVariable*)item attributedStringWithDefaultFont:[(NSTextFieldCell*)[tableColumn dataCell] font]];
  return s;
}

#pragma mark NSOutlineViewDelegate
- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item {
  if ([item isMemberOfClass:[TDPlaceholderVariable class]])
    [[_project.networkController currentOpenSession] updatePendingVariable:item];
  
  [cell setAttributedStringValue:[outlineView.dataSource outlineView:outlineView objectValueForTableColumn:tableColumn byItem:item]];
}
- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
  return item && [item isMemberOfClass:[TDStackContext class]];
}
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
  return ![item isMemberOfClass:[TDStackContext class]];
}

@end
