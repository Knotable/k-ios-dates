//
//  GMProgressView.h
//  RevealControllerProject
//
//  Created by backup on 13-11-11.
//
//

#import <UIKit/UIKit.h>
typedef enum _GMProgressType
{
    GMProgressLine,
    GMProgressCircle,
}GMProgressType;

@protocol GMProgressViewDelegate <NSObject>
@optional
- (void)playerDidFinishPlaying;
@end

@interface GMProgressView : UIView
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, assign) GMProgressType type;
@property (nonatomic, assign) CGFloat rediu;
@property (nonatomic, assign) BOOL showProgress;
@property (nonatomic) UIColor *backColor;
@property (nonatomic) UIColor *progressColor;
@property (assign, nonatomic) CGFloat lineWidth;
@property (assign, nonatomic) NSTimeInterval duration;
@property (assign, nonatomic) BOOL playOrPauseButtonIsPlaying;
@property (assign, nonatomic) id <GMProgressViewDelegate> delegate;
@property (assign, nonatomic) float progress;

- (id)initWithFrame:(CGRect)frame
          backColor:(UIColor *)backColor
      progressColor:(UIColor *)progressColor
          lineWidth:(CGFloat)lineWidth;
- (void)setTitleText:(NSString *)text;
@end
