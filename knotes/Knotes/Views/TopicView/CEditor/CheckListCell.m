//
//  CheckListCell.m
//  RevealControllerProject
//
//  Created by backup on 13-12-3.
//
//

#import "CheckListCell.h"
#import "CUtil.h"
#import "DesignManager.h"
#import "InputAccessViewManager.h"
#import "UIImage+FontAwesome.h"

@interface CheckListCell()<UITextFieldDelegate>
@property (nonatomic, retain) UIImage* checkedImage;
@property (nonatomic, retain) UIImage* uncheckedImage;
@property (nonatomic, retain) UIButton* checkBtn;
@property (nonatomic, retain) UIButton* addButton;
@property (nonatomic) BOOL  isAddable;
@property (nonatomic, assign) BOOL  isChecked;

@property (nonatomic, strong) UIView *editBgView;

@end

@implementation CheckListCell

@synthesize editor = _editor;
@synthesize inputText = _inputText;
@synthesize checkBtn = _checkBtn;
@synthesize addButton= _addButton;
@synthesize isChecked = _isChecked;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.editBgView = [UIView new];
        self.editBgView.userInteractionEnabled = NO;
        
        _editBgView.layer.cornerRadius=2.0f;
        _editBgView.layer.masksToBounds=YES;
        _editBgView.layer.borderColor=[[UIColor redColor]CGColor];
        _editBgView.layer.borderWidth= 1.0f;
        
        _editBgView.hidden = YES;
        
        [self addSubview:self.editBgView];
        
        if (self.checkedImage == nil)
        {
            self.checkedImage = [UIImage imageNamed: @"check_btn.png"];
        }
        
        if (self.uncheckedImage == nil)
        {
            self.uncheckedImage = [UIImage imageNamed: @"uncheck_btn.png"];
        }
        
        if (!_inputText)
        {
            _inputText = [[UITextField alloc] initWithFrame:CGRectZero];
            _inputText.delegate = self;
            _inputText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            _inputText.textColor = kInputTextColor;
            _inputText.font = kCustomLightFont(kDefaultFontSize);
            _inputText.borderStyle = UITextBorderStyleNone;
            _inputText.adjustsFontSizeToFitWidth = YES;
            _inputText.textAlignment = NSTextAlignmentLeft;
            _inputText.clearButtonMode = UITextFieldViewModeNever;
            _inputText.clearsOnBeginEditing = YES;
            _inputText.keyboardType = UIKeyboardTypeASCIICapable;
            
            [self addSubview:_inputText];
        }
        
        if (!_checkBtn)
        {
            self.checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_checkBtn addTarget:self action:@selector(onCheckChanged:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_checkBtn];
        }
        
        if (!_addButton)
        {
            self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_addButton setImage:[UIImage imageWithIcon:@"fa-times" backgroundColor:[UIColor clearColor] iconColor:[UIColor grayColor] fontSize:14] forState:UIControlStateNormal];
            //[_addButton setTitle:@"X" forState:UIControlStateNormal];
            [_addButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
            [_addButton addTarget:self action:@selector(onAddItem:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_addButton];
        }
    }
    
//    _inputText.backgroundColor = [UIColor redColor];
    return self;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat ctlWidth = self.bounds.size.width;
    CGFloat ctlHeight = self.bounds.size.height;
    CGFloat itemH = 30;
    if (!_editor) {
        [_checkBtn setFrame:CGRectMake(4, (ctlHeight-itemH)/2, itemH, itemH)];
        CGRect rect = CGRectMake(40, (ctlHeight-itemH)/2, ctlWidth-60, itemH);
        [_editBgView setFrame:CGRectInset(rect, -6, 0)];
        [_inputText setFrame:rect];
    } else {
        CGRect rect = CGRectMake(10, (ctlHeight-itemH)/2, self.bounds.size.width-70, itemH);
        [_editBgView setFrame:CGRectInset(rect, -6, 0)];
        [_inputText setFrame:rect];
        [_addButton setFrame:CGRectMake(ctlWidth-46, (ctlHeight-itemH)/2, itemH+10, itemH)];
    }
    
//Adding Botton border in UITextField
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 2;
    border.borderColor = [UIColor darkGrayColor].CGColor;
    border.frame = CGRectMake(0, _inputText.frame.size.height - borderWidth, _inputText.frame.size.width, _inputText.frame.size.height);
    border.borderWidth = borderWidth;
    [_inputText.layer addSublayer:border];
}

-(void)setInfo:(CEditVoteInfo *)info
{
    _info = info;
    
    self.editor = YES;
    self.isChecked = info.checked;
    
    [_inputText setText:info.name];
    
    UIImage* img = self.isChecked? self.checkedImage : self.uncheckedImage;
    
    [_checkBtn setImage:img forState:UIControlStateNormal];
    _isAddable = NO;
    
    [_addButton setImage:[UIImage imageWithIcon:@"fa-times" backgroundColor:[UIColor clearColor] iconColor:[UIColor grayColor] fontSize:14] forState:UIControlStateNormal];
    [_addButton setTitle:@"x" forState:UIControlStateNormal];
    [_addButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [_addButton setBackgroundColor:[DesignManager knoteBackgroundColor]];
}

- (void)setAddable:(BOOL)flag
{
    _isAddable = YES;
    
    [_addButton setImage:[UIImage imageWithIcon:@"fa-plus" backgroundColor:[UIColor clearColor] iconColor:[UIColor grayColor] fontSize:14] forState:UIControlStateNormal];
    [_addButton setTitle:@"+" forState:UIControlStateNormal];
    [_addButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [_addButton setBackgroundColor:[DesignManager knoteBackgroundColor]];
    
    if (flag)
    {
        [_inputText becomeFirstResponder];
    }
}

- (void)endEditText
{
    self.info.name = _inputText.text;
    if ([_inputText isFirstResponder]) {
        [_inputText resignFirstResponder];
    }
}
- (void)onCheckChanged:(id)sender
{
    _isChecked = !_isChecked;
    
    if ([self.delegate respondsToSelector:@selector(checkSelected:withItem:)])
        [self.delegate checkSelected:_isChecked withItem:self];
    
    UIImage* img = _isChecked? self.checkedImage : self.uncheckedImage;
    [_checkBtn setImage:img forState:UIControlStateNormal];
    
}

- (void)onAddItem:(id)sender
{
    UIButton *actionButton = (UIButton*) sender;
    
    if ([actionButton.titleLabel.text isEqualToString:@"+"])
    {
        _isAddable = YES;
    }
    else
    {
        _isAddable = NO;
    }
    
    if (_isAddable)
    {
        if ([_inputText.text length]>0)
        {
            self.info.name = _inputText.text;
            
            if ([self.delegate canAddItem: _inputText.text])
            {
                if ([self.delegate respondsToSelector:@selector(addNewItemAtIndex:withContent:)])
                {
                    if ([self.delegate addNewItemAtIndex:self.index withContent:_inputText.text])
                    {
                        // Lin - Added to change button type here
                        
                        // Change + button to x button here
                        
                        [_addButton setImage:[UIImage imageWithIcon:@"fa-times" backgroundColor:[UIColor clearColor] iconColor:[UIColor grayColor] fontSize:14] forState:UIControlStateNormal];
                        [_addButton setTitle:@"x" forState:UIControlStateNormal];
                        [_addButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
                        [_addButton setBackgroundColor:[DesignManager knoteBackgroundColor]];
                        
                        // Lin - Ended
                    }
                    else
                    {
                        [_addButton setImage:[UIImage imageWithIcon:@"fa-plus" backgroundColor:[UIColor clearColor] iconColor:[UIColor grayColor] fontSize:14] forState:UIControlStateNormal];
                        [_addButton setTitle:@"+" forState:UIControlStateNormal];
                        [_addButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
                        [_addButton setBackgroundColor:[DesignManager knoteBackgroundColor]];
                    }
                }
            }
        }
        else
        {
            _editBgView.layer.cornerRadius=2.0f;
            _editBgView.layer.masksToBounds=YES;
            _editBgView.layer.borderColor=[[UIColor redColor]CGColor];
            _editBgView.layer.borderWidth= 1.0f;
        }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(removeVoteCellAtIndex:)])
            [self.delegate removeVoteCellAtIndex:self.index];
    }
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
//   textField.inputAccessoryView =[[InputAccessViewManager sharedInstance] inputAccessViewWithOutCamera];
    _editBgView.layer.cornerRadius=2.0f;
    _editBgView.layer.masksToBounds=YES;
    _editBgView.layer.borderColor=[[UIColor darkGrayColor]CGColor];
    _editBgView.layer.borderWidth= 1.0f;
    textField.text = self.info.name;
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemBeginEditing:)]) {
        [self.delegate itemBeginEditing:self];
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.info.name = textField.text;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.info.name = textField.text;
	return [textField resignFirstResponder];
}
@end
