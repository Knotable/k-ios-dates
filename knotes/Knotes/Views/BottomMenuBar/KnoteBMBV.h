//
//  KnoteBMBV.h
//  Knotable
//
//  Created by Lin on 31/7/14.
//
//

#import <UIKit/UIKit.h>

@protocol KnoteBMBDelegate <NSObject>
-(void) BottomMenuActionIndex:(NSInteger)butIndex;
@end

@interface KnoteBMBV : UIView

@property (nonatomic, strong) IBOutlet  UIView      *m_BMBView;

@property (nonatomic, strong) IBOutlet  UIButton    *m_btnPeople;
@property (nonatomic, strong) IBOutlet  UIButton    *m_btnPads;
@property (nonatomic, strong) IBOutlet  UIButton    *m_btnSetting;

@property (nonatomic, strong) IBOutlet  UILabel     *m_lblPeople;
@property (nonatomic, strong) IBOutlet  UILabel     *m_lblPads;
@property (nonatomic, strong) IBOutlet  UILabel     *m_lblSetting;

@property (nonatomic, strong) IBOutlet  UIImageView *m_imgPeople;
@property (nonatomic, strong) IBOutlet  UIImageView *m_imgPads;
@property (nonatomic, strong) IBOutlet  UIImageView *m_imgSetting;

@property (readwrite,weak) id<KnoteBMBDelegate> targetDelegate;

- (IBAction)menuAction:(id)sender;
- (void)UpdateButtonStateIndex:(NSInteger)buttonIndex;

@end
