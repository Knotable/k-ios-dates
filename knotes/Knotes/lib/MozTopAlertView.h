//
//  MozTopAlertView.h
//  MoeLove
//
//  Created by LuLucius on 14/12/7.
//  Copyright (c) 2014年 MOZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DesignManager.h"

typedef enum : NSUInteger {
    MozAlertTypeInfo,
    MozAlertTypeSuccess,
    MozAlertTypeWarning,
    MozAlertTypeError
} MozAlertType;
@protocol MozAlertDelegate <NSObject>

-(void)mozAlertViewWillDisplay;
-(void)mozAlertViewWillhide;

@end
@interface MozTopAlertView : UIView

@property(nonatomic, assign)BOOL autoHide;
@property(nonatomic, assign)NSInteger duration;
@property (nonatomic,weak)id<MozAlertDelegate>targetDelegate;
//@property(nonatomic, retain)UIView *parentView;

/*
 * btn target
 */
@property (nonatomic, copy) dispatch_block_t doBlock;

/*
 * action after dismiss
 */
@property (nonatomic, copy) dispatch_block_t dismissBlock;

+ (BOOL)hasViewWithParentView:(UIView*)parentView;
+ (void)hideViewWithParentView:(UIView*)parentView;
+ (MozTopAlertView*)viewWithParentView:(UIView*)parentView;

+ (MozTopAlertView*)showWithType:(MozAlertType)type text:(NSString*)text parentView:(UIView*)parentView;
+ (MozTopAlertView*)showWithType:(MozAlertType)type text:(NSString*)text doText:(NSString*)doText andDelegate:(id)delegate doBlock:(dispatch_block_t)doBlock parentView:(UIView*)parentView;

@end
// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net