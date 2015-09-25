//
//  MenuView.m
//  Knotable
//
//  Created by wuli on 14-3-14.
//
//

#import "MenuView.h"
#import "CUtil.h"
#import "GMProtocol.h"

@interface MenuView()

@property (strong, nonatomic) UIImageView       *imgBg;
@property (strong, nonatomic) UILabel           *infoLabel;
@property (strong, nonatomic) NSMutableArray    *btnGroup;
@property (strong, nonatomic) NSMutableArray    *imgGroup;

@end

@implementation MenuView

SYNTHESIZE_SINGLETON_FOR_CLASS(MenuView);

- (instancetype)init
{
    NSDictionary *dic0 = [NSDictionary dictionaryWithObjectsAndKeys:@"",kBtnTitle,@"delete_icon",kBtnIconName,kMenuGrayColor,kBtnBG,[NSNumber numberWithInt:GmDeleteTag],kBtnTag, nil];
    NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:@"",kBtnTitle,@"pencil_icon",kBtnIconName,kMenuGrayColor,kBtnBG,[NSNumber numberWithInt:GmEditTag],kBtnTag, nil];
    NSDictionary *dic2 = [NSDictionary dictionaryWithObjectsAndKeys:@"",kBtnTitle,@"like_icon",kBtnIconName,kMenuGrayColor,kBtnBG,[NSNumber numberWithInt:GmLikeTag],kBtnTag, nil];
    NSArray *array = [[NSArray alloc] initWithObjects:dic0,dic1,dic2, nil];

    self = [self initWithInfo:array];
    if (self) {
        
    }
    return self;
}

-(id)initWithInfo:(NSArray *)info
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.22 green:0.25 blue:0.32 alpha:0.9];
        
        self.btnGroup = [[NSMutableArray alloc] initWithCapacity:3];
        self.imgGroup = [[NSMutableArray alloc] initWithCapacity:3];
        
        for (int i = 0;i<[info count];i++) {
            NSDictionary *dic = (NSDictionary *)[info objectAtIndex:i];
            UIImage * img = [UIImage imageNamed:[dic objectForKey:kBtnIconName]];
            UIImageView *imgV = [[UIImageView alloc] initWithImage:img];
            [imgV setFrame:CGRectMake(0, 0, 28, 28)];
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectZero];
            btn.tag = [[dic objectForKey:kBtnTag] integerValue];
            //            [btn setTitle:[dic objectForKey:kBtnTitle] forState:UIControlStateNormal];
            btn.backgroundColor = [dic objectForKey:kBtnBG];
            btn.titleLabel.font = kCustomBoldFont(16);
            [btn addSubview:imgV];
            [self addSubview:btn];
            [btn addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [_btnGroup addObject:btn];
            [_imgGroup addObject:imgV];
        }
        
        _editable = YES;
        self.userInteractionEnabled = YES;
        return self;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat height = 44;
    CGFloat menuOptionButtonWidth = (CGRectGetWidth(self.bounds)-20)/[self.imgGroup count];
    CGFloat startY = 0;
    _buttonWidth = menuOptionButtonWidth;
    
    for (UIImageView *imgV in self.imgGroup) {
        [imgV setFrame:CGRectMake((menuOptionButtonWidth-imgV.frame.size.width)/2, (height-imgV.frame.size.height)/2, imgV.frame.size.width, imgV.frame.size.height)];
    }
    CGFloat x= 10;
    for (UIButton *btn in self.btnGroup) {
        [btn setFrame:CGRectMake(x, 0, menuOptionButtonWidth, height)];
        x+=menuOptionButtonWidth;
    }
    CGRect rect = self.frame;
    CGRect imgRect = _imgBg.frame;
    CGRect labRect = _infoLabel.frame;
    startY = (rect.size.height-imgRect.size.height-labRect.size.height)/2;
    CGFloat startX = (rect.size.width- menuOptionButtonWidth - imgRect.size.width)/2;
    imgRect.origin.x = startX;
    imgRect.origin.y = startY;
    [_imgBg setFrame:imgRect];
    startY = imgRect.origin.y+imgRect.size.height;
    startX = (rect.size.width- menuOptionButtonWidth - labRect.size.width)/2;
    labRect.origin.x = startX;
    labRect.origin.y = startY;
    [_infoLabel setFrame:labRect];
}

- (CGFloat)menuOptionButtonWidth
{
    return 100;
}

- (void)buttonTapped:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(menuButtonClicked:withTag:)]) {
        [self.delegate menuButtonClicked:self.cell withTag:btn.tag];
    }
}
@end
