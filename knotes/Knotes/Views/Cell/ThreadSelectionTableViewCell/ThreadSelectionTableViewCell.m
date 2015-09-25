//
//  ThreadSelectionTableViewCell.m
//  Knotable
//
//  Created by Agus Guerra on 6/2/15.
//
//

#import "ThreadSelectionTableViewCell.h"
#import "TopicInfo.h"

@interface ThreadSelectionTableViewCell()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end

@implementation ThreadSelectionTableViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)initWithModel:(TopicInfo *)topicInfo {
    if (topicInfo && topicInfo.entity.topic.length > 0) {
        self.titleLabel.text = topicInfo.entity.topic;
    } else {
        self.titleLabel.text = @"No topic";
    }
    
    if (self.selected) {
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)initWithTitle:(NSString *)topicTitle {
    self.titleLabel.text = topicTitle;
    
    if (self.selected) {
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

@end
