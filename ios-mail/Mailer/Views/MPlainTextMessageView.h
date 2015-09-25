//
//  MPlainTextMessageView.h
//  Mailer
//
//  Created by Martin Ceperley on 10/15/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MPlainTextMessageView : UIView{
    @private
    CGFloat _width;
}

- (id)initWithAttributedText:(NSAttributedString *)attributedText;

@property (strong, nonatomic) UITextView *textView;
@property (copy, nonatomic) NSAttributedString *attributedText;

@end
