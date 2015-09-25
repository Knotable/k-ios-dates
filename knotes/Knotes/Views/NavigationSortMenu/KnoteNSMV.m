//
//  KnoteBMBV.m
//  Knotable
//
//  Created by Lin on 31/7/14.
//
//

#import "KnoteNSMV.h"
#import "DesignManager.h"

@implementation KnoteNSMV

@synthesize m_btnSort;

-(id)init
{
    self =[super init];
    
    if (self) {
        // Initialization code
        
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"KnoteNSMV" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[KnoteNSMV class]]) {
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

#pragma mark -
#pragma mark - Menu Buttons' Action
- (IBAction)sortAction:(id)sender
{
    if ([[self targetDelegate]respondsToSelector:@selector(NavigationSortAction)])
    {
        sortSelectd = !sortSelectd;
        [[self targetDelegate] NavigationSortAction];
    }    
}

@end
