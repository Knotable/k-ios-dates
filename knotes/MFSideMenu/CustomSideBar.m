//
//  CustomSideBar.m
//  Knotable
//
//  Created by Dhruv on 5/6/15.
//
//

#import "CustomSideBar.h"
@interface CustomSideBar()
@property (nonatomic)CGFloat contentWidth;
@property (nonatomic)CGFloat mainWidth;
@property (nonatomic)CGFloat mainHeight;

@end
@implementation CustomSideBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initSideBarisShowingFromRight:(BOOL)isShowingFromRight withDelegate:(id)delegate
{
    
    if (self = [super init])
    {
        _mainWidth=[UIScreen mainScreen].bounds.size.width;
        _mainHeight=[UIScreen mainScreen].bounds.size.height;
        _contentWidth=250;
        self.delegate=delegate;
        self.isShowingFromRight=isShowingFromRight;
        self.frame=[UIScreen mainScreen].bounds;
        //[self addSubview:self.ContainerInSidebar];
        self.backgroundColor=[UIColor colorWithWhite:0.000 alpha:0.530];
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
        tap.delegate=self;
        [self addGestureRecognizer:tap];
        self.userInteractionEnabled=YES;
    }
    return self;
}
-(void)ShowSideBarWithAnimationWithController:(UIViewController *)control animated:(BOOL)animated
{
    self.isOpen=YES;
    if ([self.delegate respondsToSelector:@selector(sidebarwillShowOnScreenAnimated:)])
    {
        [self.delegate sidebarwillShowOnScreenAnimated:YES];
    }
    
    if (control)
    {
        self.ContainerInSidebar=control;
        self.ContainerInSidebar.view.frame=CGRectMake(_isShowingFromRight?_mainWidth:-_contentWidth, 0, _contentWidth, _mainHeight);
        
        UIViewController *controller=[self getMainViewController];
        self.layer.backgroundColor = [UIColor clearColor].CGColor;
        [self addSubview:self.ContainerInSidebar.view];
        [controller.view addSubview:self];
    }
    
    [self animationShow:animated];
}
-(void)animationShow:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    CGRect frameChange=[(KnotableNavigationController *)[(UIViewController *)self.delegate navigationController] navBorder].frame;
    frameChange.origin.y=63.5;
    frameChange.size.height=0.5;
    [(KnotableNavigationController *)[(UIViewController *)self.delegate navigationController] navBorder].frame=frameChange;
    self.isOpen=YES;
        [UIView animateWithDuration:animated?0.25f:0.0f
                          delay:0
                        options:kNilOptions
                     animations:^{
                         self.ContainerInSidebar.view.frame=CGRectMake(_isShowingFromRight?_mainWidth-_contentWidth:0, 0, _contentWidth, _mainHeight);
                         self.layer.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.530].CGColor;
                     }
                     completion:^(BOOL finished) {
                     }];
}
-(void)animationHide:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    CGRect frameChange=[(KnotableNavigationController *)[(UIViewController *)self.delegate navigationController] navBorder].frame;
    frameChange.origin.y=43.5;
    frameChange.size.height=0.5;
    [(KnotableNavigationController *)[(UIViewController *)self.delegate navigationController] navBorder].frame=frameChange;
    self.isOpen=NO;
    [UIView animateWithDuration:animated?0.25f:0.0f
                          delay:0
                        options:kNilOptions
                     animations:^{
                         self.ContainerInSidebar.view.frame=CGRectMake(_isShowingFromRight?_mainWidth:-_contentWidth, 0, _contentWidth, _mainHeight);
                         self.backgroundColor=[UIColor clearColor];
                         self.layer.backgroundColor = [UIColor clearColor].CGColor;
                     }
                     completion:^(BOOL finished) {
                         [self.ContainerInSidebar.view removeFromSuperview];
                         [self removeFromSuperview];
                         if ([self.delegate respondsToSelector:@selector(sidebardidDismissFromScreenAnimated:)])
                         {
                             [self.delegate sidebardidDismissFromScreenAnimated:YES];
                         }
                     }];
}
-(void)handleTap:(UITapGestureRecognizer *)gesture
{
    [self hideSideBarWithAnimation:YES];
}
-(void)hideSideBarWithAnimation:(BOOL)animated
{
    self.layer.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.530].CGColor;
    [self animationHide:animated];
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:_ContainerInSidebar.view])
    {
        return NO;
    }
    else
    {
        return YES;
    }
}
-(UIViewController *)getMainViewController
{
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;    
    return delegate.navController;
}
- (void)handlePanning:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIViewController *controller;
   
    switch ([gestureRecognizer state])
    {
        case UIGestureRecognizerStateBegan:
            if ([self.delegate respondsToSelector:@selector(sidebarwillShowOnScreenAnimated:)])
            {
                [self.delegate sidebarwillShowOnScreenAnimated:YES];
            }
            controller=[self getMainViewController];
            [controller.view addSubview:self];
            self.backgroundColor=[UIColor colorWithWhite:0.000 alpha:0.530];
            self.ContainerInSidebar.view.frame=CGRectMake(_isShowingFromRight?_mainWidth:-_contentWidth, 0, _contentWidth, _mainHeight);
             [self addSubview:self.ContainerInSidebar.view];
            [self startDragging:gestureRecognizer];
            break;
         case UIGestureRecognizerStateChanged:
            [self startDragging:gestureRecognizer];
            break;
        case UIGestureRecognizerStateEnded:
            
            if (_isShowingFromRight?self.ContainerInSidebar.view.frame.origin.x<=70+(_contentWidth/2):self.ContainerInSidebar.view.frame.origin.x>=(-_contentWidth/2))
            {
                [self animationShow:YES];
            }
            else
            {
                [self animationHide:YES];
            }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            
            break;
            
        default:
            break;
    }
}
- (void)startDragging:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint pointInSrc = [gestureRecognizer locationInView:gestureRecognizer.view];
    if (_isShowingFromRight?pointInSrc.x>=_mainWidth-_contentWidth:pointInSrc.x<=_contentWidth)
    {
       NSLog(@"%@",NSStringFromCGPoint(pointInSrc));
    CGRect frameToChange=self.ContainerInSidebar.view.frame;
    frameToChange.origin.x=_isShowingFromRight?pointInSrc.x:-_contentWidth+pointInSrc.x;
    self.ContainerInSidebar.view.frame=frameToChange;
            CGFloat a=_mainWidth-self.ContainerInSidebar.view.frame.origin.x;
        a=(a*0.53)/_contentWidth;
        if (a>0)
        {
            a=-a;
        }
         self.backgroundColor = [UIColor colorWithWhite:0.000 alpha:a];
    }
    
    /*****Shadow bug Dont erase****
     if (!_isShowingFromRight)
     {
     a=(_contentWidth*0.53)/a;
     }
     else
     {
     a=(a*0.53)/_contentWidth;
     }
     
     if (a<0)
     {
     a=-a;
     }
     NSLog(@"%f",a);
     
     [UIView animateWithDuration:0.0f
     delay:0
     options:kNilOptions
     animations:^{
     self.layer.backgroundColor = [UIColor colorWithWhite:0.000 alpha:a].CGColor;
     }
     completion:^(BOOL finished) {
     self.layer.backgroundColor = [UIColor colorWithWhite:0.000 alpha:a].CGColor;
     
     }];*/
   
}
@end
