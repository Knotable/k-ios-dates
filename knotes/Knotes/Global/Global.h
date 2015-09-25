#import <UIKit/UIKit.h>

#import "AppDelegate.h"

typedef enum {
    DEVICE_IPHONE_35INCH,
    DEVICE_IPHONE_40INCH,
    DEVICE_IPHONE_47INCH,
    DEVICE_IPHONE_55INCH,
    DEVICE_IPAD,
} DEVICE_TYPE;


typedef enum {
    IOS_8 = 4,
    IOS_7 = 3,
    IOS_6 = 2,
    IOS_5 = 1,
    IOS_4 = 0,
} IOS_VERSION;

IOS_VERSION gIOSVersion;

DEVICE_TYPE gDeviceType;
CGSize gScreenSize;

UIInterfaceOrientation gDeviceOrientation;