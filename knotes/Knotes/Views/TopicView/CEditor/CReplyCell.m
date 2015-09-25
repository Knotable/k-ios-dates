//
//  CReplyCell.m
//  Knotable
//
//  Created by Dhruv on 3/23/15.
//
//

#import "CReplyCell.h"

@implementation CReplyCell

- (void)awakeFromNib {
    // Initialization code
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

{
    self.lbl_ReplyText =[[UILabel alloc]init];
    self.lbl_ReplyText.font=[DesignManager knoteBodyFont];
    self.lbl_ReplyText.numberOfLines=0;
    self.lbl_ReplyText.lineBreakMode = NSLineBreakByWordWrapping;
    self.lbl_ReplyText.backgroundColor=[UIColor clearColor];
    self.contentView.backgroundColor=[UIColor clearColor];
    [self.contentView addSubview:self.lbl_ReplyText];
    self.replyTime=[[UILabel alloc]init];
    self.replyTime.font=[DesignManager knoteTimeFont];
    self.replyTime.numberOfLines=0;
    self.replyTime.lineBreakMode=NSLineBreakByWordWrapping;
    self.replyTime.textColor=[DesignManager KnoteCommentsTimeLabelColor];
    self.replyTime.textAlignment=NSTextAlignmentRight;
    [self.contentView addSubview:self.replyTime];
    self.menu = [[QuadCurveMenu alloc] initWithFrame:self.bounds
                                         centerPoint:CGPointMake(4, 2)
                                          dataSource:nil
                                     mainMenuFactory:nil
                                     menuItemFactory:nil];
    self.menu.delegate = self;
    [self addSubview:self.menu];
    [self bringSubviewToFront:self.menu];
}
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setGotReply:(NSDictionary *)gotReply
{
    _gotReply=gotReply;
    self.lbl_ReplyText.text=[self getString:gotReply];
    self.replyTime.text=[[ThreadItemManager sharedInstance]getDateTimeIndicate:[self getTimeInterval:gotReply]];
    ContactsEntity *replier_contact = [ContactsEntity MR_findFirstByAttribute:@"mainEmail" withValue:gotReply[@"from"]];
    if (!replier_contact) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email like[cd] %@",[NSString stringWithFormat:@"*%@*",gotReply[@"from"]]];//查询条件
        replier_contact = [ContactsEntity MR_findFirstWithPredicate:predicate];
    }
    
    if (replier_contact) {
        if ([replier_contact isFault]) {
            [replier_contact MR_refresh];
        }
        [replier_contact getAsyncImageWithBlock:^(id img, BOOL flag)
         {
             
             if (img)
             {
                 UIImage *image = [img circlePlainImageSize:30];
                 
                 QuadCurveCustomMenuItemFactory *imgMenuItem = [[QuadCurveCustomMenuItemFactory alloc] initWithImage:image
                                                                                                      highlightImage:image];
                 
                 self.menu.mainMenuItemFactory = imgMenuItem;
                 self.menu.expandItemAnimation=nil;

                 self.menu.mainMenuButton.dataObject = replier_contact;
             }
         }];
    } else {
        if ([gotReply objectForKey:@"from"]) {
            [ContactManager findContactFromServerByEmail:gotReply[@"from"]];
        }
    }
      [self setNeedsUpdateConstraints];
}
-(void)updateConstraints
{
    [super updateConstraints];
    [self.menu mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(13));
        make.left.equalTo(@(15));
        make.height.equalTo(@(30));
        make.width.equalTo(@(20));
    }];
    [self.lbl_ReplyText mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(2));
        NSLog(@"%@",NSStringFromCGRect([UIScreen mainScreen].bounds));
        CGRect size=[CUtil getTextRect:self.lbl_ReplyText.text Font:[DesignManager knoteBodyFont] Width:CGRectGetWidth([UIScreen mainScreen].bounds)-22];
        make.height.equalTo(@(size.size.height - REMOVE_COMMENT_LABEL_EXTRA_VERTICALSPACE));
        make.width.equalTo(@(CGRectGetWidth([UIScreen mainScreen].bounds)-35));
        make.left.equalTo(self.menu.mas_right);
    }];
    [self.replyTime mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lbl_ReplyText.mas_bottom);
        NSLog(@"%@",NSStringFromCGRect([UIScreen mainScreen].bounds));
        make.height.equalTo(@(15));
        make.width.equalTo(@(CGRectGetWidth([UIScreen mainScreen].bounds)-8));
        //make.left.equalTo(@(4));
        make.right.equalTo(self.contentView).offset(-4);
        //make.bottom.equalTo(@(5));
        //make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-5);
    }];
}
/*-(CGFloat)getHeightOfCell:(NSDictionary *)tempReply
{
    CGFloat height=0;
    height += [CUtil getTextRect:(NSString *)[self getString:tempReply] Font:[DesignManager knoteBodyFont] Width:CGRectGetWidth([UIScreen mainScreen].bounds)-8].size.height;
    height +=10;
    return height;
}*/

-(NSString *)getString:(NSDictionary *)content
{
        if (!content) {
            return @"";
        }
        NSString *text = content[@"body"] ;
        if (text && [text isKindOfClass:[NSString class]] && (text.length > 3)) {
            HybridDocument *document = [[HybridDocument alloc] initWithHTML:text];
            text = document.text;
            if(!text){
                text = @"";
            }
        }
    return text;
}
-(NSTimeInterval)getTimeInterval:(NSDictionary *)content
{
    [content objectForKey:@"from"];
    
    NSDate  *editDateVal = [content objectForKey:@"date"];
    NSTimeInterval interval = 0;
    if ([editDateVal isKindOfClass:[NSDate class]]) {
        interval = [editDateVal timeIntervalSince1970];
    } else if ([editDateVal isKindOfClass:[NSDictionary class]]) {
        NSNumber *t= [(NSDictionary *)editDateVal valueForKey:@"$date"];
        if (t && [t isKindOfClass:[NSNumber class]]) {
            interval = t.longLongValue;
        }
    }
    return interval;
}
#pragma mark - QuadCurveMenuDelegate Adherence
- (void)quadCurveMenu:(QuadCurveMenu *)menu didTapMenu:(QuadCurveMenuItem *)mainMenuItem
{
    menu.expanding=NO;
    [menu closeMenu];
    if (mainMenuItem.dataObject)
    {
        if (self.delegate
            && [self.delegate respondsToSelector:@selector(titleInfoClickeAtContact:)])
        {
            [self.delegate titleInfoClickeAtContact:(ContactsEntity *)mainMenuItem.dataObject];
        }
        
        [menu closeMenu];
    }
}

@end
