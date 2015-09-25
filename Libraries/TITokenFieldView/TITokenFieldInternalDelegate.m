//
//  TITokenFieldInternalDelegate.m
//  Mailer
//
//  Created by wuli on 14-5-12.
//  Copyright (c) 2014年 Knotable. All rights reserved.
//

#import "TITokenFieldInternalDelegate.h"

extern NSString * const kTextHidden; // This character isn't available on iOS (yet) so it's safe.
extern NSString * const kTextEmpty;


@interface TITokenFieldInternalDelegate ()


@end
//==========================================================
#pragma mark - TITokenFieldInternalDelegate -
//==========================================================
@implementation TITokenFieldInternalDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldShouldBeginEditing:)]){
		return [self.delegate textFieldShouldBeginEditing:textField];
	}
	
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]){
		[self.delegate textFieldDidBeginEditing:textField];
	}
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]){
		return [self.delegate textFieldShouldEndEditing:textField];
	}
	
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldDidEndEditing:)]){
		[self.delegate textFieldDidEndEditing:textField];
	}
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
	if (self.tokenField.tokens.count && [string isEqualToString:@""] && [self.tokenField.text isEqualToString:kTextEmpty]){
		[self.tokenField selectToken:[self.tokenField.tokens lastObject]];
		return NO;
	}
	
	if ([textField.text isEqualToString:kTextHidden]){
		[self.tokenField removeToken:self.tokenField.selectedToken];
		return (![string isEqualToString:@""]);
	}
	
	if ([string rangeOfCharacterFromSet:self.tokenField.tokenizingCharacters].location != NSNotFound){
		[self.tokenField tokenizeText];
		return NO;
	}
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]){
		return [self.delegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
	}
	
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	[self.tokenField tokenizeText];
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldShouldReturn:)]){
		[self.delegate textFieldShouldReturn:textField];
	}
	
	return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	
	if (self.delegate && [self.delegate respondsToSelector:@selector(textFieldShouldClear:)]){
		return [self.delegate textFieldShouldClear:textField];
	}
	
	return YES;
}
-(void)setDelegate:(id<UITextFieldDelegate>)delegate
{
    _delegate = delegate;
}
@end

