//
//  KnoteBMBV.h
//  Knotable
//
//  Created by Lin on 31/7/14.
//
//

#import <UIKit/UIKit.h>

@interface KnoteLoadingView : UIView
{
    
}

@property (nonatomic, readonly) BOOL                isAnimating;
@property (nonatomic, assign) CGFloat               anglePer;
@property (nonatomic, strong) NSTimer               *timer;

@property (nonatomic, strong) IBOutlet  UIImageView *loadingImageView;

- (void)startAnimation;
- (void)stopAnimation;
- (void)dismiss;

@end
