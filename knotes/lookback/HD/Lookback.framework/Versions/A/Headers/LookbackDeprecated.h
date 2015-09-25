#import <Foundation/Foundation.h>

#ifndef LOOKBACK_INTERNAL
#define LOOKBACK_DEPRECATED_ATTRIBUTE DEPRECATED_ATTRIBUTE
#else
#define LOOKBACK_DEPRECATED_ATTRIBUTE
#endif

/*!
	@header Lookback Deprecated API
	The use of these interfaces is discourages and will be removed in a future
	version of Lookback.
*/

#pragma mark Compatibility macros
/*!
	@group Compatibility macros
	For compatibility with old code using Lookback under the miscapitalized or
	misprefixed names.
 */
#define LookBack Lookback
#define GFAutomaticallyLogViewAppearance LookbackAutomaticallyLogViewAppearance
#define GFCameraEnabledSettingsKey LookbackCameraEnabledSettingsKey
#define GFAudioEnabledSettingsKey LookbackAudioEnabledSettingsKey
#define GFShowPreviewSettingsKey LookbackShowPreviewSettingsKey
#define GFStartedUploadingNotificationName LookbackStartedUploadingNotificationName
#define GFExperienceDestinationURLUserInfoKey LookbackExperienceDestinationURLUserInfoKey
#define GFExperienceStartedAtUserInfoKey LookbackExperienceStartedAtUserInfoKey

#pragma mark Deprecated settings

/*! @see -[Lookback automaticallyRecordViewControllerNames]*/
LOOKBACK_DEPRECATED_ATTRIBUTE static NSString *const LookbackAutomaticallyLogViewAppearance = @"GFio.lookback.autologViews";

/*! @see -[Lookback franerateLimit]*/
LOOKBACK_DEPRECATED_ATTRIBUTE static NSString *const LookbackScreenRecorderFramerateLimitKey = @"com.thirdcog.lookback.screenrecorder.fpsLimit";

/*! @see LookbackAfterRecordingOptionSettingsKey */
DEPRECATED_ATTRIBUTE static NSString *const LookbackRecordingAfterTimeoutOptionSettingsKey = @"io.lookback.recording.afterTimeoutOption";


/*! @see LookbackAfterRecordingOption */
DEPRECATED_ATTRIBUTE typedef NS_ENUM(NSInteger, LookbackAfterTimeoutOption) {
	LookbackAfterTimeoutReview = 0,
	LookbackAfterTimeoutUpload,
};


@interface Lookback (LookbackDeprecated)
/*!
	This property has been renamed to 'recording'.
	@see setRecording:
*/
@property(nonatomic) DEPRECATED_ATTRIBUTE BOOL enabled;
@end