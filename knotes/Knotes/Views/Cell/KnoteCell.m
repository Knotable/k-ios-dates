//
//  KnoteCell.m
//  Knotable
//
//  Created by Martin Ceperley on 12/22/13.
//
//

#import "KnoteCell.h"

#import "CUtil.h"
#import "SizingTextView.h"
#import "MessageEntity.h"
#import "DesignManager.h"
#import "UIButton+Extensions.h"
#import <QuartzCore/QuartzCore.h>

@interface KnoteCell ()

@property (nonatomic, strong) UITextView* bodyTextView;
@property (nonatomic, strong) NSMutableParagraphStyle *knoteParagraphStyle;
@property (nonatomic, strong) NSDictionary *knoteTextAttributes;
@property (nonatomic, strong) MASConstraint *heightConstraint;

@end

@implementation KnoteCell

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _bodyTextView = [[UITextView alloc] initWithFrame:CGRectZero textContainer:nil];
        _bodyTextView.scrollEnabled = NO;
        _bodyTextView.font = [DesignManager knoteSubjectFont];
        _bodyTextView.textColor = [DesignManager knoteBodyTextColor];
        _bodyTextView.backgroundColor = [UIColor clearColor];
        _bodyTextView.alpha = 1.0;
        _bodyTextView.textContainerInset = UIEdgeInsetsZero;
        _bodyTextView.contentInset = UIEdgeInsetsMake(0, -5.0, 0, -5.0);

        //To implement
        _bodyTextView.allowsEditingTextAttributes = NO;
        _bodyTextView.editable = NO;
        _bodyTextView.selectable = YES;
        _bodyTextView.userInteractionEnabled = NO;

        _bodyTextView.dataDetectorTypes = UIDataDetectorTypeLink;
        _bodyTextView.linkTextAttributes = [DesignManager linkTextAttributes];

        
        [self.bodyView addSubview:_bodyTextView];
        
        NSMutableParagraphStyle *paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paraStyle.paragraphSpacing = 12.0;
        paraStyle.headIndent = 0.0;
        paraStyle.tailIndent = 0.0;
        paraStyle.firstLineHeadIndent = 0.0;
        
        _knoteParagraphStyle = paraStyle;
        
        _knoteTextAttributes = @{NSParagraphStyleAttributeName: paraStyle ,
                                 NSFontAttributeName: _bodyTextView.font,
                                 NSForegroundColorAttributeName: _bodyTextView.textColor};



        self.expandeMode = NO;

    }
    return self;
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)setDelegate:(id)delegate
{
    [super setDelegate:delegate];
    _bodyTextView.delegate = delegate;
}

- (void)setMessage:(MessageEntity *)message
{
    [super setMessage:message];

    NSString *text = message.body;
    
    if (message.body == nil)
    {
        text = @"";
        
        NSLog(@"Message without title type: %d", message.type);
    }
    
    _knoteTextAttributes = @{ NSParagraphStyleAttributeName: _knoteParagraphStyle,
                             NSFontAttributeName: _bodyTextView.font,
                             NSForegroundColorAttributeName: _bodyTextView.textColor };
    
    self.bodyTextView.attributedText = [[NSAttributedString alloc] initWithString:text
                                                                       attributes:_knoteTextAttributes];
}

- (void)updateConstraints
{
    if (!self.didSetupConstraints)
    {
        [self.bodyTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            //height is assigned in setMaxWidth
            _heightConstraint = make.height.equalTo(@0);
            make.top.equalTo(self.bodyView);
            make.bottom.equalTo(self.bodyView).offset(-10);
            make.left.equalTo(self.bodyView);
            make.right.equalTo(self.mas_right).offset(-20);
        }];
    }
    [super updateConstraints];
}

- (void)setMaxWidth
{
    CGFloat MAX_HEIGHT = 30.0;
    CGFloat height = self.bodyTextView.intrinsicContentSize.height;
    height = MAX_HEIGHT;
    _heightConstraint.offset(height);
}

- (void)wasEdited
{
}

- (void)finishedEditing
{
    if ([self.message.body isEqualToString:self.bodyTextView.text]) {
        return;
    }
    
    self.message.body = self.bodyTextView.text;
    [AppDelegate saveContext];
}

-(void)didDissapear
{
    
}

- (void)expandeCell {
    
    self.expandeMode = !self.expandeMode;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NEWS_CELL_EXPAND
                                                        object:self userInfo:nil];
}


@end
