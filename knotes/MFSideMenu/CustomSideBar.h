//
//  CustomSideBar.h
//  Knotable
//
//  Created by Dhruv on 5/6/15.
//
//

#import <UIKit/UIKit.h>
@protocol CustomSidebarDelegate <NSObject>
@optional
- (void)sidebarwillShowOnScreenAnimated:(BOOL)animatedYesOrNo;
- (void)sidebardidShowOnScreenAnimated:(BOOL)animatedYesOrNo;
- (void)sidebarwillDismissFromScreenAnimated:(BOOL)animatedYesOrNo;
- (void)sidebardidDismissFromScreenAnimated:(BOOL)animatedYesOrNo;
@end
@interface CustomSideBar : UIView<UIGestureRecognizerDelegate>

-(instancetype)initSideBarisShowingFromRight:(BOOL)isShowingFromRight withDelegate:(id)delegate;

@property(strong,nonatomic)UIViewController *ContainerInSidebar;
@property(nonatomic)BOOL isOpen;

@property(nonatomic)BOOL isShowingFromRight;

@property (nonatomic, weak) id <CustomSidebarDelegate> delegate;
- (void)handlePanning:(UIPanGestureRecognizer *)gestureRecognizer;
-(void)ShowSideBarWithAnimationWithController:(UIViewController *)control animated:(BOOL)animated;
-(void)hideSideBarWithAnimation:(BOOL)animated;
-(UIViewController *)getMainViewController;
@end
