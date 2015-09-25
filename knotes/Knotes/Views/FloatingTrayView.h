//
//  FloatingTrayView.h
//  Knotable
//
//  Created by Martin Ceperley on 1/17/14.
//
//

@protocol FloatingTrayDelegate

@optional

-(void)floatingTraySetAlphabetical:(BOOL)alphabetical;
-(void)floatingTraySetArchived:(BOOL)archived;
-(void)floatingTraysetOneReorder:(BOOL)reorder;
-(void)floatingTraysetReorder:(BOOL)reorder;
-(void)floatingTrayLock;
-(void)floatingTrayShared:(NSMutableArray *)contactsArray;

@end

@interface FloatingTrayView : UIView {
    BOOL bShowArchived;
    BOOL bShowShare;
    BOOL bShowLock;
}

-(void)showArchived:(BOOL)bShow;
-(void)showLock:(BOOL)bShow;
-(void)showShare:(BOOL)bShow;
-(void)showReorder:(BOOL)bShow;
-(void)installConstraints;

@property (nonatomic, weak) NSObject<FloatingTrayDelegate>* delegate;
@property (nonatomic, strong) UIButton *archivedButton;
@property (nonatomic, strong) UIButton *alphabeticalButton;
@property (nonatomic, strong) UIButton *lockButton;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic,strong) UIButton *reorderButton;
@end
