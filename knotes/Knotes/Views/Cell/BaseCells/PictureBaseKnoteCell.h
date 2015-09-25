//
//  BaseKnoteCell.h
//  
//
//  Created by Martin Ceperley on 12/22/13.
//
//

#import <UIKit/UIKit.h>
#import "CEditBaseItemView.h"
#import "MCSwipeTableViewCell.h"
#import "TopicInfo.h"

@class MessageEntity, SWTableViewCell;

//@interface BaseKnoteCell : UITableViewCell

@interface PictureBaseKnoteCell : MCSwipeTableViewCell

@property (nonatomic, strong) CTitleInfoBar *titleInfoBar;

@property (nonatomic, strong) UIView *bodyView;
@property (nonatomic, strong) UIView *header;
@property (nonatomic, strong) UIView *background;
@property (nonatomic, strong) UIView *overlay;

@property (nonatomic, strong) UILabel *topicLabel;


@property (nonatomic, strong) MessageEntity* message;
@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, assign) BOOL shouldHideHeader;
@property (nonatomic, assign) BOOL headerOnTop;
@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) BOOL expandeMode;

@property (nonatomic, strong) TopicInfo     *cellTInfo;


- (id)init;
- (void)setMaxWidth;

- (void)beganEditing;
- (void)wasEdited;
- (void)finishedEditing;

- (void)willAppear;
- (void)didDissapear;

- (void)showOverlay:(BOOL)showing animate:(BOOL)animate;

@end
