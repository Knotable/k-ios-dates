//
//  TITokenFieldView.m
//  TITokenFieldView
//
//  Created by Tom Irving on 16/02/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//

#import "TITokenFieldView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+TIToken.h"
#import "TITokenField.h"
#import "TIToken.h"
#import "TITokenConfig.h"
#define kDefaultFieldHeight (42)
//==========================================================
#pragma mark - Private Additions -
//==========================================================



//==========================================================
#pragma mark - TITokenFieldView -
//==========================================================
@interface TITokenFieldView ()
@property (nonatomic, strong) UITableView * resultsTable;
@end
@interface TITokenFieldView (Private)
- (NSString *)displayStringForRepresentedObject:(id)object withTokenField:(TITokenField *)tokenField;
- (NSString *)searchResultStringForRepresentedObject:(id)object withTokenField:(TITokenField *)tokenField;
- (void)setSearchResultsVisible:(BOOL)visible;
- (void)resultsForSubstring:(NSString *)substring forTokenField:(TITokenField *)tokenField;
- (void)presentpopoverAtTokenFieldCaretAnimated:(BOOL)animated;
@end

@implementation TITokenFieldView
@synthesize sourceArray;

#pragma mark Main Shit
- (id)initWithFrame:(CGRect)frame {
	
    if ((self = [super initWithFrame:frame])){
		
		[self setBackgroundColor:[UIColor clearColor]];
		[self setDelaysContentTouches:YES];
		[self setMultipleTouchEnabled:NO];
		
		self.showAlreadyTokenized = NO;
		self.resultsArray = [[NSMutableArray alloc] init];
		
		self.tokenField = [[TITokenField alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, kDefaultFieldHeight)];
		[_tokenField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
		[_tokenField setDelegate:self];
		[self addSubview:_tokenField];
        
        self.tokenFieldCC = [[TITokenField alloc] initWithFrame:CGRectMake(0, kDefaultFieldHeight, frame.size.width, kDefaultFieldHeight)];
		[_tokenFieldCC addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
		[_tokenFieldCC setDelegate:self];
        [_tokenFieldCC setPromptText:@"Cc:"];

		[self addSubview:_tokenFieldCC];
        
        self.tokenFieldBCC = [[TITokenField alloc] initWithFrame:CGRectMake(0, 2*kDefaultFieldHeight, frame.size.width, kDefaultFieldHeight)];
		[_tokenFieldBCC addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
		[_tokenFieldBCC setDelegate:self];
        [_tokenFieldBCC setPromptText:@"Bcc:"];
        
		[self addSubview:_tokenFieldBCC];
        
        
        
		CGFloat tokenFieldBottom = CGRectGetMaxY(_tokenFieldBCC.frame);
		

		
		// This view is created for convenience, because it resizes and moves with the rest of the subviews.
		self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, tokenFieldBottom + 1, self.bounds.size.width,
															   self.bounds.size.height - tokenFieldBottom - 1)];
		[_contentView setBackgroundColor:[UIColor clearColor]];
		[self addSubview:_contentView];
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
			
			UITableViewController * tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
			[tableViewController.tableView setDelegate:self];
			[tableViewController.tableView setDataSource:self];
#if IOS7_API
            [tableViewController setPreferredContentSize:CGSizeMake(400, 400)];
#else
			[tableViewController setContentSizeForViewInPopover:CGSizeMake(400, 400)];
#endif
			
			self.resultsTable = tableViewController.tableView;
			
			popoverController = [[UIPopoverController alloc] initWithContentViewController:tableViewController];
		}
		else
		{
			self.resultsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, tokenFieldBottom + 1, self.bounds.size.width, 10)];
			[_resultsTable setSeparatorColor:[UIColor colorWithWhite:0.85 alpha:1]];
			[_resultsTable setBackgroundColor:[UIColor colorWithRed:0.92 green:0.92 blue:0.92 alpha:1]];
			[_resultsTable setDelegate:self];
			[_resultsTable setDataSource:self];
			[_resultsTable setHidden:YES];
			[self addSubview:_resultsTable];
			
			popoverController = nil;
		}
		
		[self bringSubviewToFront:_tokenField];
		[self updateContentSize];
	}
	
    return self;
}

- (void)setFrame:(CGRect)frame {
	
	[super setFrame:frame];
	
	CGFloat width = frame.size.width;
	[_resultsTable ti_setWidth:width];
	[_contentView ti_setWidth:width];
	[_contentView ti_setHeight:(frame.size.height - CGRectGetHeight(_tokenFieldBCC.bounds)- CGRectGetHeight(_tokenFieldCC.bounds) - CGRectGetHeight(_tokenField.bounds))];
	[_tokenField ti_setWidth:width];
    [_tokenFieldCC ti_setWidth:width];
    [_tokenFieldBCC ti_setWidth:width];

	if (popoverController.popoverVisible){
		[popoverController dismissPopoverAnimated:NO];
		[self presentpopoverAtTokenFieldCaretAnimated:NO];
	}
	
	[self updateContentSize];
	[self layoutSubviews];
}

- (void)setContentOffset:(CGPoint)offset {
	[super setContentOffset:offset];
	[self layoutSubviews];
}

- (void)layoutSubviews {
	
	[super layoutSubviews];
	
	CGFloat relativeFieldHeight = CGRectGetMaxY(self.currTKField.frame) - self.contentOffset.y;
	CGFloat newHeight = self.bounds.size.height - relativeFieldHeight;
	if (newHeight > -1) {
        [_resultsTable ti_setHeight:newHeight];
    }
}

- (void)updateContentSize {
	[self setContentSize:CGSizeMake(self.bounds.size.width, self.contentView.frame.origin.y + self.contentView.bounds.size.height + 1)];
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (BOOL)becomeFirstResponder {
    self.currTKField = _tokenField;
	return [_tokenField becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    self.currTKField = nil;
	return [_tokenField resignFirstResponder];
}


-(void)setTokenDelegate:(id<TITokenFieldViewDelegate>)tokenDelegate
{
    if (_tokenDelegate != tokenDelegate) {
        _tokenDelegate = tokenDelegate;
    }
}
//wuli check
//- (void)setDelegate:(id<TITokenFieldViewDelegate>)del {
//	_delegate = del;
//	[super setDelegate:_delegate];
//}

#pragma mark TableView Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (self.tokenDelegate && [self.tokenDelegate respondsToSelector:@selector(tokenField:resultsTableView:heightForRowAtIndexPath:)]){
		return [self.tokenDelegate tokenField:_tokenField resultsTableView:tableView heightForRowAtIndexPath:indexPath];
	}
	
	return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if (self.tokenDelegate && [self.tokenDelegate respondsToSelector:@selector(tokenField:didFinishSearch:)]){
		[self.tokenDelegate tokenField:self.currTKField didFinishSearch:_resultsArray];
	}
	
	[self setSearchResultsVisible:(_resultsArray.count > 0)];
	return _resultsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	id representedObject = [_resultsArray objectAtIndex:indexPath.row];
	
	if (self.tokenDelegate && [self.tokenDelegate respondsToSelector:@selector(tokenField:resultsTableView:cellForRepresentedObject:)]){
		return [self.tokenDelegate tokenField:self.currTKField resultsTableView:tableView cellForRepresentedObject:representedObject];
	}
	
    static NSString * CellIdentifier = @"ResultsCell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	[cell.textLabel setText:[self searchResultStringForRepresentedObject:representedObject withTokenField:self.currTKField]];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	id representedObject = [_resultsArray objectAtIndex:indexPath.row];
    
	TIToken * token = [self.currTKField addTokenWithTitle:[self displayStringForRepresentedObject:representedObject withTokenField:self.currTKField]];
	[token setRepresentedObject:representedObject];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self setSearchResultsVisible:NO];

}

#pragma mark TextField Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	[_resultsArray removeAllObjects];
	[_resultsTable reloadData];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.currTKField =(TITokenField *) textField;
	[_resultsTable reloadData];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.currTKField = nil;
	[self setSearchResultsVisible:NO];
}

- (void)textFieldDidChange:(UITextField *)textField {
    CGFloat currentFieldBottom = CGRectGetMaxY(textField.frame);//wuli check
    [_resultsTable ti_setOriginY:(currentFieldBottom + 1)];

    CGFloat fieldBottom = CGRectGetMaxY(self.tokenFieldBCC.frame);//wuli check
    [_contentView ti_setOriginY:(fieldBottom + 1)];

	[self resultsForSubstring:textField.text forTokenField:(TITokenField *)textField];
}

- (void)tokenFieldWillResize:(TITokenField *)aTokenField animated:(BOOL)animated {
	
    [_tokenFieldCC ti_setOriginY:CGRectGetMaxY(self.tokenField.frame)];
    [_tokenFieldBCC ti_setOriginY:CGRectGetMaxY(self.tokenFieldCC.frame)];
    CGFloat tokenFieldBottom = CGRectGetMaxY(_tokenFieldBCC.frame);
	[_contentView ti_setOriginY:(tokenFieldBottom + 1)];
}

- (void)tokenFieldDidResize:(TITokenField *)aTokenField animated:(BOOL)animated {
	
	[self updateContentSize];
	
	if (self.tokenDelegate && [self.tokenDelegate respondsToSelector:@selector(tokenField:didChangeToFrame:)]){
		[self.tokenDelegate tokenField:aTokenField didChangeToFrame:aTokenField.frame];
	}
}

#pragma mark Results Methods
- (NSString *)displayStringForRepresentedObject:(id)object withTokenField:(TITokenField *)tokenField {
	
	if (self.tokenDelegate && [self.tokenDelegate respondsToSelector:@selector(tokenField:displayStringForRepresentedObject:)]){
		return [self.tokenDelegate tokenField:tokenField displayStringForRepresentedObject:object];
	}
	
	if ([object isKindOfClass:[NSString class]]){
		return (NSString *)object;
	}
	
	return [NSString stringWithFormat:@"%@", object];
}

- (NSString *)searchResultStringForRepresentedObject:(id)object withTokenField:(TITokenField *)tokenField{
	
	if (self.tokenDelegate && [self.tokenDelegate respondsToSelector:@selector(tokenField:searchResultStringForRepresentedObject:)]){
		return [self.tokenDelegate tokenField:self.currTKField searchResultStringForRepresentedObject:object];
	}
	
	return [self displayStringForRepresentedObject:object withTokenField:self.currTKField];
}

- (void)setSearchResultsVisible:(BOOL)visible {
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
		
		if (visible) [self presentpopoverAtTokenFieldCaretAnimated:YES];
		else [popoverController dismissPopoverAnimated:YES];
	}
	else
	{
		[_resultsTable setHidden:!visible];
		[self.currTKField setResultsModeEnabled:visible];
	}
}

- (void)resultsForSubstring:(NSString *)substring forTokenField:(TITokenField *)tokenField
{
	
	// The brute force searching method.
	// Takes the input string and compares it against everything in the source array.
	// If the source is massive, this could take some time.
	// You could always subclass and override this if needed or do it on a background thread.
	// GCD would be great for that.
	
	[_resultsArray removeAllObjects];
	[_resultsTable reloadData];
	
	NSString * strippedString = [substring stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	NSArray * sourceCopy = [sourceArray copy];
	for (NSString * sourceObject in sourceCopy){
		
		NSString * query = [[self searchResultStringForRepresentedObject:sourceObject withTokenField:tokenField] lowercaseString];
		if ([query rangeOfString:strippedString].location != NSNotFound){
			
			BOOL shouldAdd = YES;
			
			if (!_showAlreadyTokenized){
				
				for (TIToken * token in tokenField.tokens){
					
					if ([token.representedObject isEqual:sourceObject]){
						shouldAdd = NO;
						break;
					}
				}
			}
			
			if (shouldAdd){
				if (![_resultsArray containsObject:sourceObject]){
					[_resultsArray addObject:sourceObject];
				}
			}
		}
	}
	[_resultsArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		return [[self searchResultStringForRepresentedObject:obj1 withTokenField:tokenField] localizedCaseInsensitiveCompare:[self searchResultStringForRepresentedObject:obj2 withTokenField:tokenField]];
	}];
	[_resultsTable reloadData];
}

- (void)presentpopoverAtTokenFieldCaretAnimated:(BOOL)animated {
	
    UITextPosition * position = [self.currTKField positionFromPosition:self.currTKField.beginningOfDocument offset:2];
    CGRect caretRect = [self.currTKField caretRectForPosition:position];
	
	[popoverController presentPopoverFromRect:caretRect inView:self.currTKField
					 permittedArrowDirections:UIPopoverArrowDirectionUp animated:animated];
}

#pragma mark - Other stuff

- (NSString *)description {
	return [NSString stringWithFormat:@"<TITokenFieldView %p; Token count = %lu CCToken count = %lu BCCToken count = %lu>",
            self,
            (unsigned long)self.tokenField.tokenTitles.count,
            (unsigned long)self.tokenFieldCC.tokenTitles.count,
            (unsigned long)self.tokenFieldBCC.tokenTitles.count
            ];
}

- (void)dealloc {
	[self setDelegate:nil];
}

@end




