//
//  RecordFile.h
//  SimpleRecord
//
//  Created by xiaoyezi on 15/3/13.
//  Copyright (c) 2015年 xiaoyezi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface RecordFile : NSObject

@property (nonatomic, strong) NSURL *file;
@property (nonatomic, strong) NSMutableData *fileData;
@property (nonatomic, strong) AVAudioFile *audioFile;

- (void)saveFileWithCurrentTime;

@end
