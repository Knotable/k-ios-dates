//
//  CEditVoteCell.m
//  RevealControllerProject
//
//  Created by backup on 13-11-8.
//
//

#import "CEditVoteCell.h"

#import "CUtil.h"
#import "DesignManager.h"

@interface CEditVoteCell()<UITextFieldDelegate>

@property (nonatomic)           BOOL  isAddable;
@property (nonatomic, assign)   BOOL  isChecked;
@property (nonatomic, strong)   UIView *grayView;
@property (nonatomic, strong)   UILabel *progressLabel;
@property (nonatomic, strong)   CEditVoteInfo *info;

@end

@implementation CEditVoteCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.checkedImage = [UIImage imageNamed: @"check_btn"];
        self.uncheckedImage = [UIImage imageNamed: @"uncheck_btn"];
        self.checkedImage1 = [UIImage imageNamed: @"icon_check"];
        self.uncheckedImage1 = [UIImage imageNamed: @"icon_uncheck"];
        
        self.tfVote = [[UITextField alloc] initWithFrame:CGRectZero];
        
        _tfVote.delegate = self;
        _tfVote.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _tfVote.textColor = [DesignManager knoteBodyTextColor];
        _tfVote.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
        _tfVote.borderStyle = UITextBorderStyleNone;
        _tfVote.adjustsFontSizeToFitWidth = YES;
        _tfVote.textAlignment = NSTextAlignmentLeft;
        _tfVote.clearButtonMode = UITextFieldViewModeNever;
        _tfVote.clearsOnBeginEditing = YES;
        _tfVote.keyboardType = UIKeyboardTypeASCIICapable;
        _tfVote.enabled = NO;
        
        self.checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_checkBtn addTarget:self action:@selector(onCheckChanged:) forControlEvents:UIControlEventTouchUpInside];
        
        self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addButton setTitle:@"X" forState:UIControlStateNormal];
        [_addButton addTarget:self action:@selector(onAddItem:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:_tfVote];
        [self addSubview:_addButton];
        [self addSubview:_checkBtn];
        
        self.progressLabel = [[UILabel alloc] init];
        self.progressLabel.textAlignment = NSTextAlignmentRight;
        self.progressLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
        
        [self addSubview:self.progressLabel];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat ctlWidth = self.bounds.size.width;
    CGFloat ctlHeight = self.bounds.size.height;
    CGFloat itemH = 30;
    
    if (!_editor)
    {
        [_checkBtn setFrame:CGRectMake(6, (ctlHeight-itemH)/2, itemH, itemH)];
        [_tfVote setFrame:CGRectMake(40, (ctlHeight-itemH)/2, ctlWidth-60, itemH)];
    }
    else
    {
        [_tfVote setFrame:CGRectMake(10, (ctlHeight-itemH)/2, self.bounds.size.width-70, itemH)];
        [_addButton setFrame:CGRectMake(ctlWidth-55, (ctlHeight-itemH)/2, itemH+10, itemH)];
    }
    
    self.progressLabel.frame = CGRectInset(self.bounds, 10, 0);

}

- (void)setInfo:(CEditVoteInfo*) info tableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.editor = info.editor;
    self.info = info;
    UIImage* img = nil;
    UIColor *color = nil;
    
    if (info.type == C_LIST)
    {
        self.progressLabel.hidden = YES;
        self.isChecked = info.checked;
        img = self.isChecked? self.checkedImage1 : self.uncheckedImage1;
        
        if (_grayView)
        {
            [self.grayView removeFromSuperview];
            self.grayView = nil;
        }
        
        color = self.isChecked?[DesignManager knoteUsernameColor]:[UIColor blackColor];
        [_tfVote setTextColor:color];
        
    }
    else
    {
        self.progressLabel.hidden = NO;
        BOOL checked = NO;
        
        for (NSString *vote in info.voters)
        {
            if ([vote isKindOfClass:[NSString class]])
            {
                if ([vote isEqualToString:self.my_account_id])
                {
                    checked = YES;
                    break;
                }
            }
        }
        
        img = self.isChecked? self.checkedImage : self.uncheckedImage;
        color = self.isChecked?[DesignManager knoteUsernameColor]:[UIColor blackColor];
        
        [_tfVote setTextColor:color];
        
        self.isChecked = checked;
        
        if (!self.grayView)
        {
            self.grayView = [[UIView alloc] initWithFrame:CGRectZero];
            self.grayView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            self.grayView.backgroundColor = [UIColor colorWithWhite:0.92 alpha:0.7];
            [self addSubview:self.grayView];
            [self sendSubviewToBack:self.grayView];
        }
        
        CGFloat process = 0.0f;
        
        if (info.voters && [info.voters count]>0  && self.participators && [self.participators count]>0)
        {
            process = ((CGFloat)[info.voters count]*1.0)/(CGFloat)[self.participators count];
        }
        
        self.progressLabel.text = [NSString stringWithFormat:@"%d%%",(int)(process*100)];
        
        UIBezierPath *maskPath = nil;
        CGRect bounds = self.bounds;
        
        bounds.origin.x+=2;
        bounds.size.width-=8;
        bounds.size.width = process*bounds.size.width;
        
        self.grayView.frame = bounds;
        
        CGFloat cornerRadius = 6.f;
        
        if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1)
        {
            maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds
                                  byRoundingCorners:(UIRectCornerAllCorners)
                                        cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
        }
        else if (indexPath.row == 0)
        {
            maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds
                                  byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                        cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
        }
        else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
            maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds
                                  byRoundingCorners:(UIRectCornerBottomRight | UIRectCornerBottomLeft)
                                        cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
        }
        else
        {
            maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds
                                             byRoundingCorners:(UIRectCornerAllCorners)
                                                   cornerRadii:CGSizeMake(0, 0)];
        }
        
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = bounds;
        maskLayer.path = maskPath.CGPath;
        
        self.grayView.layer.mask = maskLayer;
    }
    
    self.contentText = info.name;
    
    if (self.contentText == (id)[NSNull null])
    {
        NSLog(@"NULL TEXT IN VOTE CELL :%@", info);
    
        self.contentText = @"";
    }
    
    if (self.info.type == C_LIST)
    {
        if (_isChecked)
        {
            // Update list name with Strike Through Style
            
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self.contentText];
            [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                    value:@0
                                    range:NSMakeRange(0, [attributeString length])];
            
            _tfVote.attributedText = attributeString;
            
            UIColor *attColor = self.isChecked?[UIColor grayColor]:[UIColor blackColor];
            
            [_tfVote setTextColor:attColor];
            
        }
        else
        {
            [_tfVote setText:self.contentText];
            _tfVote.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
        }
    }
    else
    {
        [_tfVote setText:self.contentText];
    }
    
    [_progressLabel setTextColor:color];

    [_checkBtn setImage:img forState:UIControlStateNormal];
   
    _isAddable = NO;
    
    [_addButton setTitle:@"x" forState:UIControlStateNormal];
    [_addButton setBackgroundColor:[UIColor lightGrayColor]];
}

- (void)setAddable
{
    _isAddable = YES;
    
    [_addButton setTitle:@"+" forState:UIControlStateNormal];
    [_addButton setBackgroundColor:[DesignManager knoteUsernameColor]];
}

- (void)endEditText
{
    self.contentText = _tfVote.text;
    
    if ([_tfVote isFirstResponder])
    {
         [_tfVote resignFirstResponder];
    }
}

- (void)onCheckChanged:(id)sender
{
    _isChecked = !_isChecked;
    
    if ([self.voteDelegate respondsToSelector:@selector(checkSelected:withItem:)])
        [self.voteDelegate checkSelected:_isChecked withItem:self];
    
    UIImage* img = nil;
    
    if (self.info.type == C_LIST)
    {
        img = _isChecked? self.checkedImage1 : self.uncheckedImage1;
    }
    else
    {
        img = _isChecked? self.checkedImage : self.uncheckedImage;
    }
    
    [_checkBtn setImage:img forState:UIControlStateNormal];
}

- (void)onAddItem:(id)sender
{
    UIButton *actionButton = (UIButton*) sender;
    
    if ([actionButton.currentTitle isEqualToString:@"+"])
    {
        _isAddable = YES;
    }
    else
    {
        _isAddable = NO;    
    }
    
    if (_isAddable)
    {
        if ([_tfVote.text length]>0)
        {
            self.contentText = _tfVote.text;
            
            if ([self.voteDelegate canAddItem:self.contentText])
            {
                // Change button + to x
                
                if ([self.voteDelegate respondsToSelector:@selector(addNewItemAtIndex:withContent:)])
                    [self.voteDelegate addNewItemAtIndex:self.index withContent:self.contentText];
            }
        }
        else
        {
            _tfVote.layer.cornerRadius=2.0f;
            _tfVote.layer.masksToBounds=YES;
            _tfVote.layer.borderColor=[[UIColor redColor]CGColor];
            _tfVote.layer.borderWidth= 1.0f;
        }
    }
    else
    {
        if ([self.voteDelegate respondsToSelector:@selector(removeVoteCellAtIndex:)])
            [self.voteDelegate removeVoteCellAtIndex:self.index];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.layer.cornerRadius=2.0f;
    textField.layer.masksToBounds=YES;
    textField.layer.borderColor=[[UIColor darkGrayColor]CGColor];
    textField.layer.borderWidth= 1.0f;
    textField.text = self.contentText;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.contentText = textField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.contentText = textField.text;
	return [textField resignFirstResponder];
}

#pragma mark * Private method

- (void)onTimer:(NSTimer*)timer
{
    [_holdTimer invalidate];
    _holdTimer = nil;
    if (_voteDelegate && [_voteDelegate respondsToSelector:@selector(needShowMenu:)]) {
        [_voteDelegate needShowMenu:YES];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_holdTimer invalidate];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_holdTimer invalidate];
    _holdTimer = nil;
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{

    if ([_holdTimer isValid]) {
        [_holdTimer invalidate];
        _holdTimer = nil;
    }
    
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = NO;

    [_holdTimer invalidate];
    _holdTimer = nil;
    if (_voteDelegate && [_voteDelegate respondsToSelector:@selector(needShowMenu:)]) {
        [_voteDelegate needShowMenu:NO];
    }

    [super touchesCancelled:touches withEvent:event];
}

@end
