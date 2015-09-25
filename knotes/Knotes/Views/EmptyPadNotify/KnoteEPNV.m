//
//  KnoteBMBV.m
//  Knotable
//
//  Created by Lin on 31/7/14.
//
//

#import "KnoteEPNV.h"
#import "UIButton+Extensions.h"

#define KNOTEBUTTONWIDTH    140
#define KNOTEBUTTONHEIGHT   38

@interface KnoteEPNV()



@end

@implementation KnoteEPNV

-(id)init
{
    self =[super init];
    
    if (self) {
        // Initialization code
#if 0
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"KnoteEPNV" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[KnoteEPNV class]])
        {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
#else
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        CGFloat height = screenSize.height-  64 - 48;
        
        self.lbl_Slogan = [[UILabel alloc] init];
        
        self.lbl_Slogan.text = @"This pad feels empty";
        
        self.lbl_Slogan.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:25.0]/*[UIFont systemFontOfSize:25]*/;
        self.lbl_Slogan.textAlignment = NSTextAlignmentCenter;
        self.lbl_Slogan.textColor = [UIColor darkGrayColor];
        
        [self addSubview:self.lbl_Slogan];
        
        // Button Part - 
        
        self.but_AddKnote = [UIButton buttonWithType:UIButtonTypeCustom];
        self.but_AddSomeone = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [self.but_AddKnote setTitle:@"Make a note" forState:UIControlStateNormal];
        [self.but_AddSomeone setTitle:@"Add someone" forState:UIControlStateNormal];
        
        [self.but_AddKnote addTarget:self action:@selector(onMakeNewKnote:) forControlEvents:UIControlEventTouchUpInside];
        self.but_AddKnote.layer.borderColor = [UIColor colorWithRed:0/255.0 green:170/255.0 blue:241/255.0 alpha:255/255.0].CGColor;
        [self.but_AddKnote setTitleColor:[UIColor colorWithRed:0/255.0 green:170/255.0 blue:241/255.0 alpha:255/255.0] forState:UIControlStateNormal];
        self.but_AddKnote.layer.borderWidth = 1;
        self.but_AddKnote.layer.cornerRadius = 5;
        
        [self.but_AddSomeone addTarget:self action:@selector(onAddSomeone:) forControlEvents:UIControlEventTouchUpInside];
        self.but_AddSomeone.layer.borderColor = [UIColor colorWithRed:0/255.0 green:170/255.0 blue:241/255.0 alpha:255/255.0].CGColor;
        [self.but_AddSomeone setTitleColor:[UIColor colorWithRed:0/255.0 green:170/255.0 blue:241/255.0 alpha:255/255.0] forState:UIControlStateNormal];
        self.but_AddSomeone.layer.borderWidth = 1;
        self.but_AddSomeone.layer.cornerRadius = 5;
        
        self.but_AddKnote.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0]/*[UIFont systemFontOfSize:20]*/;
        
        [self.but_AddKnote  setHitTestEdgeInsets:UIEdgeInsetsMake(-30, -30, -30, -30)];

        [self setFrame:CGRectMake(0, 0, screenSize.width, height)];
        
        self.but_AddSomeone.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0]/*[UIFont systemFontOfSize:20]*/;
        
        [self.but_AddSomeone  setHitTestEdgeInsets:UIEdgeInsetsMake(-30, -30, -30, -30)];
        
        [self.lbl_Slogan setFrame:CGRectMake(0, (height-30)/2.0-4, screenSize.width, 30)];
        
        [self.but_AddKnote setFrame:CGRectMake((screenSize.width-KNOTEBUTTONWIDTH) / 2,
                                               ((height-KNOTEBUTTONHEIGHT-30)/3.0) * 2 + 50 - 4,
                                         KNOTEBUTTONWIDTH,
                                         KNOTEBUTTONHEIGHT)];
        
        CGFloat addsomeone_but_xPos = self.but_AddKnote.frame.origin.x;
        CGFloat addsomeone_but_yPos = self.but_AddKnote.frame.origin.y + KNOTEBUTTONHEIGHT + 20;
        
        [self.but_AddSomeone setFrame:CGRectMake(addsomeone_but_xPos, addsomeone_but_yPos, KNOTEBUTTONWIDTH, KNOTEBUTTONHEIGHT)];
        
#endif
        
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
- (IBAction)onMakeNewKnote:(id)sender
{
    if ([[self targetDelegate]respondsToSelector:@selector(actionMakeNewKnote)])
    {
        [[self targetDelegate] actionMakeNewKnote];
    }
}

- (IBAction)onAddSomeone:(id)sender
{
    if ([[self targetDelegate]respondsToSelector:@selector(actionAddSomeone)])
    {
        [[self targetDelegate] actionAddSomeone];
    }
}

@end
