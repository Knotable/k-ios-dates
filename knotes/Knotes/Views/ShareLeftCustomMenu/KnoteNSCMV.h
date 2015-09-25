//
//  KnoteBMBV.h
//  Knotable
//
//  Created by Lin on 31/7/14.
//
//

#import <UIKit/UIKit.h>

@protocol KnoteNSCMDelegate <NSObject>

- (void) SharePadAddAction;
- (void) SharePadSortAction;


@end

@interface KnoteNSCMV : UIView

@property (nonatomic, strong) IBOutlet  UIButton    *m_btnAdd;
@property (nonatomic, strong) IBOutlet  UIButton    *m_btnSort;

@property (readwrite,weak) id<KnoteNSCMDelegate> targetDelegate;

- (IBAction)addAction:(id)sender;
- (IBAction)sortAction:(id)sender;

@end
