//
//  CNewCommentItemView.h
//  Knotable
//
//  Created by Agustin Guerra on 8/12/14.
//
//

#import <Foundation/Foundation.h>
#import "CEditBaseItemView.h"

@interface CNewCommentItemView : CEditBaseItemView

@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UIButton *postCommentButton;
@property (nonatomic, strong) UIActivityIndicatorView *postingCommentActivityIndicatorView;
@property (nonatomic, weak) UITableView *parentTableView;

- (void)endEditing;
- (void)postCommentButtonTapped:(UIButton *)postCommentButton;
- (void)reset;

@end
