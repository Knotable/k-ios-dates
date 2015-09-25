//
//  KnoteBMBV.h
//  Knotable
//
//  Created by Lin on 31/7/14.
//
//

#import <UIKit/UIKit.h>

@protocol KnoteNMTDelegate <NSObject>

-(void) NavigationMuteManage;

@end

@interface KnoteNMTV : UIView
{
    
}

@property (nonatomic, strong) IBOutlet  UIButton    *m_btnMute;

@property (readwrite,weak) id<KnoteNMTDelegate> targetDelegate;

- (IBAction)speakerAction:(id)sender;

@end
