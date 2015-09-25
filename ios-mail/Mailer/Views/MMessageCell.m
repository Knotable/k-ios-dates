//
//  MMessageCell.m
//  Mailer
//
//  Created by Martin Ceperley on 10/1/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "MMessageCell.h"

@implementation MMessageCell

@synthesize fromLabel;
@synthesize subjectLabel;
@synthesize dateLabel;
@synthesize textLabel;
@synthesize characterCountLabel;
@synthesize message;

-(void)awakeFromNib
{
    self.threadCount.backgroundColor = [UIColor clearColor];
//    self.threadCount.layer.cornerRadius = 2;
//    self.threadCount.layer.borderColor = [UIColor grayColor].CGColor;
//    self.threadCount.layer.borderWidth = 1;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    [self.fromLabel sizeToFit];
    CGFloat w = 0;
    w = [self.fromLabel textRectForBounds:CGRectMake(0, 0, 200, 16) limitedToNumberOfLines:0].size.width;
    [self.fromLabel setFrame:CGRectMake(25, 8, w, 16)];
    [self.threadCount setFrame:CGRectMake(25+w+4, 8, 22, 16)];
}

@end
