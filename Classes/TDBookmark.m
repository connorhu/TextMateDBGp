//
//  TDBookmark.m
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

#import "TDBookmark.h"

@implementation TDBookmark
@synthesize source = _source;
@synthesize lineNumber = _lineNumber;
@synthesize bookmarkId = _bookmarkId;

- (id)init {
  if (!(self = [super init]))
    return nil;
  _bookmarkId = -1;
  return self;
}
- (id)copyWithZone:(NSZone *)zone {
  TDBookmark* bookmark = [TDBookmark allocWithZone:zone];
  bookmark.source = _source;
  bookmark.lineNumber = _lineNumber;
  bookmark.bookmarkId = _bookmarkId;
  return bookmark;
}

- (BOOL)bookmarkIdDetermined {
  return _bookmarkId != -1;
}

- (NSString*)description {
  return [NSString stringWithFormat:@"<%@: 0x%0x, id:%d, source: \"%@\", lineNumber: %d>", [self class], self, _bookmarkId, _source, _lineNumber];
}
@end
