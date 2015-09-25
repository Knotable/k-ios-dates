#import <Foundation/Foundation.h>
#import <Lookback/LookbackSettingsViewController.h>
#import <Lookback/LookbackRecordingViewController.h>

/*! @header Lookback Public API
    Public interface for Lookback, the UX testing tool that records your screen
    and camera and uploads it to http://lookback.io for further study.
*/

/*! @class Lookback

    Lookback should be +[Lookback @link setupWithAppToken: @/link] before being used. After
    that, you can set its [Lookback @link enabled @/link] property to start and stop recording
    at any time. You can use @link LookbackSettingsViewController @/link to provide a user
    interface to do so.
    
    Rather than doing so manually, you can set -[Lookback @link shakeToRecord @/link] to
    display this UI whenever you shake your device.
*/
@interface Lookback : NSObject

/*! In your applicationDidFinishLaunching: or similar, call this method to prepare
    Lookback for use, using the App Token from your integration guide at lookback.io.
    @param appToken A string identifying your app, received from your app settings at http://lookback.io
*/
+ (void)setupWithAppToken:(NSString*)appToken;

/*! Shared instance of Lookback to use from your code. You must call
    +[Lookback @link setupWithAppToken:@/link] before calling this method.
 */
+ (Lookback*)sharedLookback;

/*! Deprecated: use @link sharedLookback @/link instead. This is because Swift
	disallows the use of a static method with the same name as the class that isn't
	a constructor.
 */
+ (Lookback*)lookback;
@end


@interface Lookback (LookbackRecording)
/*! Whether Lookback is set to currently record. You can either start recording programmatically,
	use @link shakeToRecord @/link to give your users a simple default UI to start recording, or present
    @link LookbackRecordingViewController @/link on your own to let users record from there.
 */
@property(nonatomic,getter=isRecording) BOOL recording;

/*! Is Lookback paused? Lookback will pause automatically when showing the Recorder.
    This property doesn't do anything if Lookback is not recording (as there is nothing
	to pause).
 */
@property(nonatomic,getter=isPaused) BOOL paused;

/*! Lookback automatically sets a screen recording framerate that is suitable for your
	device. However, if your app is very performance intense, you might want to decrease
	the framerate at which Lookback records to free up some CPU time for your app. This
	multiplier lets you adapt the framerate that Lookback chooses for you to something
	more suitable for your app.
	
	Default value: 1.0
	Range: 0.1 to 1.0
	
	@see framerateLimit
*/
@property(nonatomic) float framerateMultiplier;

/*! Set a specific upper limit on screen recording framerate. Note that Lookback adapts framerate to something suitable for the current device: setting the framerate
	manually will override this. Set it to 0 to let Lookback manage the framerate limit.
	
	Decreasing the framerate is the best way to fix performance problems with Lookback. However, instead of hard-coding
	a specific framerate, consider setting -[Lookback framerateMultiplier] instead, as this will let Lookback adapt the
	framerate to something suitable for your device.
	
	Default value: Depends on hardware
	Range: 1 to 60
	@see framerateMultiplier
*/
@property(nonatomic) int framerateLimit;
@end


@interface Lookback (LookbackUI)

/*! If enabled, shows the feedback bubble when you shake the device. Tapping this bubble will
	show the LookbackRecordingViewController and let the user record. Default NO.
*/
@property(nonatomic) BOOL shakeToRecord;

/*! Whether the feedback bubble (from "shakeToRecord") is currently shown. Defaults to NO,
	but you can set it to YES immediately on app start to default to it showing, e g.
*/
@property(nonatomic) BOOL feedbackBubbleVisible;

/*!
	The feedback bubble will pick up your navigation bar's appearance proxy's bar
	tint and foreground tint color. If you wish to override, you can do so with
	`feedbackBubbleForegroundColor` and `feedbackBubbleBackgroundColor`.
*/
@property(nonatomic) UIColor *feedbackBubbleForegroundColor;
@property(nonatomic) UIColor *feedbackBubbleBackgroundColor;
@property(nonatomic) UIImage *feedbackBubbleIcon;

/*!
	Whether the built-in LookbackRecordingViewController is currently being shown,
	either from pressing the feedback bubble or from setting this property to YES.
*/
@property(nonatomic) BOOL recorderVisible;
/*! The currently presented LookbackRecordingViewController. nil if recorderVisible is NO. */
@property(nonatomic,readonly) LookbackRecordingViewController *presentedRecorder;
@end


@interface Lookback (LookbackMetadata)
/*! Identifier for the user who's currently using the app. You can filter on
    this property at lookback.io later. If your service has log in user names,
    you can use that here. Optional.
    @seealso http://lookback.io/docs/log-username
*/
@property(nonatomic,copy) NSString *userIdentifier;

/*! Default YES. With this setting, all the view controllers you visit during a
	recording will be recorded, and their names displayed on the timeline. Disable
	this to not record view names, or to manually track view names using enteredView:
	and exitedView:.
	
	If you wish to customize the name that your view controller is logged as,
	you can implement +(NSString*)lookbackIdentifier in your view controller.
	*/
@property(nonatomic) BOOL automaticallyRecordViewControllerNames;

/*! If you are not using view controllers, or if automaticallyRecordViewControllerNames is NO,
	and you still want to track the user's location in your app, call this method whenever
	the user enters a new distinct view within your app.
    @param viewIdentifier Unique human readable identifier for a specific view
*/
- (void)enteredView:(NSString*)viewIdentifier;

/*! Like enteredView:, but for when the user exists the view.
    @see enteredView:
    @param viewIdentifier Unique human readable identifier for a specific view
*/
- (void)exitedView:(NSString*)viewIdentifier;

/*!	You might want to track events beyond user navigation; such as errors,
    user interaction milestones, network events, etc. Call this method whenever
	such an event is happening, and if a recording is taking place, the event
	will be attached to the timeline of that recording.
	
	@example <pre>
		[[Lookback_Weak lookback]
			logEvent:@"Playback Error"
			eventInfo:[NSString stringWithFormat:@"%d: %@",
				error.errorCode, error.localizedDescription]
		];
	
	@param event     The name of the event: this is the string that will show up
					 on the timeline.
	@param eventInfo Additional information about the event, for example error
	                 code, interaction variation, etc.
*/
- (void)logEvent:(NSString*)event eventInfo:(NSString*)eventInfo;
@end


@interface Lookback (Debugging)
@property(nonatomic,readonly) NSString *appToken;
@end


/*! If you only want to use Lookback in builds sent to testers (e g by using the
    CocoaPods :configurations=> feature), you need to avoid both linking with
    Lookback.framework and calling any Lookback code (since that would create
    a linker error). By making all your calls to Lookback_Weak instead of
    Lookback, your calls will be disabled when not linking with Lookback, and
    you thus avoid linker errors.
 
    @example <pre>
        [Lookback_Weak setupWithAppToken:@"<MYAPPTOKEN>"];
        [Lookback_Weak sharedLookback].shakeToRecord = YES;
        
        [[Lookback_Weak sharedLookback] enteredView:@"Settings"];
        </pre>
*/
#define Lookback_Weak (NSClassFromString(@"Lookback"))


#pragma mark UIKit extensions

/*!
 *  Lookback-specific extenions to UIView.
 */
@interface UIView (LookbackConcealing)

/*! @discussion If set to YES, the receiver will be covered by a red rectangle in recordings
	you make with Lookback. This is useful for hiding sensitive user
    data. Secure text fields are automatically concealed when focused.
	
	@example <pre>
		- (void)viewDidLoad {
			if([Lookback_Weak lookback]) { // don't set lookback properties if lookback isn't available
				self.userEmailLabel.lookback_shouldBeConcealedInRecordings = YES;
			}
			...
		}
		</pre>
 */
@property(nonatomic) BOOL lookback_shouldBeConcealedInRecordings;

@end

/*! Implement either of these to customize the view name that is logged whenever
	the user enters your view controller during a recording. */
@interface UIViewController (LookbackViewIdentifier)
+ (NSString*)lookbackIdentifier;
- (NSString*)lookbackIdentifier;
@end


#pragma mark Settings

/*! @group Settings
    These settings can be set using [NSUserDefaults standardUserDefaults] to modify
    the behavior of Lookback. Some of these settings can be modified by the user
    from LookbackSettingsViewController.
*/


/*! LookbackCameraEnabledSettingsKey controls whether the front-facing camera will record, in addition to recording the screen. */
static NSString *const LookbackCameraEnabledSettingsKey = @"com.thirdcog.lookback.camera.enabled";

/*! The BOOL NSUserDefaults key LookbackAudioEnabledSettingsKey controls whether audio will be recorded.*/
static NSString *const LookbackAudioEnabledSettingsKey = @"com.thirdcog.lookback.audio.enabled";

/*! The BOOL NSUserDefaults key LookbackShowPreviewSettingsKey controls whether the user should be shown a preview image of their face at the bottom-right of the screen while recording, to make sure that they are holding their device correctly and are well-framed. */
static NSString *const LookbackShowPreviewSettingsKey = @"com.thirdcog.lookback.preview.enabled";

/*! Standard timeout options for LookbackRecordingTimeoutSettingsKey. */
typedef NS_ENUM(NSInteger, LookbackTimeoutOption) {
	LookbackTimeoutImmediately = 0,
	LookbackTimeoutAfter1Minutes = 60,
	LookbackTimeoutAfter3Minutes = 180,
	LookbackTimeoutAfter5Minutes = 300,
	LookbackTimeoutAfter15Minutes = 900,
	LookbackTimeoutAfter30Minutes = 1800,
	LookbackTimeoutNever = NSIntegerMax,
};

/*! The NSTimeInterval/double key LookbackRecordingTimeoutOptionSettingsKey controls the timeout option when
	the app becomes inactive. "Inactive" in this context means that the user exists the app, or locks the screen.
	
	* Using 0 will stop a recording as soon as the app becomes inactive.
	* Using DBL_MAX will never terminate a recording when the app becomes inactive.
	* Any value in between will timeout and end the recording after the app has been inactive for
	  the specified duration.
 */
static NSString *const LookbackRecordingTimeoutSettingsKey = @"io.lookback.recording.timeoutDuration";

typedef NS_ENUM(NSInteger, LookbackAfterRecordingOption) {
	LookbackAfterRecordingReview = 0,
	LookbackAfterRecordingUpload,
	LookbackAfterTimeoutUploadAndStartNewRecording,
};

/*! The LookbackAfterRecordingOption key LookbackAfterRecordingOptionSettingsKey controls the behavior of
	Lookback when the user stops recording, or recording times out (see LookbackRecordingTimeoutSettingsKey).
	* LookbackAfterRecordingReview will let the user manually review a recording after it's been stopped.
	* LookbackAfterRecordingUpload will automatically upload without review.
	* LookbackAfterTimeoutUploadAndStartNewRecording will automatically start uploading, but if it was stopped
	  because of a timeout, it will also start a new recording the next time the app is brought to the foreground.
 */
static NSString *const LookbackAfterRecordingOptionSettingsKey = @"io.lookback.recording.afterTimeoutOption";

#pragma mark Notifications
/*! @group Notifications
    These notifications can be observed from [NSNotificationCenter defaultCenter].
*/

/*! When a recording upload starts, its URL is determined. You can then attach this URL to a bug report or similar.

    @example <pre>
        // Automatically put a recording's URL on the user's pasteboard when recording ends and upload starts.
        [[NSNotificationCenter defaultCenter] addObserverForName:LookbackStartedUploadingNotificationName object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            NSDate *when = [note userInfo][LookbackExperienceStartedAtUserInfoKey];
            if(fabs([when timeIntervalSinceNow]) < 60) { // Only if it's for an experience we just recorded
                NSURL *url = [note userInfo][LookbackExperienceDestinationURLUserInfoKey];
                [UIPasteboard generalPasteboard].URL = url;
            }
        }];</pre>
*/
static NSString *const LookbackStartedUploadingNotificationName = @"com.thirdcog.lookback.notification.startedUploading";

/*! UserInfo key in a @link LookbackStartedUploadingNotificationName @/link notification. The value is an NSURL that the user can visit
    on a computer to view the experience he/she just recorded. */
static NSString *const LookbackExperienceDestinationURLUserInfoKey = @"com.thirdcog.lookback.notification.startedUploading.destinationURL";

/*! UserInfo key in a @link LookbackStartedUploadingNotificationName @/link notification. The value is an NSDate of when the given experience
    was recorded (so you can correlate the upload with the recording). */
static NSString *const LookbackExperienceStartedAtUserInfoKey = @"com.thirdcog.lookback.notification.startedUploading.sessionStartedAt";

#import <Lookback/LookbackDeprecated.h>
