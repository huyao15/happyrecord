//
//  ViewController.m
//  SimpleRecord
//
//  Created by xiaoyezi on 15/3/13.
//  Copyright (c) 2015年 xiaoyezi. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAudioSession.h>
#import "RecordFile.h"
#import "MidiFile.h"
#import "MidiFileSerialize.h"

@interface ViewController () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, assign, getter=isRecording) BOOL recording;

@property (weak, nonatomic) IBOutlet UIButton *RecordButton;
@property (weak, nonatomic) IBOutlet UIButton *PlayButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) RecordFile *recordFile;

@property (nonatomic, strong) NSArray *midiEventArray;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
		[[AVAudioSession sharedInstance] performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
			if (granted) {
				// Microphone enabled code
				NSLog(@"Microphone is enabled..");
			}
			else {
				// Microphone disabled code
				NSLog(@"Microphone is disabled..");

				// We're in a background thread here, so jump to main thread to do UI work.
				dispatch_async(dispatch_get_main_queue(), ^{
					[[[UIAlertView alloc] initWithTitle:@"Microphone Access Denied"
												 message:@"This app requires access to your device's Microphone.\n\nPlease enable Microphone access for this app in Settings / Privacy / Microphone"
												delegate:nil
									   cancelButtonTitle:@"Dismiss"
									   otherButtonTitles:nil] show];
				});
			}
		}];
	}

    MidiFile *midiFile = [[[MidiFileSerialize alloc] init] loadWithMidName:@"test" type:@"mid"];
    [self setMidiEventsWithFile:midiFile];
}

- (void)setMidiEventsWithFile:(MidiFile *)midiFile {
    if (midiFile != nil) {
        NSMutableArray *events = [NSMutableArray array];
        for (int i = 0; i < midiFile.tracks.count; i++) {
            ITrack *track = [midiFile.tracks objectAtIndex:i];
            [events addObjectsFromArray:track.events];
            [events addObjectsFromArray:track.rests];
            [events addObjectsFromArray:track.lightEvents];
        }
        [events addObjectsFromArray:midiFile.tempos];
        [events sortedArrayUsingComparator:^NSComparisonResult(BaseEvent *a, BaseEvent *b) {
            if (a.tick == b.tick) {
                if ([a isKindOfClass:[Event class]] && [b isKindOfClass:[Event class]]) {
                    Event *eventA = (Event *)a;
                    Event *eventB = (Event *)b;
                    return [self notePitchFromEvent:eventA.event] - [self notePitchFromEvent:eventB.event];
                }
            }
            return a.tick - b.tick;
        }];
        self.midiEventArray = events;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.messageLabel.text = @"点击 Record 开始录音";
}

- (int)notePitchFromEvent:(unsigned int)event {
    return (event & 0xff00) >> 8;
}

- (IBAction)RecordAction:(id)sender {
	AVAudioSession * audioSession = [AVAudioSession sharedInstance];
	if (!self.isRecording) {
		self.recording = YES;
		[self statuForRecording];
		[audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
		[audioSession setActive:YES error:nil];

		NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] initWithCapacity:10];
		NSNumber *formatObject;
		formatObject = [NSNumber numberWithInt: kAudioFormatAppleIMA4];
		[recordSettings setObject:formatObject forKey: AVFormatIDKey];
		[recordSettings setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];
		[recordSettings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
		[recordSettings setObject:[NSNumber numberWithInt:12800] forKey:AVEncoderBitRateKey];
		[recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
		[recordSettings setObject:[NSNumber numberWithInt: AVAudioQualityHigh] forKey: AVEncoderAudioQualityKey];
		[self.recordFile saveFileWithCurrentTime];
		self.recorder = [[AVAudioRecorder alloc] initWithURL:self.recordFile.file settings:recordSettings error:nil];
		[self.recorder setDelegate:self];
		[self.recorder prepareToRecord];
		[self.recorder record];
	} else {
		[self statusForStopRecor];
		self.recording = NO;
		[audioSession setActive:NO error:nil];
		[self.recorder stop];
	}
}

- (IBAction)PlayAction:(id)sender {
	NSError *error;
	self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recordFile.file error:&error];
	self.audioPlayer.delegate = self;
	self.audioPlayer.volume=1;
	if (error) {
		NSLog(@"error:%@",[error description]);
		return;
	}
	[self statusForPalying];
	[self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
	[self statusForStopRecor];
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
	[self statusForStopRecor];
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	[self statusForStopPlay];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
	[self statusForStopRecor];
}

#pragma mark - stauts
- (void)statuForRecording {
	[self.RecordButton setTitle:@"Recording" forState:UIControlStateNormal];
	[self.PlayButton setTitle:@"Play" forState:UIControlStateNormal];
    self.messageLabel.text = @"正在录音。。.点击 Recording 停止录音";
}

- (void)statusForStopRecor {
	[self.RecordButton setTitle:@"Record" forState:UIControlStateNormal];
    self.messageLabel.text = @"点击 play 开始播放录音";
}

- (void)statusForPalying {
	[self.RecordButton setEnabled:NO];
	[self.PlayButton setTitle:@"Playing" forState:UIControlStateNormal];
	[self.RecordButton setTitle:@"Record" forState:UIControlStateNormal];
    self.messageLabel.text = @"正在播放。。。";
}

- (void)statusForStopPlay {
	[self.RecordButton setEnabled:YES];
	[self.PlayButton setTitle:@"play" forState:UIControlStateNormal];
    self.messageLabel.text = @"点击 record 开始录音";
}

#pragma mark - getter
- (RecordFile *)recordFile {
	if (_recordFile == nil) {
		_recordFile = [[RecordFile alloc] init];
	}
	return _recordFile;
}

@end
