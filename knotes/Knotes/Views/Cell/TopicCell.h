//
//  TopicCell.h
//  Knotable
//
//  Created by Martin Ceperley on 12/16/13.
//
//

#import <UIKit/UIKit.h>
#import "KnotesCellProtocal.h"
#import "CircleView.h"

@class TopicInfo;
@class TopicsEntity;
@interface TopicCell : UITableViewCell<KnotableCellProtocal>

@property (nonatomic, strong) CircleView *activityCircle;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (assign, nonatomic) BOOL editor;
@property (nonatomic, strong) TopicInfo * tInfo;
@property (nonatomic, strong) TopicsEntity *entity;

@end
