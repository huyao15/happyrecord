//
//  MidiFile.h
//  ReadStaff
//
//  Created by yan bin on 11-10-9.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseEvent : NSObject {
	int tick_;
}
@property (nonatomic, assign) int tick;

- (void)setCppEvent:(void *)event;
- (void *)getCppEvent;

@end

@interface Event : BaseEvent {
	unsigned int event_; // channel event, a note on event 0x9xnnvv00 will be saved like 0x00vvnn9x
}
@property (nonatomic, assign) unsigned int event;
//@property (nonatomic, weak) id oveNote;

@end

@interface RestEvent : BaseEvent // just for display
@property (nonatomic, assign) BOOL isOn;
//@property (nonatomic, weak) id oveNote;

@end

@interface LightEvent : Event
@end

@interface TextEvent : BaseEvent {
	NSString *text_;
}
@property (nonatomic, retain) NSString* text;
@end
@interface SpecificInfoEvent : BaseEvent {
    NSMutableData *infos_;
}
@property (nonatomic, retain) NSMutableData *infos;
@end

@interface TempoEvent : BaseEvent {
	int tempo_; // microseconds/quarter note
}
@property (nonatomic, assign) int tempo;
@end

@interface TimeSignatureEvent : BaseEvent {
	int numerator_; // such as 2, 3, 4 etc, default=4
	int denominator_; //such as 2, 4, 8 etc 3/4 as numerator_/denominator_, default=4
	int number_ticks_;
	int number_32nd_notes_;
    
}
@property (nonatomic, assign) int numerator, denominator,number_ticks,number_32nd_notes;
@end

@interface KeySignatureEvent : BaseEvent {
	int sf_; //sf_=sharps/flats (-7=7 flats, 0=key of c,7=7 sharps)
	int mi_; //mi_=major/minor (0=major, 1=minor)
}
@property (nonatomic,assign) int sf, mi;
@end

@interface SysExclusiveEvent : BaseEvent {
    
	NSMutableData* event_;
}
@property (nonatomic, retain) NSMutableData* event;
@end

@interface ChordEvent : BaseEvent {
	unsigned int root_;
	unsigned int type_;
	unsigned int bass_;
    
}
@end

@interface ITrack : NSObject {
    int number_;
    NSString *name_;//track的名字
    NSString *instrument_;//track使用的乐器名，这是存储在midi文件中的一个字符串，跟track中的乐器事件没有一一对应关系
    
    NSMutableArray *events_; //Event
    NSMutableArray *rests; //RestEvent
    NSMutableArray *lyrics_; //TextEvent
    NSMutableArray *specificEvents_; //SpecificInfoEvent
    NSMutableArray *texts_; //TextEvent
}
@property (nonatomic, assign) int number;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *instrument;
@property (nonatomic, readonly) NSMutableArray *events, *rests, *lightEvents, *lyrics, *specificEvents, *texts;
-(bool) sort_events;

@end


@interface MidiFile : NSObject {
    
@private
    NSMutableArray *tempos_; //TempoEvent list
    NSMutableArray *timeSignatures_; //TimeSignatureEvent
    NSMutableArray *keySignatures_; //KeySignatureEvent
    NSMutableArray *sysExclusives_; //SysExclusiveEvent
    NSMutableArray *markers_;  //TextEvent
    NSMutableArray *cuePoints_; //TextEvent

    NSMutableArray *tracks_;//ITrack
    
    int format_;
    int quarter_;
    NSString *name_;
    NSString *author_;
    NSString *copyright_;
}
@property (nonatomic, retain) NSMutableArray *markers, *cuePoints, *tempos, *timeSignatures, *keySignatures, *sysExclusives, *tracks;
@property (nonatomic, assign) int quarter, format;
@property (nonatomic, retain) NSString *author, *name, *copyright;
@end
