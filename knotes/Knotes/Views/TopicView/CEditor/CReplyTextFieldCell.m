//
//  CReplyTextFieldCell.m
//  Knotable
//
//  Created by Dhruv on 3/23/15.
//
//

#import "CReplyTextFieldCell.h"

@implementation CReplyTextFieldCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    {
        self.contentView.backgroundColor=[UIColor clearColor];
        self.txtPost=[[UITextField alloc]init];
        self.txtPost.delegate=self;
        self.txtPost.font=[DesignManager knoteBodyFont];
        [self.txtPost setPlaceholder:@"Write a comment..."];
        [self.txtPost setBorderStyle:UITextBorderStyleNone];
        [self.contentView addSubview:self.txtPost];
        self.btn_Post=[UIButton buttonWithType:UIButtonTypeCustom];
    
        [self.btn_Post setTitle:@"Done" forState:UIControlStateNormal];
        [self.btn_Post.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.0]];
        [self.btn_Post setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
        [self.btn_Post addTarget:self action:@selector(tapOnPost) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.btn_Post];
        self.underLine = [[UIView alloc] init];
        self.underLine.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        self.underLine.hidden = YES;
    
    
        [self.contentView addSubview:self.underLine];
    }
    return self;
}
-(void)setItempost:(CItem *)itempost
{
    _itempost=itempost;
    [self setNeedsUpdateConstraints];
}
-(void)updateConstraints
{
    [super updateConstraints];
    [self.txtPost mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(5));
        make.height.equalTo(@(25));
        make.left.equalTo(@(10));
        make.width.equalTo(self.contentView).offset(-50);   //-32
    }];
    [self.btn_Post mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.txtPost.mas_right);
        make.top.equalTo(@(10));    //14
        make.height.equalTo(@(21)); //21
        make.width.equalTo(@(30));  //21
        
    }];
    [self.underLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(1));
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self.contentView);
    }];
}
-(void)tapOnPost
{
    NSLog(@"@%@",_itempost);
    if (_txtPost.text.length==0)
    {
        return;
    }
        NSString *noteId      = self.itempost.itemId;
        NSString *commentBody = self.txtPost.text;
        self.txtPost.text=@"";
        NSString *topicId     = self.itempost.userData.topic_id;
        
        BOOL emptyNoteId = [noteId isEqualToString:@""] || noteId == NULL;
        
        if (!emptyNoteId)
        {
            [[ThreadItemManager sharedInstance] addComment:commentBody
                                              toNoteWithId:noteId
                                             inTopicWithId:topicId];
        }
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.deleGate && [self.deleGate respondsToSelector:@selector(ChangeOffsetAccordingToEdting:forTextField:)])
    {
        [self.deleGate ChangeOffsetAccordingToEdting:self.itempost forTextField:textField];
    }
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
        return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (range.location == 0 && [string isEqualToString:@" "]) {
        return NO;
    }
    return YES;
}
@end
