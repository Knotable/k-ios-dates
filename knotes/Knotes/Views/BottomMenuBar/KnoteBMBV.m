//
//  KnoteBMBV.m
//  Knotable
//
//  Created by Lin on 31/7/14.
//
//

#import "KnoteBMBV.h"
#import "DesignManager.h"

@implementation KnoteBMBV

@synthesize m_BMBView;

@synthesize m_btnPeople;
@synthesize m_btnPads;
@synthesize m_btnSetting;

@synthesize m_lblPeople;
@synthesize m_lblPads;
@synthesize m_lblSetting;

@synthesize m_imgPeople;
@synthesize m_imgPads;
@synthesize m_imgSetting;

-(id)init
{
    self =[super init];
    if (self) {
        // Initialization code
        
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"KnoteBMBV" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[KnoteBMBV class]]) {
            return nil;
        }
        
        self = [arrayOfViews lastObject];
        
    }
    return self;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

#pragma mark -
#pragma mark - Menu Buttons' Action
- (IBAction)menuAction:(id)sender
{
    UIButton    *button = (UIButton*)sender;
    
    NSInteger   senderTag = button.tag;
    
    if ([[self targetDelegate]respondsToSelector:@selector(BottomMenuActionIndex:)])
    {
        switch (senderTag) {
                
            case 101:
                
                [[self targetDelegate] BottomMenuActionIndex:1];
                
                break;
                
            case 102:
                
                [[self targetDelegate] BottomMenuActionIndex:2];
                
                break;
                
            case 103:
                
                [[self targetDelegate] BottomMenuActionIndex:3];
                
                break;
        }
    }    
}

- (void)UpdateButtonStateIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 1:
            
            [self.m_imgPeople   setImage:[UIImage imageNamed:@"people_selected"]];
            [self.m_imgPads     setImage:[UIImage imageNamed:@"pads_normal"]];
            [self.m_imgSetting  setImage:[UIImage imageNamed:@"setting_normal"]];
            
            break;
            
        case 2:
            
            [self.m_imgPeople   setImage:[UIImage imageNamed:@"people_normal"]];
            [self.m_imgPads     setImage:[UIImage imageNamed:@"pads_selected"]];
            [self.m_imgSetting  setImage:[UIImage imageNamed:@"setting_normal"]];
            
            break;
            
        case 3:
            
            [self.m_imgPeople   setImage:[UIImage imageNamed:@"people_normal"]];
            [self.m_imgPads     setImage:[UIImage imageNamed:@"pads_normal"]];
            [self.m_imgSetting  setImage:[UIImage imageNamed:@"setting_selected"]];
            
            break;
    }
}

@end
