//
//  CEditHeaderInfoView.h
//  Knotable
//
//  Created by backup on 11/18/14.
//
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, header_button_tag)
{
    HEADER_BUTTON_TRASH,
    HEADER_BUTTON_KNOTE,
    HEADER_BUTTON_VOTE,
    HEADER_BUTTON_TASK,
    HEADER_BUTTON_DATE,
};
@protocol CEditHeaderInfoViewDelegate <NSObject>
-(void)headerButtonClickedAt:(NSInteger)index;
-(void)deleteButtonClicked;

@end

@interface CEditHeaderInfoView : UIView
//@property (nonatomic, strong) UISegmentedControl *selectControl;
@property (nonatomic, strong) NSMutableDictionary *contentDic;
@property (nonatomic, weak) id <CEditHeaderInfoViewDelegate>delegate;
@property (nonatomic, strong) UIButton  *deleteButton;
@property (nonatomic, strong) UILabel   *preDeletButtonLabel;
@property (nonatomic, assign) NSInteger num;

@property (nonatomic, assign) BOOL showArchived;
- (void) flashButton;
@end
