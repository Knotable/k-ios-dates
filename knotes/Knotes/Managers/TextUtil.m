//
//  TextUtil.m
//  Knotable
//
//  Created by wuli on 14-4-3.
//
//

#import "TextUtil.h"
#import "KnoteTextView.h"
#import "DesignManager.h"

@interface TextUtil()

@property(nonatomic,strong) KnoteTextView *textView;

- (void)createTextViewWithWidth:(CGFloat)width;

@end

@implementation TextUtil

SYNTHESIZE_SINGLETON_FOR_CLASS(TextUtil);

- (CGSize)getTextViewSize:(NSAttributedString *)text withWidth:(CGFloat)width {
    return [self getTextViewSize:text withWidth:width andMaximumNumberOfLines:0];
}

- (CGSize)getTextViewSize:(NSAttributedString *)text withWidth:(CGFloat)width andMaximumNumberOfLines:(int)maximumNumberOfLines {
    if (!self.textView) {
        [self createTextViewWithWidth:width];
    }
    
    self.textView.textContainer.maximumNumberOfLines = maximumNumberOfLines;
    self.textView.attributedText = text;
    CGSize sizeThatShouldFitTheContent = [self.textView sizeThatFits:self.textView.frame.size];
    
    return sizeThatShouldFitTheContent;
}

- (void)createTextViewWithWidth:(CGFloat)width {
    
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(width, 1000000)];
    textContainer.heightTracksTextView = YES;
    textContainer.widthTracksTextView = YES;
    
    NSLayoutManager *layoutManager = [NSLayoutManager new];
    layoutManager.usesFontLeading = YES;
    [layoutManager addTextContainer:textContainer];
    
    NSTextStorage *textStorage = [NSTextStorage new];
    [textStorage addLayoutManager:layoutManager];
    
    self.textView = [[KnoteTextView alloc] initWithFrame:CGRectMake(0, 0, width, 1000000) textContainer:textContainer];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.textColor = [DesignManager knoteBodyTextColor];
    self.textView.font = [DesignManager knoteBodyFont];
    self.textView.dataDetectorTypes = UIDataDetectorTypeLink;
    self.textView.linkTextAttributes = [DesignManager linkTextAttributes];
    self.textView.selectable = YES;
    self.textView.userInteractionEnabled = YES;
    self.textView.scrollEnabled = NO;
    self.textView.contentInset = UIEdgeInsetsZero;
    self.textView.editable = NO;
    self.textView.textContainerInset = UIEdgeInsetsMake(4.0, 4.0, 4.0, 4.0);
}

@end
