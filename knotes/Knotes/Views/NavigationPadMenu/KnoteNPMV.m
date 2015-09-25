//
//  KnoteBMBV.m
//  Knotable
//
//  Created by Lin on 31/7/14.
//
//

#import "KnoteNPMV.h"
#import "DesignManager.h"
#import "Constant.h"

@implementation KnoteNPMV


@synthesize m_btnText;
@synthesize m_btnDeadline;
@synthesize m_btnChecklist;
@synthesize m_btnVote;

-(id)init
{
    NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"KnoteNPMV" owner:self options:nil];
    self = [arrayOfViews count] > 0 && [[arrayOfViews objectAtIndex:0] isKindOfClass:[KnoteNPMV class]] ? [arrayOfViews objectAtIndex:0] : nil ;
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
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
    
    if ([[self targetDelegate]respondsToSelector:@selector(PadMenuActionIndex:)])
    {
        switch (senderTag)
        {
            case NPMV_TEXT_TAG:
                
                [[self targetDelegate] PadMenuActionIndex:0];
                
                break;
                
            case NPMV_DEADLINE_TAG:
                
                [[self targetDelegate] PadMenuActionIndex:1];
                
                break;
                
            case NPMV_CHECKLIST_TAG:
                
                [[self targetDelegate] PadMenuActionIndex:2];
                
                break;
                
            case NPMV_VOTE_TAG:
                
                [[self targetDelegate] PadMenuActionIndex:3];
                
                break;
        }
    }    
}

@end
