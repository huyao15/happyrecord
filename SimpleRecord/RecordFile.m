//
//  RecordFile.m
//  SimpleRecord
//
//  Created by xiaoyezi on 15/3/13.
//  Copyright (c) 2015年 xiaoyezi. All rights reserved.
//

#import "RecordFile.h"

@implementation RecordFile

- (instancetype)init {
	self = [super init];
	if (self) {
		self.file = nil;
	}
	return self;
}

- (void)saveFileWithCurrentTime {
	NSDate *date = [NSDate date];
	NSTimeInterval timeInterval = [date timeIntervalSince1970];
	self.file = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%f.caf",[[NSBundle mainBundle] resourcePath],timeInterval]];
}


#pragma mark - getter
- (NSMutableData *)fileData {
    if (_fileData == nil) {
        _fileData = [[NSMutableData alloc] init];
    }
    return _fileData;
}

@end
