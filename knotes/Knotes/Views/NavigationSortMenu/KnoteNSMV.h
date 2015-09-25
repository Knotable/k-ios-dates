//
//  KnoteBMBV.h
//  Knotable
//
//  Created by Lin on 31/7/14.
//
//

#import <UIKit/UIKit.h>

@protocol KnoteNSMDelegate <NSObject>

-(void) NavigationSortAction;

@end

@interface KnoteNSMV : UIView
{
    BOOL    sortSelectd;
    
}

@property (nonatomic, strong) IBOutlet  UIButton    *m_btnSort;

@property (readwrite,weak) id<KnoteNSMDelegate> targetDelegate;

- (IBAction)sortAction:(id)sender;

@end
