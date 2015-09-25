//
//  MenuView.h
//  Knotable
//
//  Created by wuli on 14-3-14.
//
//

#import <UIKit/UIKit.h>
#import "Singleton.h"
@protocol MenuViewDelegate <NSObject>
- (void)menuButtonClicked:(id)cell withTag:(NSInteger)tag;
@end
@interface MenuView : UIView
SYNTHESIZE_SINGLETON_FOR_HEADER(MenuView);
@property(nonatomic, weak) id cell;
@property (weak, nonatomic) id<MenuViewDelegate> delegate;
@property (assign, nonatomic) BOOL editable;
@property (assign, nonatomic) BOOL isShowing;

@property (readwrite, nonatomic) CGFloat buttonWidth;
-(id)initWithInfo:(NSArray *)info;
@end
