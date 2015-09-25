//
//  KnoteBMBV.m
//  Knotable
//
//  Created by Lin on 31/7/14.
//
//

#import "KnoteNMV.h"
#import "DesignManager.h"

@implementation KnoteNMV


@synthesize m_btnArchive;
@synthesize m_btnReorder;
@synthesize archiveSelectedFlag;
@synthesize reorderSelectedFlag;

-(id)init
{
    self =[super init];
    
    if (self) {
        // Initialization code
        
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"KnoteNMV" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[KnoteNMV class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
        
        archiveSelectedFlag = NO;
        reorderSelectedFlag = NO;
        
        [self.m_btnArchive setBackgroundImage:[UIImage imageNamed:@"trash_normal"] forState:UIControlStateNormal];
        [self.m_btnArchive setBackgroundImage:[UIImage imageNamed:@"trash_selected"] forState:UIControlStateSelected];
        [self.m_btnArchive setBackgroundImage:[UIImage imageNamed:@"trash_selected"] forState:UIControlStateHighlighted];
        
        [self.m_btnReorder setBackgroundImage:[UIImage imageNamed:@"order_normal"] forState:UIControlStateNormal];
        [self.m_btnReorder setBackgroundImage:[UIImage imageNamed:@"order_selected"] forState:UIControlStateSelected];
        [self.m_btnReorder setBackgroundImage:[UIImage imageNamed:@"order_selected"] forState:UIControlStateHighlighted];
        
        self.m_btnReorder.hidden = YES;
    }
    return self;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

#pragma mark -
#pragma mark - Menu Buttons' Action
- (IBAction)menuAction:(id)sender
{
    UIButton    *button = (UIButton*)sender;
    
    NSInteger   senderTag = button.tag;
    
    if ([[self targetDelegate]respondsToSelector:@selector(NavigationMenuActionIndex:)])
    {
        switch (senderTag)
        {
            case 100:
                
                if (archiveSelectedFlag)
                {
                    [self.m_btnArchive setBackgroundImage:[UIImage imageNamed:@"trash_normal"] forState:UIControlStateNormal];
                }
                else
                {
                    [self.m_btnArchive setBackgroundImage:[UIImage imageNamed:@"trash_selected"] forState:UIControlStateNormal];
                }
                
                archiveSelectedFlag = !archiveSelectedFlag;
                
                [[self targetDelegate] NavigationMenuActionIndex:0];
                
                break;
                
            case 101:
                
                
                if (reorderSelectedFlag)
                {
                    [self.m_btnReorder setBackgroundImage:[UIImage imageNamed:@"order_normal"] forState:UIControlStateNormal];
                }
                else
                {
                    [self.m_btnReorder setBackgroundImage:[UIImage imageNamed:@"order_selected"] forState:UIControlStateNormal];
                }
                
                reorderSelectedFlag = !reorderSelectedFlag;
                
                [[self targetDelegate] NavigationMenuActionIndex:1];
                
                break;
        }
    }    
}

@end
