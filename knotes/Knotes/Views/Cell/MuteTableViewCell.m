//
//  MuteTableViewCell.m
//  Knotable
//
//  Created by backup on 8/27/14.
//
//

#import "MuteTableViewCell.h"

#import "TopicsEntity.h"

#import "DataManager.h"
#import "AppDelegate.h"

#import "UIImage+Knotes.h"
#import "UIButton+Extensions.h"

@implementation MuteTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImage *img = [UIImage imageNamed:@"speakerOff"];
        UIImage *imgSelected = [UIImage imageNamed:@"speakerOn"];
        self.unMuteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.unMuteBtn setImage:img forState:UIControlStateNormal];
        [self.unMuteBtn setImage:imgSelected forState:UIControlStateHighlighted];
        [self.unMuteBtn addTarget:self action:@selector(unMuteTopic) forControlEvents:UIControlEventTouchUpInside];
        self.backgroundColor = MUTE_BACKGROUND;
    }
    return self;
}

-(void)setMessage:(MessageEntity *)message withAnimate:(BOOL)animal
{
    _message = message;
    
    TopicsEntity *topic = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:message.topic_id];
    
    if (topic)
    {
        self.textLabel.text = topic.topic;
        if ([topic.isMute boolValue])
        {
            if (!message.muted)
            {
                message.muted = YES;
                
                [glbAppdel.managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:HOT_KNOTES_DOWNLOADED_NOTIFICATION object:nil userInfo:@{kHotOrMute:@(2)}];
                }];
            }
        }
    }
    else
    {
        self.textLabel.text = message.topic_id;
    }
    
    self.detailTextLabel.text = message.body;
    self.unMuteBtn.transform = CGAffineTransformMakeScale(1, 1);
    self.unMuteBtn.hidden = NO;
    [self.unMuteBtn setFrame:CGRectMake(0, 0, 38,38)];
    [self.unMuteBtn  setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -40, -10, -40)];
    self.accessoryView = self.unMuteBtn;

    if (animal) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.unMuteBtn.transform = CGAffineTransformMakeScale(0.6, 0.6);
            self.unMuteBtn.alpha = 0.2;
            [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.unMuteBtn.transform = CGAffineTransformMakeScale(1, 1);
                self.unMuteBtn.alpha = 1;
            } completion:^(BOOL finished) {
                if (finished) {
                    [UIView animateKeyframesWithDuration:.4 delay:0 options:0 animations:^{
                        [UIView addKeyframeWithRelativeStartTime:.2 relativeDuration:.2 animations:^{
                            self.unMuteBtn.transform = CGAffineTransformScale(CGAffineTransformMakeScale(1, 1), 1, 1);
                        }];
                    } completion:^(BOOL finished){
                    }];
                }
            }];
        });
    }
}
- (void)unMuteTopic
{
    [self.unMuteBtn animatedDismiss];
    [[DataManager sharedInstance] setMessage:self.message withMute:NO];
    [glbAppdel.managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:MUTE_KNOTES_DOWNLOADED_NOTIFICATION object:self];
        });
    }];
    
    return;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"Unmute this pad ?"
                                                   delegate:nil
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK",nil];
    alert.delegate = self;
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [[DataManager sharedInstance] setMessage:self.message withMute:NO];
        [glbAppdel.managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:HOT_KNOTES_DOWNLOADED_NOTIFICATION object:nil userInfo:@{kHotOrMute:@(2)}];
        }];
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
