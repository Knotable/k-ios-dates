//
//  KnoteBMBV.m
//  Knotable
//
//  Created by Lin on 31/7/14.
//
//

#import "KnoteNSCMV.h"
#import "DesignManager.h"

@implementation KnoteNSCMV

@synthesize m_btnAdd;
@synthesize m_btnSort;

-(id)init
{
    self =[super init];
    
    if (self) {
        // Initialization code
        
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"KnoteNSCMV" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[KnoteNSCMV class]]) {
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
#pragma mark - Menu Buttons' Action

- (IBAction)addAction:(id)sender
{
    if ([[self targetDelegate]respondsToSelector:@selector(SharePadAddAction)])
    {
        [[self targetDelegate] SharePadAddAction];
    }
}

- (IBAction)sortAction:(id)sender
{
    if ([[self targetDelegate]respondsToSelector:@selector(SharePadSortAction)])
    {        
        [[self targetDelegate] SharePadSortAction];
    }    
}

@end
