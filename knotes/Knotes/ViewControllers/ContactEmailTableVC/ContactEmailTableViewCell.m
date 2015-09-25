//
//  ContactEmailTableViewCell.m
//  Knotable
//
//  Created by Emiliano Barcia Lizarazu on 14/1/15.
//
//

#import "ContactEmailTableViewCell.h"

@implementation ContactEmailTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(NSString *)description{
    return [[self.descriptionLabel.text stringByAppendingString:@": "] stringByAppendingString:self.emailLabel.text];
}

-(void)initWitDescription:(NSString *) description andMail:(NSString *)mail{
    self.descriptionLabel.text = description;
    self.descriptionLabel.textColor = self.tintColor;
    self.emailLabel.text = mail;
}

@end
