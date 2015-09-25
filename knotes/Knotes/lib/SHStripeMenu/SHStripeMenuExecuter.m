//
//  SHStripeMenuExecuter.m
//  SHStripeMenu
//
//  Created by Narasimharaj on 08/05/13.
//  Copyright (c) 2013 SimHa. All rights reserved.
//

#import "SHStripeMenuExecuter.h"
#import "SHStripeMenuViewController.h"
#import "SHLineView.h"
#import "UIApplication+AppDimensions.h"
#import <QuartzCore/QuartzCore.h>
#define STRIPE_WIDTH 40

@interface SHStripeMenuExecuter () <UIGestureRecognizerDelegate, SHStripeMenuDelegate>

@property (nonatomic, strong) SHStripeMenuViewController					*stripeMenuViewController;
@property (nonatomic, strong) UIViewController *rootViewController;
@property (nonatomic, assign) BOOL											showingStripeMenu;

@end

@implementation SHStripeMenuExecuter
- (id)init
{
    self = [super init];
    if (self) {
        self.startY = 20;/*status bar */
        //self.startY = 0;
        self.menuType = SHStripeMenuLeft;//default is left
        self.menuItems = [[NSMutableArray alloc] initWithCapacity:3];
    }
    return self;
}
- (void)setupToParentView:(UIViewController *)rootViewController
{
	_rootViewController = rootViewController;
	[self setStripes];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)setStripes
{
	[self createMenuView];
	[self setStripesView];
}

- (void)setStripesView
{
    CGFloat orignX = 0;
    if (self.menuType == SHStripeMenuRight) {
        orignX = [UIApplication currentSize].width - STRIPE_WIDTH;
    }
    
	if (_lineView == nil)
	{
		_lineView = [[SHLineView alloc] initWithFrame:CGRectMake(orignX, self.startY, STRIPE_WIDTH, STRIPE_WIDTH)];
		[_rootViewController.view addSubview:_lineView];
		_lineView.backgroundColor = [UIColor clearColor];
	}
	else
		_lineView.frame = CGRectMake(orignX, self.startY, STRIPE_WIDTH, STRIPE_WIDTH);
	[_rootViewController.view bringSubviewToFront:_lineView];

	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(stripesTapped:)];
	[tapRecognizer setDelegate:self];
	[_lineView addGestureRecognizer:tapRecognizer];

	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(stripesSwiped:)];
	[panRecognizer setDelegate:self];
	[_lineView addGestureRecognizer:panRecognizer];
    
    
    if (_stripeMenuViewController.view) {
        UIPanGestureRecognizer *panRecg = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(stripesSwiped:)];
        [panRecg setDelegate:self];
        [_stripeMenuViewController.view addGestureRecognizer:panRecg];
    }
}

- (void)stripesTapped:(id)sender
{
    if (self.showingStripeMenu) {
        [self hideStripeMenu];
    } else {
        [self showStripeMenu];
    }
}

- (void)stripesSwiped:(UIPanGestureRecognizer *)panGesture
{
	// Show menu only when swiped to right
	CGPoint velocity = [(UIPanGestureRecognizer *) panGesture velocityInView:[panGesture view]];
    CGPoint point = [(UIPanGestureRecognizer *) panGesture locationInView:[[UIApplication sharedApplication] keyWindow]];
    UIView *childView = [self getMenuView];

    CGRect rect1 = childView.frame;
    CGFloat offset = 0;
   
    switch (panGesture.state)
    {
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            if (self.menuType != SHStripeMenuLeft) {
                velocity.x = - velocity.x;
            }
            if (velocity.x > 0)
                [self showStripeMenu];
            if (rect1.origin.x> self.stripeMenuViewController.menuWidth/2) {
                [self hideStripeMenu];
            } else {
                [self showStripeMenu];
            }
            break;
        }
        case UIGestureRecognizerStateBegan:
        {
            if (!self.showingStripeMenu) {
                offset = self.stripeMenuViewController.menuWidth;
                CGPoint p = [(UIPanGestureRecognizer *) panGesture translationInView:[panGesture view]];
                rect1.origin.x=p.x+offset-36;
            }
            childView.frame = rect1;
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGFloat maxOffsetX = [UIApplication currentSize].width - self.stripeMenuViewController.menuWidth+15;
            point.x = point.x<maxOffsetX?maxOffsetX:point.x;
            //_lineView.center = CGPointMake(point.x, _lineView.center.y);
            offset = ([UIApplication currentSize].width - self.stripeMenuViewController.menuWidth);
            rect1.origin.x=point.x-offset-15;
            childView.frame = rect1;
            break;
        }
        default:
            break;
    }
}

- (void)createMenuView
{
	if (_stripeMenuViewController == nil)
	{
		self.stripeMenuViewController			= [[SHStripeMenuViewController alloc] initWithNibName:@"SHStripeMenuViewController" bundle:nil];
        _stripeMenuViewController.menuItems = self.menuItems;
        self.stripeMenuViewController.menuType = self.menuType;
		self.stripeMenuViewController.delegate	= self;
		[_rootViewController.view addSubview:self.stripeMenuViewController.view];
		[_stripeMenuViewController didMoveToParentViewController:_rootViewController];
        CGFloat oringX = _rootViewController.view.frame.size.width;
        if (self.menuType == SHStripeMenuLeft) {
            oringX = -oringX;
        }
        //_stripeMenuViewController.view.frame = CGRectMake(oringX, self.startY + STRIPE_WIDTH, _rootViewController.view.frame.size.width, _rootViewController.view.frame.size.height);
        _stripeMenuViewController.view.frame = CGRectMake(oringX, self.startY, _rootViewController.view.frame.size.width, _rootViewController.view.frame.size.height);
	}
}

- (UIView *)getMenuView
{
	[self createMenuView];
	// set up view shadows
	UIView *view = self.stripeMenuViewController.view;

	return view;
}

- (void)hideStripeMenu
{
	[UIView animateWithDuration :SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
			animations			:^{
                CGFloat orignX = -_stripeMenuViewController.view.frame.size.width;
                if (self.menuType == SHStripeMenuRight) {
                    orignX = [UIApplication currentSize].width + _stripeMenuViewController.view.frame.size.width;
                }
                
                _stripeMenuViewController.view.frame = CGRectMake (orignX, self.startY, _stripeMenuViewController.view.frame.size.width, _stripeMenuViewController.view.frame.size.height);
                _stripeMenuViewController.view.layer.shadowOpacity = 0;
                _stripeMenuViewController.view.layer.shadowOffset = CGSizeZero;
                _stripeMenuViewController.view.layer.shadowRadius = 0;
		}
			completion			:^(BOOL finished) {
			if (finished)
			{
				self.showingStripeMenu = FALSE;
			}
		}
	];
	// show stripes
	[self setStripesView];
    
    /*
	__block CGRect lineViewFrame = _lineView.frame;

	[UIView animateWithDuration :SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
			animations			:^{
                if (self.menuType == SHStripeMenuLeft) {
                    lineViewFrame.origin.x = 0;
                } else {
                    lineViewFrame.origin.x = [UIApplication currentSize].width - STRIPE_WIDTH;
                }
			_lineView.frame = lineViewFrame;
		}
			completion			:^(BOOL finished) {
			if (finished)
			{}
		}
	];
     
     */
}

- (void)showStripeMenu
{
	UIView *childView = [self getMenuView];

	[_rootViewController.view bringSubviewToFront:childView];
	// show menu
	[UIView animateWithDuration :SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
			animations			:^{
                _stripeMenuViewController.view.frame = CGRectMake (0, self.startY, [UIApplication currentSize].width, [UIApplication currentSize].height);
                _stripeMenuViewController.view.layer.shadowOpacity = 5;
                _stripeMenuViewController.view.layer.shadowOffset = CGSizeMake(3, 3);
                _stripeMenuViewController.view.layer.shadowRadius = 5;
		}
			completion			:^(BOOL finished) {
			if (finished)
			{
				self.showingStripeMenu = TRUE;
			}
		}
	];
	// hide stripes
	[self setStripesView];
    
    /*
    __block	CGRect lineViewFrame = _lineView.frame;

	[UIView animateWithDuration :SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
			animations			:^{
                if (self.menuType == SHStripeMenuLeft) {
                    lineViewFrame.origin.x = -STRIPE_WIDTH;
                } else {
                    lineViewFrame.origin.x = [UIApplication currentSize].width - self.stripeMenuViewController.menuWidth+15;
                }
                _lineView.frame = lineViewFrame;
		}
			completion			:^(BOOL finished) {
			if (finished)
			{}
		}
	];
     */
}

- (void)hideMenu
{
	[self hideStripeMenu];
}

- (void)itemSelected:(SHMenuItem *)item
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(stripeMenuItemSelected:)]) {
        [self.delegate stripeMenuItemSelected:item.email];
    }
}
- (void)itemTaped:(SHMenuItem *)item
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(stripeMenuItemTaped:)]) {
        [self.delegate stripeMenuItemTaped:item.name];
    }
}
- (void)didRotate:(NSNotification *)notification
{
	if (!self.showingStripeMenu)
		[self setStripesView];
	[_stripeMenuViewController setTableView];
}
- (void)refreshView
{
    _stripeMenuViewController.menuItems = self.menuItems;
    [_stripeMenuViewController setupMenuItems];
    
    /*
    __block	CGRect lineViewFrame = _lineView.frame;
    
	[UIView animateWithDuration :SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                   animations			:^{
                       if (self.menuType == SHStripeMenuLeft) {
                           lineViewFrame.origin.x = -STRIPE_WIDTH;
                       } else {
                           lineViewFrame.origin.x = [UIApplication currentSize].width - self.stripeMenuViewController.menuWidth + 15;
                       }
                       _lineView.frame = lineViewFrame;
                   }
                   completion			:^(BOOL finished) {
                       if (finished)
                       {}
                   }
     ];
     */
}
@end
