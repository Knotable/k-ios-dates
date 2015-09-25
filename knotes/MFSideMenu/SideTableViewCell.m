//
//  SideTableViewCell.m
//  Knotable
//
//  Created by Dhruv on 4/22/15.
//
//

#import "SideTableViewCell.h"
#import "DesignManager.h"

@implementation SideTableViewCell

- (void)awakeFromNib {
    // Initialization code
   
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
     self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        self.imgMenu=[[UIImageView alloc]initWithFrame:CGRectMake(20, 11, 18, 18)];
        self.imgMenu.contentMode=UIViewContentModeScaleAspectFit;
        [self addSubview:self.imgMenu];
        self.lbl_text =[[UILabel alloc]initWithFrame:CGRectMake(60, 11, 150, 20)];
        self.lbl_text.font=[DesignManager knoteRealnameFont];
        [self addSubview:self.lbl_text];
    }
    return self;
}
@end
