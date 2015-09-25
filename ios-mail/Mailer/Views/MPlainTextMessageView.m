//
//  MPlainTextMessageView.m
//  Mailer
//
//  Created by Martin Ceperley on 10/15/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "MPlainTextMessageView.h"


@implementation MPlainTextMessageView

- (id)initWithAttributedText:(NSAttributedString *)attributedText
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.attributedText = attributedText;
        
        _textView = [[UITextView alloc] initWithFrame:CGRectZero];
        _textView.attributedText = self.attributedText;
        _textView.scrollEnabled = NO;
        _textView.editable = NO;
        _textView.dataDetectorTypes = UIDataDetectorTypeAll;
        //_textView.backgroundColor = [UIColor greenColor];
        self.backgroundColor = [UIColor yellowColor];
        
        [self addSubview:_textView];
        
        [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
}

@end
