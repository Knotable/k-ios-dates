//
//  BI_ViewConst.h
//  BaiduIMLib
//
//  Created by backup on 12-2-27.
//  Copyright (c) 2012年 backup. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat kMinMoveDistance;
extern const CGFloat kHitTestGridWidth;
extern const CGFloat kHitTestGridHeight;
extern const CGFloat kHintViewSmallFontSize;
extern const CGFloat kHintViewLargeFontSize;
extern const CGFloat kMinSwipeScreenDistanceHorizontal;
extern const CGFloat kMaxSwipeScreenTimeInterval;
extern const CGFloat kDefaultLongPressInterval;
extern const CGFloat kDefaultLongPressedRepeatTimeInterval;

typedef enum
{
    kKeyboardViewLevelNone,     //不指定，则为一般面板
    kKeyboardViewLevelPanel,    //键盘面板（必须放在最底部）
    kKeyboardViewLevelGeneric,  //一般面板（更多候选字面板，符号列表等）
    kKeyboardViewLevelNight,    //夜间模式视图
    kKeyboardViewLevelSnapshot, //滑屏时的截图
    kKeyboardViewLevelPage,     //页面指示视图
    kKeyboardViewLevelMenu,     //菜单
    kKeyboardViewLevelMask,     //显示气泡时的半透层（必须放在气泡下面）
    kKeyboardViewLevelHint,     //显示气泡（必须放在最顶部）
}BIKeyboardViewLevel;

typedef enum {
    kTouchStyleNone,
    kTouchStyleTap,            //点击
    kTouchStyleDragUp,         //点划
    kTouchStyleDragDown,
    kTouchStyleDragLeft,
    kTouchStyleDragRight,
    kTouchStyleLong,           //长按
} BITouchStyle;




