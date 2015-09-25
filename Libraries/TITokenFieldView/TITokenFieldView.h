//
//  TITokenFieldView.h
//  TITokenFieldView
//
//  Created by Tom Irving on 16/02/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without modification,
//	are permitted provided that the following conditions are met:
//
//		1. Redistributions of source code must retain the above copyright notice, this list of
//		   conditions and the following disclaimer.
//
//		2. Redistributions in binary form must reproduce the above copyright notice, this list
//         of conditions and the following disclaimer in the documentation and/or other materials
//         provided with the distribution.
//
//	THIS SOFTWARE IS PROVIDED BY TOM IRVING "AS IS" AND ANY EXPRESS OR IMPLIED
//	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//	FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL TOM IRVING OR
//	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//	ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <UIKit/UIKit.h>

#import "TITokenFieldDelegate.h"
@class TITokenField, TIToken;

//==========================================================
#pragma mark - Delegate Methods -
//==========================================================
@protocol TITokenFieldViewDelegate <UIScrollViewDelegate>
@optional
- (void)tokenField:(TITokenField *)tokenField didChangeToFrame:(CGRect)frame;
- (void)tokenField:(TITokenField *)tokenField didFinishSearch:(NSArray *)matches;
- (NSString *)tokenField:(TITokenField *)tokenField displayStringForRepresentedObject:(id)object;
- (NSString *)tokenField:(TITokenField *)tokenField searchResultStringForRepresentedObject:(id)object;
- (UITableViewCell *)tokenField:(TITokenField *)tokenField resultsTableView:(UITableView *)tableView cellForRepresentedObject:(id)object;
- (CGFloat)tokenField:(TITokenField *)tokenField resultsTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
@end





//==========================================================
#pragma mark - TITokenFieldView -
//==========================================================
@interface TITokenFieldView : UIScrollView <UITableViewDelegate, UITableViewDataSource, TITokenFieldDelegate> {
    
    NSArray * sourceArray;
	
    UIPopoverController * popoverController;
}

@property (nonatomic, assign) BOOL showAlreadyTokenized;
@property (nonatomic, weak) id <TITokenFieldViewDelegate> tokenDelegate;
@property (nonatomic, strong) TITokenField * tokenField;
@property (nonatomic, strong) TITokenField * tokenFieldCC;
@property (nonatomic, strong) TITokenField * tokenFieldBCC;
@property (nonatomic, weak) TITokenField * currTKField;
@property (nonatomic, copy) NSArray * sourceArray;
@property (nonatomic, strong) NSMutableArray * resultsArray;
@property (nonatomic, strong) UIView * contentView;

- (void)updateContentSize;

@end



