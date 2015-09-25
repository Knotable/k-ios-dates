//
//  KnoteBMBV.h
//  Knotable
//
//  Created by Lin on 31/7/14.
//
//

#import <UIKit/UIKit.h>

@protocol KnoteNMDelegate <NSObject>

-(void) NavigationMenuActionIndex:(NSInteger)butIndex;

@end

@interface KnoteNMV : UIView
{
//    BOOL    archiveSelectedFlag;
//    BOOL    reorderSelectedFlag;
    
}

@property (atomic, assign )   BOOL  archiveSelectedFlag;
@property (atomic, assign )   BOOL  reorderSelectedFlag;

@property (nonatomic, strong) IBOutlet  UIButton    *m_btnArchive;
@property (nonatomic, strong) IBOutlet  UIButton    *m_btnReorder;

@property (readwrite,weak) id<KnoteNMDelegate> targetDelegate;

- (IBAction)menuAction:(id)sender;

@end
