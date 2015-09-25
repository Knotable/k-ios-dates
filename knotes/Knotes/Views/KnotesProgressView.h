//
//  KnotableProgressView.h
//  Knotable
//
//  Created by Mac on 18/11/14.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ProgressViewStyle)
{
    KnotableProgressViewStyleBlue = 1,
    KnotableProgressViewStyleWhite
};

@interface KnotableProgressView : UIView

@property (nonatomic , assign) CGFloat positionFromCentre;
@property (nonatomic , assign) BOOL isAnimating;
@property (nonatomic , assign) float previousProgress;
@property (nonatomic , assign) ProgressViewStyle progressViewStyle;
@property(nonatomic,retain) BWStatusBarOverlay *statusBarLoaderView;

- (void) startAnimating;
- (void) stopAnimating;

- (void) startProgressWithTitle:(NSString*)progressTitle;
- (void) stopProgressBar;

-(void) startStatusBarLoading;
-(void) finishStatusBarLoading;


@end
