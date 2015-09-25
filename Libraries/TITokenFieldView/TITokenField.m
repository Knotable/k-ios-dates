//
//  TITokenField.m
//  Mailer
//
//  Created by wuli on 14-5-12.
//  Copyright (c) 2014年 Knotable. All rights reserved.
//

#import "TITokenField.h"
#import "UIView+TIToken.h"

#import "TITokenFieldInternalDelegate.h"
#import "TITokenConfig.h"

//==========================================================
#pragma mark - TITokenField -
//==========================================================
NSString * const kTextEmpty = @" "; // Just a space
NSString * const kTextHidden = @"`"; // This character isn't available on iOS (yet) so it's safe.



@interface TITokenField ()
@property (nonatomic, readonly) UIScrollView * scrollView;
@end

@interface TITokenField (Private)
- (void)updateHeightAnimated:(BOOL)animated;
- (void)performButtonAction;
@end

@implementation TITokenField
@synthesize delegate;
@synthesize tokens;
@synthesize editable;
@synthesize resultsModeEnabled;
@synthesize removesTokensOnEndEditing;
@synthesize numberOfLines;
@synthesize addButtonSelector;
@synthesize tokenizingCharacters;

#pragma mark Init
- (id)initWithFrame:(CGRect)frame {
	
    if ((self = [super initWithFrame:frame])){
		[self setup];
    }
	
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	
	if ((self = [super initWithCoder:aDecoder])){
		[self setup];
	}
	
	return self;
}

- (void)setup {
	[self setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
	[self setBorderStyle:UITextBorderStyleNone];
	[self setFont:[UIFont systemFontOfSize:14]];
	[self setBackgroundColor:[UIColor whiteColor]];
	[self setAutocorrectionType:UITextAutocorrectionTypeNo];
	[self setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	
	[self addTarget:self action:@selector(didBeginEditing) forControlEvents:UIControlEventEditingDidBegin];
	[self addTarget:self action:@selector(didEndEditing) forControlEvents:UIControlEventEditingDidEnd];
	[self addTarget:self action:@selector(didChangeText) forControlEvents:UIControlEventEditingChanged];
	
	[self.layer setShadowColor:[[UIColor blackColor] CGColor]];
	[self.layer setShadowOpacity:0.6];
	[self.layer setShadowRadius:12];
	
	self.addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
	[_addButton setUserInteractionEnabled:YES];
	[_addButton setHidden:YES];
	[_addButton addTarget:self action:@selector(performButtonAction) forControlEvents:UIControlEventTouchUpInside];
	[self setRightView:_addButton];
	[self setAddButtonAction:nil target:nil];
	
	[self setPromptText:@"To:"];
	[self setText:kTextEmpty];
	
	self.internalDelegate = [[TITokenFieldInternalDelegate alloc] init];
	[self.internalDelegate setTokenField:self];
	[super setDelegate:_internalDelegate];
	
	tokens = [[NSMutableArray alloc] init];
	editable = YES;
	removesTokensOnEndEditing = YES;
	tokenizingCharacters = [NSCharacterSet characterSetWithCharactersInString:@","];
    
    self.separator = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds)-1, CGRectGetWidth(self.bounds), 1)];
    [_separator setBackgroundColor:[UIColor colorWithWhite:0.7 alpha:1]];
    [self addSubview:_separator];
    [self bringSubviewToFront:_separator];

}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
    [_separator ti_setOriginY:frame.size.height-1];
    [_separator ti_setWidth:frame.size.width];
	[self.layer setShadowPath:[[UIBezierPath bezierPathWithRect:self.bounds] CGPath]];
	[self updateHeightAnimated:NO];
}

- (void)setText:(NSString *)text {
	[super setText:((text.length == 0 || [text isEqualToString:@""]) ? kTextEmpty : text)];
}

- (void)setFont:(UIFont *)font {
	[super setFont:font];
	
	if ([self.leftView isKindOfClass:[UILabel class]]){
		[self setPromptText:((UILabel *)self.leftView).text];
	}
}

- (void)setDelegate:(id<TITokenFieldDelegate>)del {
	delegate = del;
	[_internalDelegate setDelegate:delegate];
}

//- (NSArray *)tokens {
//	return [[tokens copy] autorelease];
//}

- (UIScrollView *)scrollView {
	return ([self.superview isKindOfClass:[UIScrollView class]] ? (UIScrollView *)self.superview : nil);
}

- (BOOL)becomeFirstResponder {
	return (editable ? [super becomeFirstResponder] : NO);
}

#pragma mark Event Handling
- (void)didBeginEditing {
	for (TIToken * token in tokens) {
        [self addToken:token];
    }
}

- (void)didEndEditing {
	
	[_selectedToken setSelected:NO];
	_selectedToken = nil;
	
	[self tokenizeText];
	
	if (removesTokensOnEndEditing){
		
		for (TIToken * token in tokens) [token removeFromSuperview];
		
		NSString * untokenized = kTextEmpty;
		
		if (tokens.count){
			
			NSMutableArray * titles = [[NSMutableArray alloc] init];
			for (TIToken * token in tokens) [titles addObject:token.title];
			
			untokenized = [self.tokenTitles componentsJoinedByString:@", "];
#if IOS7_API
            CGSize untokSize = [untokenized sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
#else
			CGSize untokSize = [untokenized sizeWithFont:[UIFont systemFontOfSize:14]];
#endif
			CGFloat availableWidth = self.bounds.size.width - self.leftView.bounds.size.width - self.rightView.bounds.size.width;
			
			if (tokens.count > 1 && untokSize.width > availableWidth){
				untokenized = [NSString stringWithFormat:@"%lu recipients", (unsigned long)titles.count];
			}
        }
		
		[self setText:untokenized];
	}
	
	[self setResultsModeEnabled:NO];
}

- (void)didChangeText {
	if (self.text.length == 0) [self setText:kTextEmpty];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
	
	// Stop the cut, copy, select and selectAll appearing when the field is 'empty'.
	if (action == @selector(cut:) ||
        action == @selector(copy:) ||
        action == @selector(select:) ||
        action == @selector(selectAll:)) {
		return ![self.text isEqualToString:kTextEmpty];
    }
	return [super canPerformAction:action withSender:sender];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	
	if (_selectedToken && touch.view == self) [self deselectSelectedToken];
	return [super beginTrackingWithTouch:touch withEvent:event];
}

#pragma mark Token Handling
- (TIToken *)addTokenWithTitle:(NSString *)title {
	
	if (title.length) {
		TIToken * token = [[TIToken alloc] initWithTitle:title representedObject:nil font:self.font];
		[self addToken:token];
		return token;
	}
	
	return nil;
}

- (void)addToken:(TIToken *)token {
	
	[self becomeFirstResponder];
	
	[token addTarget:self action:@selector(tokenTouchDown:) forControlEvents:UIControlEventTouchDown];
	[token addTarget:self action:@selector(tokenTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:token];
	
	if (![tokens containsObject:token]) [tokens addObject:token];
	
	[self setResultsModeEnabled:NO];
	[self setText:kTextEmpty];
}

- (void)removeToken:(TIToken *)token {
	
	if (token == _selectedToken)
		_selectedToken = nil;
	
	[token removeFromSuperview];
	[tokens removeObject:token];
	
	[self setText:kTextEmpty];
	[self setResultsModeEnabled:NO];
}

- (void)selectToken:(TIToken *)token {
	
	[self deselectSelectedToken];
	
	_selectedToken = token;
	[_selectedToken setSelected:YES];
	
	[self becomeFirstResponder];
	
	[self setText:kTextHidden];
}

- (void)deselectSelectedToken {
	
	[_selectedToken setSelected:NO];
	_selectedToken = nil;
	
	[self setText:kTextEmpty];
}

- (void)tokenizeText {
	
	if (![self.text isEqualToString:kTextEmpty] && ![self.text isEqualToString:kTextHidden]){
		
		NSArray * components = [self.text componentsSeparatedByCharactersInSet:tokenizingCharacters];
		for (NSString *__strong component in components){//wuli check
			
			component = [component stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			if (component.length) [self addTokenWithTitle:component];
		}
	}
}

- (void)tokenTouchDown:(TIToken *)token {
	
	if (_selectedToken != token){
		[_selectedToken setSelected:NO];
		_selectedToken = nil;
	}
}

- (void)tokenTouchUpInside:(TIToken *)token {
	if (editable) [self selectToken:token];
}

- (CGFloat)layoutTokens {
	
	// Adapted from Joe Hewitt's Three20 layout method.
	CGFloat topMargin = floor(self.font.lineHeight * 4 / 7);
	CGFloat leftMargin = self.leftView ? self.leftView.bounds.size.width + 12 : 8;
	CGFloat rightMargin = 16;
	CGFloat rightMarginWithButton = _addButton.hidden ? 8 : 46;
	CGFloat initialPadding = 8;
	CGFloat tokenPadding = 4;
	CGFloat linePadding = topMargin + 5;
	CGFloat lineHeightWithPadding = self.font.lineHeight + linePadding;
	
	numberOfLines = 1;
	cursorLocation.x = leftMargin;
	cursorLocation.y = topMargin - 1;
	
	for (TIToken * token in tokens){
		
		[token setFont:self.font];
		
		if (token.superview){
			
			CGFloat lineWidth = cursorLocation.x + token.bounds.size.width + rightMargin;
			if (lineWidth >= self.bounds.size.width){
				
				numberOfLines++;
				cursorLocation.x = leftMargin;
				
				if (numberOfLines > 1) cursorLocation.x = initialPadding;
				cursorLocation.y += lineHeightWithPadding;
			}
			
			CGRect newFrame = (CGRect){cursorLocation, token.bounds.size};
			if (!CGRectEqualToRect(token.frame, newFrame)){
				
				[token setFrame:newFrame];
				[token setAlpha:0.6];
				
				[UIView animateWithDuration:0.3 animations:^{[token setAlpha:1];}];
			}
			
			cursorLocation.x += token.bounds.size.width + tokenPadding;
		}
		
		CGFloat leftoverWidth = self.bounds.size.width - (cursorLocation.x + rightMarginWithButton);
		if (leftoverWidth < 50){
			
			numberOfLines++;
			cursorLocation.x = leftMargin;
			
			if (numberOfLines > 1) cursorLocation.x = initialPadding;
			cursorLocation.y += lineHeightWithPadding;
		}
	}
	
	return cursorLocation.y + lineHeightWithPadding;
}

#pragma mark View Handlers
- (void)updateHeightAnimated:(BOOL)animated {
	
	CGFloat previousHeight = self.bounds.size.height;
	CGFloat newHeight = [self layoutTokens];
	
	if (previousHeight && previousHeight != newHeight){
		
		// Animating this seems to invoke the triple-tap-delete-key-loop-problem-thing™
		[UIView animateWithDuration:(animated ? 0.3 : 0) animations:^{
			[self ti_setHeight:newHeight];
			
			if ([delegate respondsToSelector:@selector(tokenFieldWillResize:animated:)]){
				[delegate tokenFieldWillResize:self animated:animated];
			}
			
		} completion:^(BOOL complete) {
			
			if ([delegate respondsToSelector:@selector(tokenFieldDidResize:animated:)]){
				[delegate tokenFieldDidResize:self animated:animated];
			}
		}];
	}
}

- (void)setResultsModeEnabled:(BOOL)flag {
	[self setResultsModeEnabled:flag animated:YES];
}

- (void)setResultsModeEnabled:(BOOL)flag animated:(BOOL)animated {
	
	[self updateHeightAnimated:animated];
	
	if (resultsModeEnabled != flag) {
		
		//Hide / show the shadow
		[self.layer setMasksToBounds:!flag];
		
		UIScrollView * scrollView = self.scrollView;
		[scrollView setScrollsToTop:!flag];
		[scrollView setScrollEnabled:!flag];
		
		CGFloat offset = ((numberOfLines == 1 || !flag) ? 0 : cursorLocation.y - floor(self.font.lineHeight * 4 / 7) + 1);
		[scrollView setContentOffset:CGPointMake(0, self.frame.origin.y + offset) animated:animated];
	}
	
	resultsModeEnabled = flag;
}

#pragma mark Other
- (NSArray *)tokenTitles {
	
	NSMutableArray * titles = [[NSMutableArray alloc] init];
	for (TIToken * token in tokens) {
        [titles addObject:token.title];
    }
	return titles;
}

- (NSArray *)tokenObjects {
	
	NSMutableArray * objects = [[NSMutableArray alloc] init];
	for (TIToken * token in tokens) {
        [objects addObject:token.representedObject];
    }
	return objects;
}

- (void)setPromptText:(NSString *)text {
	
	if (text){
		
		UILabel * label = (UILabel *)self.leftView;
		if (!label || ![label isKindOfClass:[UILabel class]]) {
			label = [[UILabel alloc] initWithFrame:CGRectZero];
			[label setTextColor:[UIColor colorWithWhite:0.5 alpha:1]];
			[self setLeftView:label];
			
			[self setLeftViewMode:UITextFieldViewModeAlways];
		}
		
		[label setText:text];
		[label setFont:[UIFont systemFontOfSize:(self.font.pointSize + 1)]];
		[label sizeToFit];
	} else {
		[self setLeftView:nil];
	}
	
	[self updateHeightAnimated:YES];
}

- (void)setAddButtonAction:(SEL)action target:(id)sender {
	
	[self setAddButtonSelector:action];
	[self setAddButtonTarget:sender];
	
	[_addButton setHidden:(!action || !sender)];
	[self setRightViewMode:(_addButton.hidden ? UITextFieldViewModeNever : UITextFieldViewModeAlways)];
}

- (void)performButtonAction {
	
	if (!self.editing) {
        [self becomeFirstResponder];
    }
    //temp remove 
//	[self.addButtonTarget performSelector:addButtonSelector withObject:_addButton];
}

- (CGRect)textRectForBounds:(CGRect)bounds {
	
	if ([self.text isEqualToString:kTextHidden]) {
        return CGRectMake(0, -20, 0, 0);
	}
	CGRect frame = CGRectOffset(bounds, cursorLocation.x, cursorLocation.y + 3);
	frame.size.width -= (cursorLocation.x + 8 + (_addButton.hidden ? 0 : 28));
	
	return frame;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
	return [self textRectForBounds:bounds];
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
	return [self textRectForBounds:bounds];
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds {
	return ((CGRect){{8, ceilf(self.font.lineHeight * 4 / 7)}, self.leftView.bounds.size});
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
	return ((CGRect){{bounds.size.width - _addButton.bounds.size.width - 6,
		bounds.size.height - _addButton.bounds.size.height - 6}, _addButton.bounds.size});
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<TITokenField %p; prompt = \"%@\">", self, ((UILabel *)self.leftView).text];
}

- (void)dealloc {
	[self setDelegate:nil];
}

@end

