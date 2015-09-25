//
//  HIstoryCommentsCell.m
//  Knotable
//
//  Created by Dhruv on 3/24/15.
//
//

#import "HIstoryCommentsCell.h"
#import "DesignManager.h"
@implementation HIstoryCommentsCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    {
        self.contentView.backgroundColor=[UIColor clearColor];
        self.imgOfHistory=[[UIImageView alloc] initWithFrame:CGRectMake(60, 2,36 , 36)];
        self.imgOfHistory.image=[UIImage imageNamed:@"ic_history_pad"];
        [self.contentView addSubview:self.imgOfHistory];
        self.lbl_ShowAll=[[UILabel alloc]initWithFrame:CGRectMake(96, 9, 250, 21)];
        self.lbl_ShowAll.text=@"Load previous comments";
        self.lbl_ShowAll.font=[DesignManager knoteUsernameFont];
        self.lbl_ShowAll.textColor=[UIColor grayColor];
        [self.contentView addSubview:self.lbl_ShowAll];
    }
    return self;
}
@end
