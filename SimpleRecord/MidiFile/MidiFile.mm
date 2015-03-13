//
//  MidiFile.m
//  ReadStaff
//
//  Created by yan bin on 11-10-9.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//



#import "MidiFile.h"

@implementation BaseEvent {
    void *_cppEvent;
}

@synthesize tick=tick_;

- (instancetype)init {
    if (self = [super init]) {
        _cppEvent = NULL;
    }
    return self;
}

- (void)setCppEvent:(void *)event {
    _cppEvent = event;
}

- (void *)getCppEvent {
    return _cppEvent;
}

@end

@implementation Event
@synthesize event=event_;
@end

@implementation RestEvent
@synthesize isOn;
@end

@implementation LightEvent
@end

@implementation TimeSignatureEvent
@synthesize numerator=numerator_,number_ticks=number_ticks_,number_32nd_notes=number_32nd_notes_,denominator=denominator_;
@end

@implementation TextEvent
@synthesize text=text_;
@end

@implementation TempoEvent
@synthesize tempo=tempo_;
@end

@implementation KeySignatureEvent
@synthesize mi=mi_;
@synthesize sf=sf_;
@end

@implementation SpecificInfoEvent
@synthesize infos=infos_;
@end

@implementation ChordEvent
@end

//系统高级消息
@implementation SysExclusiveEvent
@synthesize event=event_;
@end

@implementation ITrack
@synthesize number=number_;
@synthesize name=name_;
@synthesize instrument=instrument_;
@synthesize events=events_, rests;
@synthesize lyrics=lyrics_;
@synthesize specificEvents=specificEvents_;
@synthesize texts=texts_;
- (id) init
{
    self=[super init];
    if (self) {
        events_=[[NSMutableArray alloc]init];
        rests = [NSMutableArray array];
        _lightEvents=[[NSMutableArray alloc]init];
        texts_=[[NSMutableArray alloc]init];
        lyrics_=[[NSMutableArray alloc]init];
        specificEvents_=[[NSMutableArray alloc]init];
    }
    return self;
}

- (void) clear
{
    number_ = 0;
    self.name = nil;
    self.instrument = nil;
}

NSInteger compair_event(Event* e1, Event* e2, void* data)
{
    if (e1.tick == e2.tick) {
        if ((e1.event & 0xF0) == 0xC0 && (e2.event & 0xF0) == 0x90) //instrument
            return true;
        
        if ((e1.event & 0xF0) == 0xB0 && (e2.event & 0xF0) == 0x90) //control event
            return true;
    }
    
    return e1.tick - e2.tick;
}

-(bool) sort_events
{
    [events_ sortUsingFunction:compair_event context:nil];
    return true;
}


@end

@implementation MidiFile
@synthesize tempos=tempos_,timeSignatures=timeSignatures_;
@synthesize markers=markers_, cuePoints=cuePoints_, keySignatures=keySignatures_, sysExclusives=sysExclusives_;
@synthesize quarter=quarter_, format=format_;
@synthesize author=author_, name=name_, copyright=copyright_;
@synthesize tracks=tracks_;

- (id) init
{
    self = [super init];
    if (self) {
        tracks_ = [[NSMutableArray alloc]init];
        tempos_ = [[NSMutableArray alloc]init];
        timeSignatures_ = [[NSMutableArray alloc]init];
        keySignatures_ = [[NSMutableArray alloc]init];
        sysExclusives_ = [[NSMutableArray alloc]init];
    }
    return self;
}

-(BOOL) addTrack:(int) idx
{
    return NO;
}

- (NSMutableArray*) getTracks
{
    return tracks_;
}
    
-(ITrack*)getTrack:(int) idx
{
    return [tracks_ objectAtIndex:idx];
}
-(void)clear
{
    format_ = 1;
    quarter_ = 480;
    
    [tempos_ removeAllObjects];
    [timeSignatures_ removeAllObjects];
    [keySignatures_ removeAllObjects];
    [sysExclusives_ removeAllObjects];
    
    [markers_ removeAllObjects];
    [cuePoints_ removeAllObjects];

    [tracks_ removeAllObjects];
}

@end
