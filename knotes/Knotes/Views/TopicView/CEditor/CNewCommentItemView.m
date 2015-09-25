//
//  CNewCommentItemView.m
//  Knotable
//
//  Created by Agustin Guerra on 8/12/14.
//
//

#import "CNewCommentItemView.h"

#import "GMSolidLayer.h"
#import "KnoteTextView.h"
#import "CEditReplysItemView.h"
#import "ImageCollectionViewCell.h"

#import "CUtil.h"
#import "ObjCMongoDB.h"

#import "DesignManager.h"
#import "CKnoteItem.h"

#import "CNewCommentItem.h"

#import <QuartzCore/QuartzCore.h>

@interface CNewCommentItemView() <UITextViewDelegate>

@property (nonatomic, retain) IBOutlet KnoteTextView *textView;
@property (nonatomic, assign) CGRect originalFileImageFrame;
@end

@implementation CNewCommentItemView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.commentButton.hidden = YES;
        self.pinButton.hidden = YES;
        
        [self createTextView];
        [self createPlaceholderLabel];
        [self createPostCommentButton];
        [self createPostingCommentActivityIndicatorView];
    }
    
    return self;
}

- (void)reset {
    self.textView.text = @"";
    self.textView.editable   = YES;
    self.textView.selectable = YES;
    self.postCommentButton.hidden = NO;
    [self initPlaceholderLabel];
    [self.postingCommentActivityIndicatorView stopAnimating];
}

- (void)createTextView {
    NSTextStorage* textStorage = [NSTextStorage new];
    NSLayoutManager* layoutManager = [NSLayoutManager new];
    layoutManager.usesFontLeading = YES;
    
    [textStorage addLayoutManager:layoutManager];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:self.contentView.bounds.size];
    textContainer.heightTracksTextView = YES;
    textContainer.widthTracksTextView = YES;
    [layoutManager addTextContainer:textContainer];
    
    self.textView = [[KnoteTextView alloc] initWithFrame:self.contentView.bounds textContainer:textContainer];
    self.textView.delegate = self;
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.textColor = [DesignManager knoteBodyTextColor];
    self.textView.font = [DesignManager knoteBodyFont];
    self.textView.dataDetectorTypes = UIDataDetectorTypeLink;
    self.textView.linkTextAttributes = [DesignManager linkTextAttributes];
    self.textView.userInteractionEnabled = YES;
    self.textView.selectable             = YES;
    self.textView.editable               = YES;
    self.textView.scrollEnabled          = NO;
    self.textView.layer.borderColor  = [UIColor grayColor].CGColor;
    self.textView.layer.borderWidth  = 2.0;
    self.textView.layer.cornerRadius = 6.0;
    self.textView.contentInset       = UIEdgeInsetsZero;
    self.textView.textContainerInset = UIEdgeInsetsMake(4.0, 4.0, 4.0, 60.0);
    
    [self.contentView addSubview:self.textView];
    [self.contentView bringSubviewToFront:self.textView];
}

- (void)createPlaceholderLabel {
    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    [self initPlaceholderLabel];
    
    [self.contentView addSubview:self.placeholderLabel];
    [self.contentView bringSubviewToFront:self.placeholderLabel];
    
    if (![self.textView.text isEqualToString:@""]) {
        self.placeholderLabel.hidden = YES;
    }
}

- (void)initPlaceholderLabel {
    self.placeholderLabel.text = @"Write your comment here..";
    self.placeholderLabel.textColor = [DesignManager KnoteNormalColor];
    self.placeholderLabel.font = [DesignManager knoteBodyFont];
}

- (void)createPostCommentButton {
    self.postCommentButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.postCommentButton setTitle:@"Post" forState:UIControlStateNormal];
    [self.postCommentButton addTarget:self action:@selector(postCommentButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:self.postCommentButton];
    [self.contentView bringSubviewToFront:self.postCommentButton];
}

- (void)createPostingCommentActivityIndicatorView {
    self.postingCommentActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.postingCommentActivityIndicatorView.hidesWhenStopped = YES;
    
    [self.contentView addSubview:self.postingCommentActivityIndicatorView];
    [self.contentView bringSubviewToFront:self.postingCommentActivityIndicatorView];
}

- (void)postCommentButtonTapped:(UIButton *)postCommentButton {
    NSLog(@"postCommentButtonTapped");
    CNewCommentItem *newCommentItem = (CNewCommentItem *)self.getItemData;
    newCommentItem.body = self.textView.text;
    [newCommentItem postComment];
    
    [self.textView resignFirstResponder];
    self.textView.editable   = NO;
    self.textView.selectable = NO;
    self.placeholderLabel.text = @"Posting comment..";
    [self.postingCommentActivityIndicatorView startAnimating];
    self.postCommentButton.hidden = YES;
}

- (void)updateConstraints {
#if NEW_DESIGN
#else
    self.titleBarHeight = 0;
#endif
    self.infoBarHeight  = 0;
    
    [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgView.mas_top).offset(5);
        make.bottom.equalTo(self.bgView.mas_bottom).offset(-5.0);
        make.left.equalTo(self.mas_left).offset(kTheadLeftGap - 12);
        make.right.equalTo(self.mas_right).offset(-5.0);
    }];
    
    [self.placeholderLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgView.mas_top).offset(10);
        make.left.equalTo(self.mas_left).offset(kTheadLeftGap - 5.0);
    }];
    
    [self.postCommentButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bgView.mas_bottom).offset(-5.0);
        make.right.equalTo(self.mas_right).offset(-15.0);
    }];
    
    [self.postingCommentActivityIndicatorView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bgView.mas_bottom).offset(-15.0);
        make.right.equalTo(self.mas_right).offset(-15.0);
    }];
    
    [super updateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textView.textContainer.size = self.textView.bounds.size;
}

- (void)endEditing {
    [self.textView resignFirstResponder];
}

- (void)startEditing {
    [self.textView becomeFirstResponder];
}

- (void)setItemData:(CItem *)itemData {
    [super setItemData:itemData];
}

- (CItem *)getItemData {
    return [super getItemData];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView == self.textView) {
        self.placeholderLabel.hidden = YES;
        [self.parentTableView.delegate performSelector:@selector(setActiveView:) withObject:self];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView == self.textView) {
        self.textView.text = @"";
        self.placeholderLabel.hidden = NO;
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    return YES;
}

- (BOOL)becomeFirstResponder {
    BOOL flag =  [self.textView becomeFirstResponder];
    return flag;
}

- (BOOL)isFirstResponder {
    BOOL flag = [self.textView isFirstResponder];
    return flag;
}

- (BOOL)resignFirstResponder {
    BOOL flag = [self.textView resignFirstResponder];
    return flag;
}

@end
