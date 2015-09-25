//
//  ThreadConst.h
//  Knotable
//
//  Created by backup on 13-12-26.
//
//


#if NEW_DESIGN
#else
#define kDefalutTitleBarH 32.0
#endif
#define kDefalutInfoBarH 0.0
#define kDefalutBtnBarH 0.0
#if NEW_DESIGN
#define kDefalutTitleIconH (32.0)
#else
#define kDefalutTitleIconH (32.0+6)
#endif
#define kDefaultUserPictureSizeInRecent (72.0)
#define kDefalutHeaderAvatorIconH 32.0

#define kDefalutLikeIconH 20.0
#define kDefalutPaityIconH 20.0

#define kDefaultCtlWidth 298.0
#define kDefaultWidgetW 188.0
#define kDefaultWidgetH 88.0
#define kWidgetTitleH 22.0
#define kItemMinH 60.0
#define kDefaultMoreBtnH 48.0f

#define kDefaultFontSize 16
#define kDefaultLineHeight 20.0f

#define kGridViewH 62.0

#define kDefaultSegmentIconHeight 26
#define kNavagationBarColor [UIColor colorWithRed:39/255.0 green:60/255.0 blue:61/255.0 alpha:1]
#define kKnoteIdPrefix @"tempId."


#define kDateFormat @"MMM dd yyyy,hh:mm aa"
#define kDateFormat1 @"MMM dd yyyy, hh:mm:ss aa"
#define kDateFormat2 @"EEE MMM dd hh:mm:ss aa yyy"
#define kCtlDateFormat @"EEEE MMMM dd HH:mm:ss Z yyyy"
#define kCtlDateFormat1 @"EEEE MMMM dd yyyy hh:mm aa Z yyyy"

#define kKnoteTimeIntervalMaxValue 9999999999.0

#define kVGap 4
#define kHGap 4


//for datetime view control
#define kDefaultRefreshInterval 60
#define KDefaultCheckTime 60*60*24


#define kLimitPeopleCount 5

#define kTextKnoteTitleHeight 42
#define kStatusbarH 20
#define kNavigationBarH 44
#define kSegmentBarH 60

#define kAvatorBaseUrl @"http://www.gravatar.com/avatar"

typedef enum _ItemOpType {
    ItemAdd,
    ItemModify
} ItemOpType;

typedef enum _ItemLifeCycle {
    ItemNew,
    ItemExisting,
    ItemSwapEditing
} ItemLifeCycle;

#define THREAD_TEST 1