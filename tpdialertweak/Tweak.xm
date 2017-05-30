/* How to Hook with Logos
Hooks are written with syntax similar to that of an Objective-C @implementation.
You don't need to #include <substrate.h>, it will be done automatically, as will
the generation of a class list and an automatic constructor.

*/
#import <TPDialerAdvanced/AdvancedCalllog.h>
#import <TPDialerAdvanced/TPDialerAdvanced.h>
#import <channelcode.h>

#import <SpringBoard/SBUIFullscreenAlertAdapter.h>
#import <SpringBoard/MPIncomingPhoneCallController.h>
#import <SpringBoard/XXUnknownSuperclass.h>
#import <MobilePhone/InCallLCDView.h>
#import <MobilePhone/PhoneApplication.h>
#import <SpringBoard/SBCallAlertDisplay.h>
#import <SpringBoard/SpringBoard.h>
#import <MobilePhone/PhoneCall.h>
#import <SpringBoard/SBApplicationIcon.h>

#import <dlfcn.h>

#define tweak_log(...) NSLog(__VA_ARGS__)

const int calllog_required_mininum_version = 4300;
const int callerid_required_mininum_version = 4580;
const int tweak_version = 4580;

#define SBSERVPATH "/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices"
#define UIKITPATH "/System/Library/Framework/UIKit.framework/UIKit"

%hook AdvancedCalllog
+(BOOL)synCalllog{
        if (![self isAccessCallDB]) {
           return NO;
        }

        tweak_log(@"sync calllog in tweak");
 	if([self checkVersion:calllog_required_mininum_version]) {
 	     [self setChannelCode:CHANNEL_CODE];
   		 return  [TPDialerAdvanced copySystemCalllogToTPDialer:[self getTPDialerDBPath]];
	}else{
   	 	return %orig;
    }
}

+(BOOL)isAccessCallHistoryDB{
        tweak_log(@"check is access in tweak");
	if([self checkVersion:calllog_required_mininum_version]) {
		return [TPDialerAdvanced isAccessCallHistoryDB];
	}else{
		return %orig;
	}
}

+(int) getAdvancedTweakVersion {
    // No need to check the 
    return tweak_version;
}

%end

%hook SBUIFullscreenAlertAdapter
// This is in the ios 5 springboard process, when call comes in. 
- (id)initWithAlertController:(id)arg1{
     id result = %orig;    
     
     if([TPDialerAdvanced checkVersion:callerid_required_mininum_version]) {
         MPIncomingPhoneCallController *phoneCall = (MPIncomingPhoneCallController*)arg1;
        if([phoneCall respondsToSelector:@selector(updateLCDWithName: label: breakPoint:)]){
         
               NSString* text = phoneCall.callerName;
               NSString* label = phoneCall.incomingCallerLabel;
               NSString* number = phoneCall.incomingCallNumber;
               [TPDialerAdvanced updateFullView:phoneCall withText:text label:label number:number];
          }
     } else {
        tweak_log(@"the app version does not support callerid hook");
     }
     return result;
}
%end

%hook SBCallAlertDisplay
// This is in the ios 4 springboard process, when call comes in
- (id)updateLCDWithName:(id)name label:(id)label breakPoint:(unsigned)point {
   id result = %orig;
    if([TPDialerAdvanced checkVersion:callerid_required_mininum_version]) {
         tweak_log(@"updateOldFullView with text: %@ label: %@", name, label);
         [TPDialerAdvanced updateOldFullView:self withText:name label:label breakPoint:point];
     } else {
         tweak_log(@"the app version does not support callerid hook");
    }
    
    return result;
}

%end

%hook InCallLCDView
// This is in the MobilePhone process, when in call status
-(void)setText:(id)text {
    %orig;
    if([TPDialerAdvanced checkVersion:callerid_required_mininum_version]) {
        tweak_log(@"updateLCDView with text: %@ ", text);
        [TPDialerAdvanced updateLCDView:self withText:text label:nil];
    } else {
        tweak_log(@"the app version does not support callerid hook");
     }
}

%end

%hook PhoneCall 
// This is in the MobilePhone process. When the process creating InCallLCDController, it will first create a PhoneCall object,
// that contains phone number information. We can use this to get the phone number of known users
-(id)initWithCall:(CTCallRef)call {
    tweak_log(@"phone call");
    id result = %orig;
    if([TPDialerAdvanced checkVersion:callerid_required_mininum_version]) {
        tweak_log(@"initWithCall is hooked");
        [TPDialerAdvanced setCurrentCall:result];
    } else {
        tweak_log(@"the app version does not support callerid hook");
     }
    return result;
}

%end

// %hook PhoneApplication
// 
// -(void)applicationDidFinishLaunching:(id)application {
//     %orig;
//     
//     [TPDialerAdvanced attachCrashHandler];
// }
// 
// %end

%hook SBApplicationIcon

-(void) setBadge:(id)badge {
    %orig;
    if([[self applicationBundleID] isEqualToString:@"com.apple.mobilephone"]) {
        int newValue = [self badgeValue];
        if (newValue == 0) {
            return;
        }
        // Fetch the SpringBoard server port
        mach_port_t *p;
        void *uikit = dlopen(UIKITPATH, RTLD_LAZY);
        int (*SBSSpringBoardServerPort)() = (int (*)()) dlsym(uikit, "SBSSpringBoardServerPort");
        p = (mach_port_t*) SBSSpringBoardServerPort(); 
        dlclose(uikit);

        // Link to SBSetApplicationBadgeNumber
        void *sbserv = dlopen(SBSERVPATH, RTLD_LAZY);
        BOOL (*setBadgeNumber)(mach_port_t* port, const char* applicationID, int number) = (BOOL (*)(mach_port_t*, const char*, int)) dlsym(sbserv, "SBSetApplicationBadgeNumber");
        setBadgeNumber(p, "com.cootek.Contacts", newValue);
        dlclose(sbserv);
    }

}

%end

