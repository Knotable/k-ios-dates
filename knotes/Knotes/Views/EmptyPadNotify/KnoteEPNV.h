//
//  KnoteBMBV.h
//  Knotable
//
//  Created by Lin on 31/7/14.
//
//

#import <UIKit/UIKit.h>

@protocol KnoteEPNVDelegate <NSObject>

-(void) actionMakeNewKnote;
-(void) actionAddSomeone;


@end

@interface KnoteEPNV : UIView
{
}

@property (nonatomic, strong) UILabel*      lbl_Slogan;
@property (nonatomic, strong) UIButton*     but_AddKnote;
@property (nonatomic, strong) UIButton*     but_AddSomeone;

@property (readwrite,weak) id<KnoteEPNVDelegate> targetDelegate;

- (IBAction)onMakeNewKnote:(id)sender;
- (IBAction)onAddSomeone:(id)sender;

@end
