//
//  ComposeVote.h
//  Knotable
//
//  Created by backup on 14-1-3.
//
//

#import "ComposeTitleView.h"

@interface ComposeVote : ComposeTitleView
@property (nonatomic, strong) NSMutableArray* itemArray;
@property (nonatomic, assign) ItemLifeCycle lifeCycle;

@end
