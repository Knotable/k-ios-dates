//
//  COverlayView.h
//  DAContextMenuTableViewControllerDemo
//
//  Created by Daria Kopaliani on 7/25/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CUtil.h"

@class COverlayView;

@protocol COverlayViewDelegate <NSObject>

- (UIView *)overlayView:(COverlayView *)view didHitTest:(CGPoint)point withEvent:(UIEvent *)event;

@end


@interface COverlayView : UIView

@property (weak, nonatomic) id<COverlayViewDelegate> delegate;
@property (strong, nonatomic) NSString *deleteButtonTitle;
@property (strong, nonatomic) NSString *editButtonTitle;
@property (strong, nonatomic) NSString *likeButtonTitle;
@property (assign, nonatomic) BOOL editable;

@end
