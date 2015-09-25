//
//  KnoteBMBV.m
//  Knotable
//
//  Created by Lin on 31/7/14.
//
//

#import "KnoteNMTV.h"
#import "DesignManager.h"

@implementation KnoteNMTV

@synthesize m_btnMute;

-(id)init
{
    self =[super init];
    
    if (self) {
        // Initialization code
        
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"KnoteNMTV" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[KnoteNMTV class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


#pragma mark -
#pragma mark - Mute Buttons' Action

- (IBAction)speakerAction:(id)sender
{
    if ([[self targetDelegate]respondsToSelector:@selector(NavigationMuteManage)])
    {
        [[self targetDelegate] NavigationMuteManage];
    }    
}

@end
