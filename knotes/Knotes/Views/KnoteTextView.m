//
// Created by Martin Ceperley on 3/4/14.
//

#import "KnoteTextView.h"
#import "CEditKnoteItemView.h"


@implementation KnoteTextView {

}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return [super canPerformAction:action withSender:sender];
}

- (void)highlight:(id)sender
{
    CEditKnoteItemView *editKnoteItem = (CEditKnoteItemView *)self.superview.superview.superview.superview.superview;
    [editKnoteItem performSelector:@selector(highlight:) withObject:sender];
}

- (void)quoteText:(id)sender
{
    CEditKnoteItemView *editKnoteItem = (CEditKnoteItemView *)self.superview.superview.superview.superview.superview;
    
    if ([editKnoteItem respondsToSelector:@selector(quoteText:)])
    {
        [editKnoteItem performSelector:@selector(quoteText:)
                            withObject:sender];
    }
}

@end
