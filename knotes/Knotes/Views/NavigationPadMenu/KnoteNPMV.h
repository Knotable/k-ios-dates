//
//  KnoteBMBV.h
//  Knotable
//
//  Created by Lin on 31/7/14.
//
//

#import <UIKit/UIKit.h>

@protocol KnoteNPMDelegate <NSObject>

-(void) PadMenuActionIndex:(NSInteger)butIndex;

@end

@interface KnoteNPMV : UIView
{
    
}

@property (nonatomic, strong) IBOutlet  UIButton    *m_btnText;
@property (nonatomic, strong) IBOutlet  UIButton    *m_btnDeadline;
@property (nonatomic, strong) IBOutlet  UIButton    *m_btnChecklist;
@property (nonatomic, strong) IBOutlet  UIButton    *m_btnVote;

@property (readwrite,weak) id<KnoteNPMDelegate> targetDelegate;

- (IBAction)menuAction:(id)sender;

@end
