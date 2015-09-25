//
//  ShareListController.h
//  Knotable
//
//  Created by Martin Ceperley on 3/17/14.
//
//

#import <UIKit/UIKit.h>
#import "SwipeTableView.h"
#if New_DrawerDesign
#import "SharePeopleCell.h"
#endif
#import "FloatingTrayView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImage+Tint.h"
#import "CustomBarButtonItem.h"

@class TopicsEntity, UserEntity;

@protocol ShareListDelegateProtocol <NSObject>
@optional

-(void) sharingWithContacts:(NSArray *)contacts;
-(void) updateSharedTopicContacts;
-(void) addContactPressedFromSharelist;
-(void)makeViewFullScreen;
@end

@interface ShareListController : UIViewController <SwipeTableViewDelegate,
                                                    FloatingTrayDelegate,
                                                    UITableViewDelegate,
                                                    UITableViewDataSource,
                                                    UISearchBarDelegate,
                                                    UISearchDisplayDelegate>
@property (nonatomic,strong) TopicsEntity *topic;
@property (nonatomic, strong) UIView *searchBgView;
@property (nonatomic, strong) UIButton *recordBtn;

- (id)initWithTopic:(TopicsEntity *)topic loginUser:(UserEntity *)loginUser sharedContacts:(NSArray *)sharedContacts;
- (id)initWithTopic:(TopicsEntity *)topic loginUser:(UserEntity *)loginUser sharedContacts:(NSArray *)sharedContacts isForCombinedView:(BOOL)isForCombinedView;
-(void)actionSheetRemovance;
-(void)getAtON:(id)result;
@property (nonatomic, strong) id<ShareListDelegateProtocol> delegate;

@end
