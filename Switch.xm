#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <Flipswitch/FSSwitchDataSource.h>
#import <Flipswitch/FSSwitchPanel.h>

CFStringRef const kChangeVolWithBtnKey = CFSTR("buttons-can-change-ringer-volume");
CFStringRef const kPrefsSound = CFSTR("com.apple.preferences.sounds");
CFStringRef const kPrefsSoundNotification = CFSTR("com.apple.preferences.sounds.buttons-can-change-ringer-volume.changed");
NSString *const kSwitchIdentifier = @"com.PS.ChangeVolWithBtn";

extern "C" NSString *AVController_ClientNameAttribute;
extern "C" NSString *AVController_WantsVolumeChangesWhenPausedOrInactive;

extern "C" id MGCopyAnswer(CFStringRef);
extern "C" bool MGGetBoolAnswer(CFStringRef);

@interface AVController : NSObject
- (bool)setAttribute:(id)attribute forKey:(id)key error:(NSError *)error;
@end

@interface ChangeVolWithButtonSwitch : NSObject <FSSwitchDataSource> {
	AVController *avController;
}
@end

int deviceType = 0;

static void PreferencesChanged() {
	[[FSSwitchPanel sharedPanel] stateDidChangeForSwitchIdentifier:kSwitchIdentifier];
}

@implementation ChangeVolWithButtonSwitch

- (id)init {
	if (self == [super init]) {
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)PreferencesChanged, kPrefsSoundNotification, NULL, CFNotificationSuspensionBehaviorCoalesce);
		self->avController = [[%c(AVController) alloc] init];
		[self->avController setAttribute:@"Preferences" forKey:AVController_ClientNameAttribute error:nil];
		[self->avController setAttribute:@(NO) forKey:AVController_WantsVolumeChangesWhenPausedOrInactive error:nil];
	}
	return self;
}

- (int)deviceType {
	if (deviceType == 0) {
		NSString *deviceName = [[[MGCopyAnswer(CFSTR("DeviceName")) lowercaseString] retain] autorelease];
		if ([deviceName isEqualToString:@"iphone"])
			deviceType = 1;
		else {
			if (MGGetBoolAnswer(CFSTR("any-telephony")))
				deviceType = 2;
			else
				deviceType = 3;
		}
	}
	return deviceType;
}

- (void)dealloc {
	[self->avController release];
	self->avController = nil;
	CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), self, kPrefsSoundNotification, NULL);
	[super dealloc];
}

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
	Boolean keyExist;
	Boolean enabled = CFPreferencesGetAppBooleanValue(kChangeVolWithBtnKey, kPrefsSound, &keyExist);
	if (!keyExist)
		return FSSwitchStateOn;
	BOOL value = NO;
	if ([self deviceType] == 1) // Not sure, will check again
		value = enabled;
	[self->avController setAttribute:@(value) forKey:AVController_WantsVolumeChangesWhenPausedOrInactive error:nil];
	return enabled ? FSSwitchStateOn : FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier {
	if (newState == FSSwitchStateIndeterminate)
		return;
	CFBooleanRef enabled = newState == FSSwitchStateOn ? kCFBooleanTrue : kCFBooleanFalse;
	CFPreferencesSetValue(kChangeVolWithBtnKey, enabled, kPrefsSound, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	CFPreferencesSynchronize(kPrefsSound, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), kPrefsSoundNotification, nil, nil, YES);
	[self->avController setAttribute:@(newState == FSSwitchStateOn) forKey:AVController_WantsVolumeChangesWhenPausedOrInactive error:nil];
}

@end