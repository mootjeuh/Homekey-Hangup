#import <Foundation/NSFileManager.h>
#import <AVFoundation/AVAudioSession.h>

@interface CTCall : NSObject
@end

@interface TUCall : NSObject

- (int)status;
- (void)disconnect;

@end

@interface TUTelephonyCall : TUCall

- (int)status;
- (void)disconnect;

@end

static NSString *speakerModePath = @"/var/mobile/Documents/speakerMode.txt";
static TUTelephonyCall *TUInstance = nil;
static BOOL inCall = NO;

static BOOL isHeadsetPluggedIn()
{
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for(AVAudioSessionPortDescription* desc in [route outputs]) {
        if([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    return NO;
}

%hook TUTelephonyCall

- (CTCall*)call
{
	TUInstance = self;
	return %orig;
}

- (void)dealloc
{
	[[NSFileManager defaultManager] removeItemAtPath:speakerModePath error:nil];
	inCall = NO;
	%orig;
}

- (id)initWithCall:(CTCall*)arg1
{
	[[NSFileManager defaultManager] createFileAtPath:speakerModePath contents:nil attributes:nil];
	inCall = YES;
	return %orig;
}

%end

%hook SpringBoard

- (void)_menuButtonUp:(id)arg1
{
	if(inCall) {
		NSString *mode = [NSString stringWithContentsOfFile:speakerModePath encoding:NSASCIIStringEncoding error:NULL];
		if(![mode isEqualToString:@"1"]) {
			if(!isHeadsetPluggedIn()) {
				if(TUInstance) {
					if([TUInstance status]) {
						[TUInstance disconnect];
					}
				}
			}
		}
	}
	%orig;
}

%end

%hook InCallController

- (void)_setSpeakerButtonSelected:(BOOL)arg1
{
	NSString *result = [NSString stringWithFormat:@"%hhd", (char)arg1];
	[result writeToFile:speakerModePath atomically:YES encoding:NSASCIIStringEncoding error:NULL];
	%orig;
}

%end