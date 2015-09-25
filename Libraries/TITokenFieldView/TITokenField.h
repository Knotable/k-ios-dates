//
//  TITokenField.h
//  Mailer
//
//  Created by wuli on 14-5-12.
//  Copyright (c) 2014年 Knotable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TITokenFieldDelegate.h"
#import "TIToken.h"
@class TITokenFieldInternalDelegate;
//==========================================================
#pragma mark - TITokenField -
//==========================================================
@interface TITokenField : UITextField {
	
	
	NSMutableArray * tokens;
	
	BOOL editable;
	BOOL resultsModeEnabled;
	BOOL removesTokensOnEndEditing;
	
	CGPoint cursorLocation;
	int numberOfLines;
		
	SEL addButtonSelector;
	
	NSCharacterSet * tokenizingCharacters;
}

@property (nonatomic, weak) id <TITokenFieldDelegate> delegate;
@property (nonatomic,strong) TITokenFieldInternalDelegate * internalDelegate;
@property (nonatomic, readonly) NSArray * tokens;
@property (nonatomic, readonly) TIToken * selectedToken;
@property (nonatomic, readonly) NSArray * tokenObjects;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, assign) BOOL resultsModeEnabled;
@property (nonatomic, assign) BOOL removesTokensOnEndEditing;
@property (nonatomic, readonly) int numberOfLines;
@property (nonatomic, assign) SEL addButtonSelector;
@property (nonatomic, retain) NSCharacterSet * tokenizingCharacters;
@property (nonatomic, weak) id addButtonTarget;
@property (nonatomic, readonly) NSArray * tokenTitles;
@property (nonatomic, strong) UIView * separator;

@property (nonatomic, strong) UIButton * addButton;
- (void)addToken:(TIToken *)title;
- (TIToken *)addTokenWithTitle:(NSString *)title;
- (void)removeToken:(TIToken *)token;

- (void)selectToken:(TIToken *)token;
- (void)deselectSelectedToken;

- (void)tokenizeText;

- (CGFloat)layoutTokens;
- (void)setResultsModeEnabled:(BOOL)enabled animated:(BOOL)animated;

// Pass nil to any argument in either method to hide the related button.
- (void)setAddButtonAction:(SEL)action target:(id)sender;
- (void)setPromptText:(NSString *)aText;

@end
