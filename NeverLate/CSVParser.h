/*
 * cCSVParse, a small CVS file parser
 *
 * © 2007-2009 Michael Stapelberg and contributors
 * http://michael.stapelberg.de/
 *
 * This source code is BSD-licensed, see LICENSE for the complete license.
 *
 */
#import <Foundation/Foundation.h>

@interface CSVParser : NSObject {
	int fileHandle;
}

@property (nonatomic) char delimiter;
@property (nonatomic) int bufferSize;
@property (nonatomic) NSStringEncoding encoding;

-(id)initWithFile:(NSString *)fileName;

-(BOOL)openFile:(NSString*)fileName;
-(void)closeFile;

-(char)autodetectDelimiter;

-(void)parseFileLines:(void(^)(NSArray *line))lineCallback;

@end
