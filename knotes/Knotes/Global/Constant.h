#ifndef Knotable_Constant_h
#define Knotable_Constant_h

#define Documents_Folder						[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define Tmp_Folder								[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"]
#define Files_Folder							[Documents_Folder stringByAppendingPathComponent:@"files"]
#define Thumbs_Folder							[Documents_Folder stringByAppendingPathComponent:@"thumbs"]

#define UIViewAutoresizingFlexibleMargins                 \
UIViewAutoresizingFlexibleBottomMargin    | \
UIViewAutoresizingFlexibleLeftMargin      | \
UIViewAutoresizingFlexibleRightMargin     | \
UIViewAutoresizingFlexibleTopMargin

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define NLSystemVersionGreaterOrEqualThan(version) ([[[UIDevice currentDevice] systemVersion] floatValue] >= version)
#define IOS8_OR_LATER NLSystemVersionGreaterOrEqualThan(8.0)

// Third Party Service Key Information

// Lookback.io video feedback

#define LOOKBACK_KNOTABLE_TOKEN     @"qRifFQF7QkfxnYsNw"

// Embedly Image Loading Key

#define EMBEDLY_KNOTABLE_TOKEN      @"daa2ece3ae3443b9ae786534f1b0d468"

// Crashlytics API Key

#define CRASHLYTICS_KNOTABLE_APIKEY @"78bf5c82937758a95198b2e87f393e217600f36a 7885aa19d2814b9ac505580b2e7b46007c9b145f98d077c037772ffcee861c22"


#define kFirstUserKey               @"firstuser"
#define kFirstUserValue             @"NO"
#define kUserTopicCount             @"userTopicCount"
#define kUserArchivedTopicCount     @"userArchivedTopicCount"

#define BottomMenuHeight            49

// Malik Added for Caching handling

#define GET_CACHE_KEY_FOR_FULLURL(_Account_ID_) [NSString stringWithFormat:@"%@/FULL_URL",_Account_ID_]
#define GET_CACHE_KEY_FOR_MINIURL(_Account_ID_) [NSString stringWithFormat:@"%@/MINI_URL",_Account_ID_]

// Lin - Added for global static strings.

#define REMOVE_COMMENT_LABEL_EXTRA_VERTICALSPACE 10

#define RECENT_TITLE        @"Recent"
#define PEOPLE_TITLE        @"People"
#define PADS_TITLE          @"Pads"
#define PROFILE_TITLE       @"Profile"
#define ARCHIVE_TITLE       @"Pads: Done"

#define LOGIN_PROCESS_VC        1000

#define KnotebleShowPopUpMessage            @"KnotebleShowPopUpMessage"
#define kNeedChangeMongoDbServer            @"kNeedChangeMongoDbServer"
#define kNeedGoBackToLoginView              @"kNeedGoBackToLoginView"

#define kNeedChangeApplicationHost          @"kNeedChangeApplicationHost"

#define kPermissionSetState                 @"kPermissionSetState"

#define IMAGE_DOWNLOADED_NOTIFICATION       @"IMAGE_DOWNLOADED_NOTIFICATION"
#define FILE_DOWNLOADED_NOTIFICATION        @"FILE_DOWNLOADED_NOTIFICATION"

#define HIDE_NOTIFYVIEW_NOTIFICATION            @"HIDE_NOTIFYVIEW_NOTIFICATION"
#define HIDE_COMMENTINPUTVIEW_NOTIFICATION      @"HIDE_COMMENTINPUTVIEW_NOTIFICATION"

#define TopicCellIdentifier                 @"TopicCell"
#define ContactCellIdentifier               @"ContactCell"
#define PadOwnerCellIdentifier              @"PadOwnerCell"

#define kNotificationLikes                  @"kNotificationLikes"

#define MenubarDisableNotification          @"MenubarDisable"
#define MenubarEnableNotification           @"MenubarEnable"

#define Pad_BookMarked_Notification @"Pad_BookMarked_Notification"

// Previously on combinedviewcontroller

#define MUTE_BACKGROUND [UIColor colorWithWhite:0.6 alpha:0.1]

#define IMAGE_SIZE                      43.0
#define USERNAME_FONT_NAME              @"Helvetica Neue Medium"
#define USERNAME_FONT_SIZE              16.0
#define SPINER_IMAGE_SIZE               40

#define RECENT_BUTTON_INDEX             0
#define PEOPLE_BUTTON_INDEX             1
#define PADS_BUTTON_INDEX               2
#define SETTING_BUTTON_INDEX            3

#define ARCHIVE_MENU_INDEX              0
#define REORDER_MENU_INDEX              1

#define NPMV_TEXT_TAG                   100
#define NPMV_DEADLINE_TAG               101
#define NPMV_CHECKLIST_TAG              102
#define NPMV_VOTE_TAG                   103

#define MAXLABELWIDTH                   300
#define ONELINEHEIGHT                   20.281
#define BASESIZE                        60

//#define     SplitMode                   NO

#define     GestureDisableTest          YES
#define     RecentMuteISDelete          NO

#define     DEBUGKNOTECELL              YES
#define     IMAGELIMITATION             YES

#define     ENTERPRIZEPOSTIMAGEHEIGHT   180.0f
#define     ENTERPRIZEPOSTOFFSET        45.0f
#define     LoadingObserverTime         20.0f

// MongoDB Parts

#define METEORCOLLECTION_USERS           @"users"                // Existing
#define METEORCOLLECTION_PEOPLE          @"contacts"             // Existing
#define METEORCOLLECTION_KEY             @"key_notes"            // Not Existing
#define METEORCOLLECTION_KNOTES          @"knotes"               // Existing
#define METEORCOLLECTION_MESSAGES        @"messages"             // Existing
#define METEORCOLLECTION_ACCOUNTS        @"user_accounts"        // Existing
#define METEORCOLLECTION_TOPICS          @"topics"               // Existing
#define METEORCOLLECTION_FILES           @"files"                // Existing
#define METEORCOLLECTION_NOTIFICATIONS   @"notifications"        // Existing
#define METEORCOLLECTION_ACTIVITES       @"activities"           // Existing
#define METEORCOLLECTION_HOTKNOTES       @"hotKnotes"
#define METEORCOLLECTION_USERPRIVATEDATA @"userPrivateData"
#define METEORCOLLECTION_MUTEKNOTES      @"muteKnotes"
#define METEORCOLLECTION_ARCHIVEDTOPICS  @"archivedTopics"       // Existing

#define METEORCOLLECTION_KNOTE_TOPIC            @"topic"
#define METEORCOLLECTION_KNOTE_PINNED           @"pinnedKnotesForTopic"
#define METEORCOLLECTION_KNOTE_ARCHIVED         @"archivedKnotesForTopic"
#define METEORCOLLECTION_KNOTE_REST             @"allRestKnotesByTopicId"

#define AFNetworking_2_And_Above_Installed 1

typedef enum
{
    NetworkErr = -2,
    NetworkTimeOut  = -1,
    NetworkSucc,
    NetworkFailure,
} WM_NetworkStatus;

typedef void (^MongoCompletion)(WM_NetworkStatus success, NSError *error, id userData);
typedef void (^MongoCompletion2)(WM_NetworkStatus success, NSError *error, id userData, id userData2);
typedef void (^MongoCompletion3)(WM_NetworkStatus success, NSError *error, id userData, id userData2, id userData3);

#define     UseStaticGoogleClient       NO

typedef enum _DisplayMode
{
    DisplayModePeople,
    DisplayModePads,
    DisplayModeSettings
} DisplayMode;

// Constants from MongoDB's Header

#define S3_FILENAME_FORMAT @"uploads/%@"
#define MUTE_KNOTE_FETCH_LIMIT 10000

#define HOT_KNOTE_FETCH_LIMIT 5
#define HOT_KNOTE_DISPLAY_LIMIT 5

#endif
