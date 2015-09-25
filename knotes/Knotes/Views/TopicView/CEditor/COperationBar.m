//
//  COperationBar.m
//  Knotable
//
//  Created by leejan97 on 13-12-16.
//
//

#import "COperationBar.h"
#import "CUtil.h"

#define kButtonWidth 60
#define kButtonHeight 22

@interface COperationBar()

@property (nonatomic, strong) NSMutableArray *btnArray;
@property (nonatomic, strong) UILabel * likesLabel;

@end

@implementation COperationBar

@synthesize btnArray = _btnArray;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.btnArray = [[NSMutableArray alloc] initWithCapacity:3];
    }
    return self;
}

-(void)updateLikesNow:(NSNotification *)notification
{
    NSString * text = [notification.object description];
    self.likesLabel.text = text;
}

#define BUTTONSIZE 30
- (void)setImageWithContact:(ContactsEntity *)contact
{
    
    UIImageView *btn = [[UIImageView alloc]init];
    if (contact.fullURL)
    {
        [btn sd_setImageWithURL:[NSURL URLWithString:contact.fullURL]];
    }
    else
    {
        NSString * text = contact.name;
        if ([text length]>0)
        {
            text = [text substringWithRange:NSMakeRange(0, 1)].uppercaseString;
            [btn setImage:[CUtil imageText:text withBackground:contact.bgcolor size:CGSizeMake(40, 40) rate:0.6]];
        }
        else
        {
            text = @"N";;
            [btn setImage:[CUtil imageText:text withBackground:@"bgcolor5" size:CGSizeMake(40, 40) rate:0.6]];
        }
    }
    [btn setFrame:CGRectMake(0, 0, 20, 20)];
    [btn setBackgroundColor:[UIColor blackColor]];
    btn.layer.cornerRadius=btn.frame.size.height/2;
    btn.layer.masksToBounds = YES;
    btn.tag = 103;
    [self addSubview:btn];
    //[self.btnArray addObject:btn];
}


- (void)setButtonsArray:(NSArray *)array
{
    if (array)
    {
        for (NSDictionary *dic in array)
        {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *img = [UIImage imageNamed:[dic objectForKey:kBtnBG]];
            [btn setBackgroundImage: img forState:UIControlStateNormal];
            [btn setFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
            btn.tag = [[dic objectForKey:kBtnTag] integerValue];
            [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.btnArray addObject:btn];
            
            // Will look for likes label
            if([@"like_icon" isEqual:[dic objectForKey:kBtnBG]])
            {
                if(!self.likesLabel)
                {
                    self.likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, BUTTONSIZE, BUTTONSIZE)];
                    self.likesLabel.textColor = [UIColor redColor];
                    self.likesLabel.textAlignment = NSTextAlignmentCenter;
                    self.likesLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0];
                    self.likesLabel.tag = 100;
                    [btn addSubview:self.likesLabel];
                }
                
            }
        }
    }
}

-(void)likesVisible
{
    if([self.likesLabel.text isEqualToString:@"0"])
    {
        UIButton *btn = [self.btnArray objectAtIndex:2];
        [btn addSubview:self.likesLabel];
    }
}

- (void) layoutSubviews {
#if 1
    CGFloat startX = 0;
    CGFloat startY = 0;
    for (int i = 0; i<[self.btnArray count]; i++) {
        UIButton *btn = [self.btnArray objectAtIndex:i];
        [btn setFrame:CGRectMake(startX, startY, btn.bounds.size.width, btn.bounds.size.height)];
        [self addSubview:btn];
        startX += (btn.bounds.size.width + 4);
    }
#else
    CGFloat startX = 0;
    CGFloat startY = 0;
    for (int i = 0; i<[self.btnArray count]; i++) {
        UIButton *btn = [self.btnArray objectAtIndex:i];
        [btn setFrame:CGRectMake(startX, startY, btn.bounds.size.width, btn.bounds.size.height)];
        [self addSubview:btn];
        startX += (btn.bounds.size.width + 4);
    }
#endif
}

- (void)btnClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(operationButtonClickWithTag:)]) {
        [self.delegate operationButtonClickWithTag:btn.tag];
    }
}

@end
