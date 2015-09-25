//
//  SHStripeMenuViewController.m
//  SHStripeMenu
//
//  Created by Narasimharaj on 26/04/13.
//  Copyright (c) 2013 SimHa. All rights reserved.
//

#import "SHStripeMenuViewController.h"
#import "SHMenuItem.h"
#import "UIApplication+AppDimensions.h"
#import "CUtil.h"
#import <QuartzCore/QuartzCore.h>
#import "FWTPopoverView.h"
#import "SHMenuCell.h"
#import "DesignManager.h"

#define EXTRA_WIDTH 10
#define EXTRA_HEIGHT 10

@interface SHStripeMenuViewController () <UIGestureRecognizerDelegate, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView		*menuTableView;
@property (strong, nonatomic) UILabel *indicateLabel;
@property (strong, nonatomic) UIImageView *backgroundView;
@property (nonatomic, retain) FWTPopoverView *popoverView;

@end

@implementation SHStripeMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
	if (self)
	{
        self.menuWidth = 280;//default is 280 pix
        self.menuType = SHStripeMenuLeft;
		// Custom initialization
	}
	return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	// ignore the touch
	if (touch.view.superview)
		if ([touch.view.superview isKindOfClass:[UITableViewCell class]])
			return NO;
    
	return YES;	// handle the touch
}


- (void)viewDidLoad
{
	[super viewDidLoad];
    self.backgroundView = [DesignManager appBackgroundView];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.backgroundView];
    [self.view sendSubviewToBack:self.backgroundView];
    //self.view.backgroundColor = [DesignManager appBackgroundColor];
    
	// Do any additional setup after loading the view from its nib.
	[self setupMenuItems];
	[self setTableView];
    
    
}
- (void)setTableView
{
    
    CGFloat oringX = [UIApplication currentSize].width - self.menuWidth;
    if (self.menuType == SHStripeMenuLeft) {
        oringX = 0;
    }
    
	[_menuTableView setFrame:CGRectMake(oringX,
                                        0,
                                        self.menuWidth,
                                        [self getViewHeight])];														// + 88
    [self.backgroundView setFrame:CGRectMake(oringX,
                                             0,
                                             self.menuWidth,
                                             [self getViewHeight])];
    
    /*
    CGFloat height = [self getTableHeight];
    [_menuTableView setFrame:CGRectMake(oringX,
                                        0,
                                        self.menuWidth,
                                        height)];														// + 88
    [self.backgroundView setFrame:CGRectMake(oringX,
                                             0,
                                             self.menuWidth + EXTRA_WIDTH,
                                             height)];
     */
    
	[self.menuTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
	_menuTableView.backgroundColor	= [UIColor clearColor];
	_menuTableView.opaque			= NO;
	_menuTableView.backgroundView	= nil;
	_menuTableView.alpha			= 1;
    
}

- (void)setupMenuItems
{
	[self.menuTableView reloadData];
    
    
    // reset height
    CGFloat oringX = [UIApplication currentSize].width - self.menuWidth;
    if (self.menuType == SHStripeMenuLeft) {
        oringX = 0;
    }
    
    /*
    CGFloat height = [self getTableHeight];
    [_menuTableView setFrame:CGRectMake(oringX,
                                        0,
                                        self.menuWidth,
                                        height)];														// + 88
    [self.backgroundView setFrame:CGRectMake(oringX,
                                             0,
                                             self.menuWidth + EXTRA_WIDTH,
                                             height)];
     */
    
    [_menuTableView setFrame:CGRectMake(oringX,
                                        0,
                                        self.menuWidth,
                                        [self getViewHeight])];														// + 88
    [self.backgroundView setFrame:CGRectMake(oringX,
                                             0,
                                             self.menuWidth,
                                             [self getViewHeight])];

}
-(void)setMenuItems:(NSMutableArray *)menuItems
{
    _menuItems = menuItems;

    self.menuWidth = 70;
    
    CGFloat oringX = [UIApplication currentSize].width - self.menuWidth;
    if (self.menuType == SHStripeMenuLeft) {
        oringX = 0;
    }
    //CGRect rect = _titleView.frame;
    //rect.origin.x = oringX;
    //_titleView.frame = rect;
    /*
	[_menuTableView setFrame:CGRectMake(oringX,
                                        0,
                                        self.menuWidth,
                                        [self getTableHeight])];
    
    [self.backgroundView setFrame:CGRectMake(oringX,
                                             0,
                                             self.menuWidth + EXTRA_WIDTH,
                                             [self getTableHeight])];
     */
    
    [_menuTableView setFrame:CGRectMake(oringX,
                                        0,
                                        self.menuWidth,
                                        [self getViewHeight])];														// + 88
    [self.backgroundView setFrame:CGRectMake(oringX,
                                             0,
                                             self.menuWidth,
                                             [self getViewHeight])];
    
}

- (CGFloat)getTableHeight
{
    CGFloat height = 0;
    
    //finding the number of cells in your table view by looping through its sections
    for (NSInteger section = 0; section < [self numberOfSectionsInTableView:self.menuTableView]; section++)
    {
        //numberOfCells += [self tableView:self.menuTableView numberOfRowsInSection:section];
        for (int j = 0; j < [self tableView:self.menuTableView numberOfRowsInSection:section]; j++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:section];
            height += [self tableView:self.menuTableView heightForRowAtIndexPath:indexPath];
        }
        height += [self tableView:self.menuTableView heightForHeaderInSection:section];
        //height += [self tableView:self.menuTableView heightForFooterInSection:section];
    }
    
    height += EXTRA_HEIGHT;
    
    // This must be corrected.
    // When I use self.view.frame.height, then outside's self.view.frame is not working correctly!?
    if (height > [UIApplication currentSize].height - 60)
        return [UIApplication currentSize].height - 60;
    
    
    return height;
}

- (CGFloat)getViewHeight
{
    // return [self getTableHeight];
    return [UIApplication currentSize].height + 20/* status bar */;
}


- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.menuItems count]+1;
    } else {
        return 3;
    }
	return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 10;
    }
    return 2;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *hView = [[UIView alloc] init];
    hView.backgroundColor = [UIColor clearColor];
    return hView;
}

- (UIView *)createEmptyView {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 300)] ;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:36]/*[UIFont boldSystemFontOfSize:36]*/;
    label.text = @"+";
    label.textColor = [UIColor grayColor];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}


- (UITableViewCell *)tableView:(UITableViewCell *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
	SHMenuCell *cellForMenu = [self.menuTableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cellForMenu == nil)
	{
       cellForMenu = [[SHMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cellForMenu.selectionStyle = UITableViewCellSelectionStyleNone;
    UIButton *view = cellForMenu.bg_btn;//[UIButton buttonWithType:UIButtonTypeCustom];
    view.userInteractionEnabled = YES;
    view.tag = indexPath.row;
    view.backgroundColor = [UIColor clearColor];

    if (indexPath.section == 0) {


        if ([indexPath row]<[self.menuItems count]) {
            if ([self.menuItems objectAtIndex:indexPath.row]) {
                SHMenuItem *item = [self.menuItems objectAtIndex:indexPath.row];
                [view setImage:item.image forState:UIControlStateNormal];

                UILongPressGestureRecognizer * longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureUpdated:)];
                longPressGesture.numberOfTouchesRequired = 1;
                longPressGesture.delegate = self;
                longPressGesture.cancelsTouchesInView = NO;
                [view addGestureRecognizer:longPressGesture];
                [view addTarget:self action:@selector(itemDown:) forControlEvents:UIControlEventTouchDown];

                [view addTarget:self action:@selector(itemClicked:) forControlEvents:UIControlEventTouchUpInside];
                UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureUpdated:)];
                doubleTapGesture.numberOfTapsRequired = 2;
                doubleTapGesture.numberOfTouchesRequired = 1;
                doubleTapGesture.cancelsTouchesInView = NO;
                
                [view addGestureRecognizer:doubleTapGesture];
            }
            [view setFrame:CGRectMake(15, 5, 40, 40)];
            view.layer.borderColor = [UIColor lightGrayColor].CGColor;
            view.layer.borderWidth = 2;
            view.layer.cornerRadius = 4;
            view.clipsToBounds = YES;
        } else {
            [view setImage:[UIImage imageNamed:@"icon_add"] forState:UIControlStateNormal];
            view.backgroundColor = [UIColor clearColor];
            [view addTarget:self action:nil forControlEvents:UIControlEventTouchDown];
            [view addTarget:self action:@selector(itemPressed:) forControlEvents:UIControlEventTouchUpInside];
            [view setFrame:CGRectMake(15, 5, 40, 40)];
            
            view.layer.borderColor = [UIColor clearColor].CGColor;
            view.layer.borderWidth = 0;
            view.layer.cornerRadius = 0;
        }
    } else if (indexPath.section == 1) {
        UIButton *view = cellForMenu.bg_btn;//[UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *img = nil;//
        if (indexPath.row == 0) {
            img = [UIImage imageNamed:@"social-facebook"];
        } else if (indexPath.row == 1) {
            img = [UIImage imageNamed:@"social-googleplus"];
        } else if (indexPath.row == 2) {
            img = [UIImage imageNamed:@"social-twitter"];
        }
        [view setFrame:CGRectMake(15, 5, 40, 40)];
        
        view.layer.borderColor = [UIColor clearColor].CGColor;
        view.layer.borderWidth = 0;
        view.layer.cornerRadius = 0;

        [view setImage:img forState:UIControlStateNormal];
        [view addTarget:self action:nil forControlEvents:UIControlEventTouchDown];
        
        [view addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
//        [view setBackgroundImage:img forState:UIControlStateNormal];
    }
    
	CGRect frame = cellForMenu.frame;
	frame.size.width	= self.menuWidth;
	cellForMenu.frame	= frame;
    cellForMenu.backgroundColor = [UIColor clearColor];
	return cellForMenu;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// hide panel
	[_delegate hideMenu];
	// send the selected menu item
}

#pragma mark - UIResponder

- (void)longPressGestureUpdated:(UILongPressGestureRecognizer *)longPressGesture
{
    [self.indicateLabel removeFromSuperview];
    switch (longPressGesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            UIButton *btn = (UIButton *)longPressGesture.view;
            [_delegate itemSelected:[self.menuItems objectAtIndex:btn.tag]];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            break;
        }
        default:
            break;
    }
    
}
-(void)dismissIndicated:(id)sender
{
    [UIView animateWithDuration :3.0 delay:3.0 options:UIViewAnimationOptionBeginFromCurrentState
                      animations:^{
                          self.indicateLabel.hidden = YES;
                      }
                   completion			:^(BOOL finished) {
                       if (finished)
                       {
                           [self.indicateLabel removeFromSuperview];
                       }
                   }
     ];
}

- (void)itemDown:(id)sender
{
    if (self.popoverView) {
        [self.popoverView dismissPopoverAnimated:NO];
        self.popoverView = nil;
    }
}
- (void)showTips:(id)sender
{
    CGPoint point = [sender convertPoint:[(UIView *)sender center] toView:self.view];
    
    UIButton *btn = (UIButton *)sender;
    if ([self.menuItems count] > btn.tag) {
        SHMenuItem *item = [self.menuItems objectAtIndex:btn.tag];
        if (!self.popoverView )
        {
            self.popoverView = [[FWTPopoverView alloc] initwithText:item.name] ;
            __block typeof(self) myself = self;
            self.popoverView.didDismissBlock = ^(FWTPopoverView *av){
                myself.popoverView = nil;
            };
            CGColorRef fillColor =[UIColor colorWithPatternImage:[UIImage imageNamed:@"topic-bg"]].CGColor;
            self.popoverView.backgroundHelper.fillColor = fillColor;
            [self.popoverView presentFromRect:CGRectMake(point.x, point.y, 1.0f, 1.0f)
                                       inView:self.view
                      permittedArrowDirection:FWTPopoverArrowDirectionRight
                                     animated:YES];
        }
        
        [self.view bringSubviewToFront:self.popoverView];
        [UIView animateWithDuration :2.0 delay:3.0 options:UIViewAnimationOptionBeginFromCurrentState
                       animations			:^{
                           [self.popoverView dismissPopoverAnimated:YES];
                       }
                          completion:^(BOOL finished) {
                              if (finished)
                              {
                              }
                          }
         ];
    }
}
- (void)itemClicked:(id)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(showTips:) withObject:sender afterDelay:0.3];
}
- (void)itemPressed:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if ([self.menuItems count] == btn.tag) {
         [_delegate itemSelected:nil];
    }
}
- (void)tapGestureUpdated:(UITapGestureRecognizer *)tapGesture
{
    if (self.popoverView) {
        [self.popoverView dismissPopoverAnimated:NO];
        self.popoverView = nil;
    }
    UIButton *btn = (UIButton *)tapGesture.view;
    [_delegate itemTaped:[self.menuItems objectAtIndex:btn.tag]];
}
@end
