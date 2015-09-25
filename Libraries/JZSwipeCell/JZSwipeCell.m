//
// JZSwipeCell.m
//
// Copyright (C) 2013 Jeremy Zedell
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is furnished
// to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "JZSwipeCell.h"

static CGFloat const kIconHorizontalPadding = 60;
static CGFloat const kDefaultIconSize = 40;
static CGFloat const kMaxBounceAmount = 8;

@interface JZSwipeCell()

@property (nonatomic, strong) UIPanGestureRecognizer *gesture;
@property (nonatomic, assign) CGFloat dragStart;
@property (nonatomic, assign) JZSwipeType currentSwipe;

- (void)configureCell;
- (SwipeCellColorSet*)defaultColorSet;
- (void)gestureHappened:(UIPanGestureRecognizer *)sender;
- (BOOL)isRightSwipeType:(JZSwipeType)type;
- (BOOL)isLeftSwipeType:(JZSwipeType)type;
- (void)runSwipeAnimationForType:(JZSwipeType)type;
- (void)runBounceAnimationFromPoint:(CGPoint)point;
@end

@implementation JZSwipeCell

- (id)init
{
	self = [super init];
    if (self) {
		[self configureCell];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		[self configureCell];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self ) {
		[self configureCell];
	}
	
	return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self configureCell];
}

- (void)prepareForReuse
{
	[super prepareForReuse];
	self.contentBgView.center = CGPointMake(self.contentBgView.frame.size.width / 2, self.contentBgView.center.y);
	self.currentSwipe = JZSwipeTypeNone;
}

#pragma mark - Public methods

- (void)triggerSwipeWithType:(JZSwipeType)type
{
	switch (type)
	{
		case JZSwipeTypeShortRight:
			self.backgroundView.backgroundColor = self.colorSet.shortRightSwipeColor;
			self.icon.image = self.imageSet.shortRightSwipeImage;
			break;
		case JZSwipeTypeLongRight:
			self.backgroundView.backgroundColor = self.colorSet.longRightSwipeColor;
			self.icon.image = self.imageSet.longRightSwipeImage;
			break;
		case JZSwipeTypeShortLeft:
			self.backgroundView.backgroundColor = self.colorSet.shortLeftSwipeColor;
			self.icon.image = self.imageSet.shortLeftSwipeImage;
			break;
		case JZSwipeTypeLongLeft:
			self.backgroundView.backgroundColor = self.colorSet.longLeftSwipeColor;
			self.icon.image = self.imageSet.longLeftSwipeImage;
			break;
		case JZSwipeTypeNone:
		default:
			return;
	}
	
	[self runSwipeAnimationForType:type];
}

#pragma mark - Private methods

- (void)configureCell
{
	self.selectionStyle = UITableViewCellSelectionStyleNone;
    if (!self.indicateLabel) {
        self.indicateLabel = [[UILabel alloc] initWithFrame:self.bounds];
        [self addSubview:self.indicateLabel];
        self.indicateLabel.font = [UIFont boldSystemFontOfSize:22];
        self.indicateLabel.hidden = YES;
    }
    [self bringSubviewToFront:self.indicateLabel];
		
	if (!self.icon)
	{
		self.icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kDefaultIconSize, kDefaultIconSize)];
		[self addSubview:self.icon];
	}
	
	if (!self.contentBgView)
	{
		self.contentBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.contentBgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		[self addSubview:self.contentBgView];
	}
    
    if (!self.contentBgView.backgroundColor)
		self.contentBgView.backgroundColor = [UIColor whiteColor];
    
	self.gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestureHappened:)];
	self.gesture.delegate = self;
	[self.contentBgView addGestureRecognizer:self.gesture];
	
	self.shortSwipeLength = self.contentBgView.frame.size.width * 0.66;
	
	self.colorSet = [self defaultColorSet];
	self.defaultBackgroundColor = [UIColor greenColor];
	
	if (!self.backgroundView)
	{
		self.backgroundView = [[UIView alloc] init];
		self.backgroundView.backgroundColor = self.defaultBackgroundColor;
	}
}

- (SwipeCellColorSet*)defaultColorSet
{
	return SwipeCellColorSetMake([UIColor colorWithRed:0 green:194/255.0 blue:18/255.0 alpha:1],
								 [UIColor colorWithRed:222/255.0 green:84/255.0 blue:0 alpha:1],
								 [UIColor colorWithRed:231/255.0 green:196/255.0 blue:0 alpha:1],
								 [UIColor redColor]);
    
//	return SwipeCellColorSetMake([UIColor colorWithRed:0 green:194/255.0 blue:18/255.0 alpha:1],
//								 [UIColor colorWithRed:222/255.0 green:84/255.0 blue:0 alpha:1],
//								 [UIColor colorWithRed:231/255.0 green:196/255.0 blue:0 alpha:1],
//								 [UIColor colorWithRed:200/255.0 green:147/255.0 blue:47/255.0 alpha:1]);
}

- (void)gestureHappened:(UIPanGestureRecognizer *)sender
{
	CGPoint translatedPoint = [sender translationInView:self];
	switch (sender.state)
	{
		case UIGestureRecognizerStatePossible:
			
			break;
		case UIGestureRecognizerStateBegan:
			self.dragStart = sender.view.center.x;
			break;
		case UIGestureRecognizerStateChanged:
        {
			CGFloat diff = translatedPoint.x;
			
			JZSwipeType originalSwipe = self.currentSwipe;
			
			if (diff > 0)
			{
                self.currentSwipe = JZSwipeNLeft;
                return;
                self.contentBgView.center = CGPointMake(self.dragStart + translatedPoint.x, self.contentBgView.center.y);
				// in short right swipe area
				if (diff <= self.icon.frame.size.width + (kIconHorizontalPadding * 2))
				{
					// fade range
					self.icon.image = self.imageSet.shortRightSwipeImage;
					self.backgroundView.backgroundColor = self.defaultBackgroundColor;
					self.icon.center = CGPointMake((self.icon.frame.size.width / 2) + kIconHorizontalPadding, self.contentBgView.frame.size.height / 2);
					self.icon.alpha = diff / (self.icon.frame.size.width + (kIconHorizontalPadding * 3));
					self.currentSwipe = JZSwipeTypeNone;
				}
				else
				{
					// hang icon to side of content view
					if (diff < self.shortSwipeLength)
					{
						self.icon.image = self.imageSet.shortRightSwipeImage;
						self.backgroundView.backgroundColor = self.colorSet.shortRightSwipeColor;
						self.currentSwipe = JZSwipeTypeShortRight;
					}
					else
					{
						self.icon.image = self.imageSet.longRightSwipeImage;
						self.backgroundView.backgroundColor = self.colorSet.longRightSwipeColor;
						self.currentSwipe = JZSwipeTypeLongRight;
					}
					
					self.icon.center = CGPointMake(self.contentBgView.frame.origin.x - ((self.icon.frame.size.width / 2) + kIconHorizontalPadding), self.contentBgView.frame.size.height / 2);
					self.icon.alpha = 1;
				}
			}
			else if (diff < 0)
			{
                self.contentBgView.center = CGPointMake(self.dragStart + translatedPoint.x, self.contentBgView.center.y);
                self.indicateLabel.hidden = NO;
                self.indicateLabel.center = CGPointMake(self.dragStart + translatedPoint.x+self.contentBgView.bounds.size.width, self.contentBgView.center.y);
				// in short left swipe area
				if (diff >= -(self.icon.frame.size.width + (kIconHorizontalPadding * 2)))
				{
                    self.indicateLabel.textColor = [UIColor whiteColor];
                    self.indicateLabel.text = @"Archive";

					// fade range
					self.icon.image = self.imageSet.shortLeftSwipeImage;
					self.backgroundView.backgroundColor = self.defaultBackgroundColor;
					self.icon.center = CGPointMake(self.frame.size.width - ((self.icon.frame.size.width / 2) + kIconHorizontalPadding), self.contentBgView.frame.size.height / 2);
					self.icon.alpha = fabs(diff / (self.icon.frame.size.width + (kIconHorizontalPadding * 3)));
					self.currentSwipe = JZSwipeTypeNone;
				}
				else
				{
                    self.indicateLabel.textColor = [UIColor whiteColor];
                    self.indicateLabel.text = @"Delete";
					// hang icon to side of content view
					if (diff > -self.shortSwipeLength)
					{
						self.icon.image = self.imageSet.shortLeftSwipeImage;
						self.backgroundView.backgroundColor = self.colorSet.shortLeftSwipeColor;
						self.currentSwipe = JZSwipeTypeShortLeft;
					}
					else
					{
						self.icon.image = self.imageSet.longLeftSwipeImage;
						self.backgroundView.backgroundColor = self.colorSet.longLeftSwipeColor;
						self.currentSwipe = JZSwipeTypeLongLeft;
					}
					
					self.icon.center = CGPointMake((self.contentBgView.frame.origin.x + self.contentBgView.frame.size.width) + ((self.icon.frame.size.width / 2) + kIconHorizontalPadding), self.contentBgView.frame.size.height / 2);
					self.icon.alpha = 1;
				}
			}
			
			if (originalSwipe != self.currentSwipe)
			{
				if ([self.delegate respondsToSelector:@selector(swipeCell:swipeTypeChangedFrom:to:)])
					[self.delegate swipeCell:self swipeTypeChangedFrom:originalSwipe to:self.currentSwipe];
			}
        }
			break;
		case UIGestureRecognizerStateEnded:
        {
            [UIView animateWithDuration:2 animations:^{
                self.indicateLabel.hidden = YES;
            }];
			if (self.currentSwipe != JZSwipeTypeNone) {
				[self runSwipeAnimationForType:self.currentSwipe];
            } else if (self.currentSwipe != JZSwipeNLeft){
				[self runBounceAnimationFromPoint:translatedPoint];
            }
        }
			break;
		case UIGestureRecognizerStateCancelled:
			
			break;
		case UIGestureRecognizerStateFailed:
			
			break;
	}
}

- (void)runSwipeAnimationForType:(JZSwipeType)type
{
	CGFloat newIconCenterX = 0;
	CGFloat newViewCenterX = 0;
	CGFloat iconAlpha = 1;

	if ([self isRightSwipeType:type])
	{
		self.icon.center = CGPointMake(self.contentBgView.center.x - ((self.contentBgView.frame.size.width / 2) + (self.icon.frame.size.width / 2) + kIconHorizontalPadding), self.contentBgView.frame.size.height / 2);
		newIconCenterX = self.frame.size.width + (self.icon.frame.size.width / 2) + kIconHorizontalPadding;
		newViewCenterX = newIconCenterX + (self.contentBgView.frame.size.width / 2) + (self.icon.frame.size.width / 2) + kIconHorizontalPadding;
	}
	else if ([self isLeftSwipeType:type])
	{
		self.icon.center = CGPointMake(self.contentBgView.center.x + (self.contentBgView.frame.size.width / 2) + (self.icon.frame.size.width / 2) + kIconHorizontalPadding, self.contentBgView.frame.size.height / 2);
		newIconCenterX = -((self.icon.frame.size.width / 2) + kIconHorizontalPadding);
		newViewCenterX = newIconCenterX - ((self.contentBgView.frame.size.width / 2) + (self.icon.frame.size.width / 2) + kIconHorizontalPadding);
	}
	else
	{
		// non-bouncing swipe type none (unused)
		newIconCenterX = self.icon.center.x;
		newViewCenterX = self.dragStart;
		iconAlpha = 0;
	}
	
	[UIView animateWithDuration:0.25 delay:0
						options:UIViewAnimationOptionCurveLinear
					 animations:^{
						 self.icon.center = CGPointMake(newIconCenterX, self.contentBgView.frame.size.height / 2);
						 self.contentBgView.center = CGPointMake(newViewCenterX, self.contentBgView.center.y);
						 self.icon.alpha = iconAlpha;
					 } completion:^(BOOL finished) {
						 if ([self.delegate respondsToSelector:@selector(swipeCell:triggeredSwipeWithType:)])
							 [self.delegate swipeCell:self triggeredSwipeWithType:type];
						 self.dragStart = CGFLOAT_MIN;
					 }];
}

- (void)runBounceAnimationFromPoint:(CGPoint)point
{
	CGFloat diff = point.x;
	CGFloat pct = diff / (self.icon.frame.size.width + (kIconHorizontalPadding * 2));
	CGFloat bouncePoint = pct * kMaxBounceAmount;
	CGFloat bounceTime1 = 0.25;
	CGFloat bounceTime2 = 0.15;
	
	[UIView animateWithDuration:bounceTime1
					 animations:^{
						 self.contentBgView.center = CGPointMake(self.dragStart - bouncePoint, self.contentBgView.center.y);
						 self.icon.alpha = 0;
					 } completion:^(BOOL finished) {
						 [UIView animateWithDuration:bounceTime2
										  animations:^{
											  self.contentBgView.center = CGPointMake(self.dragStart, self.contentBgView.center.y);
										  } completion:^(BOOL finished) {
											  
										  }];
					 }];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
		return YES;
	
	CGPoint translation = [(UIPanGestureRecognizer*)gestureRecognizer translationInView:self];
    return fabs(translation.y) < fabs(translation.x);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return self.gesture.state == UIGestureRecognizerStatePossible;
}

#pragma mark - Helper methods

- (BOOL)isRightSwipeType:(JZSwipeType)type
{
	return type == JZSwipeTypeShortRight || type == JZSwipeTypeLongRight;
}

- (BOOL)isLeftSwipeType:(JZSwipeType)type
{
	return type == JZSwipeTypeShortLeft || type == JZSwipeTypeLongLeft;
}

@end

@implementation SwipeCellImageSet
@end

@implementation SwipeCellColorSet
@end
