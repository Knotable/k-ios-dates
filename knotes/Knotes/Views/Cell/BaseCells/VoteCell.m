//
//  VoteCell.m
//  Knotable
//
//  Created by Martin Ceperley on 12/23/13.
//
//

#import "VoteCell.h"
#import "MessageEntity.h"
#import "DesignManager.h"
#import "THProgressView.h"
#import "CUtil.h"
#import "VoteItemCell.h"

@interface VoteCell ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UIView* choicesView;

@property (nonatomic, strong) NSMutableArray* voteOptions;
@property (nonatomic, strong) NSMutableArray* voteRows;

@property (nonatomic, retain) IBOutlet UITableView* voteTableView;
@property (nonatomic, copy) NSMutableArray* voteArray;

@end

@implementation VoteCell

const int BOTTOM_LINE_TAG = 11;

- (id)init
{
    self = [super init];
    if (self) {
        
        _voteOptions = [[NSMutableArray alloc] init];
        _voteRows = [[NSMutableArray alloc] init];

        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = [DesignManager knoteBodyTextColor];
        _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16]/*[UIFont boldSystemFontOfSize:16.0]*/;
        _titleLabel.backgroundColor = [UIColor clearColor];
        
        [self.bodyView addSubview:_titleLabel];
        
        _choicesView = [UIView new];
        _choicesView.backgroundColor = [UIColor clearColor];
        [self.bodyView addSubview:_choicesView];
        
        if (!_voteTableView) {
            _voteTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
            _voteTableView.delegate = self;
            _voteTableView.dataSource = self;
            _voteTableView.backgroundColor = [UIColor clearColor];
            _voteTableView.scrollEnabled = NO;
            _voteTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            if ([[UIDevice currentDevice].systemVersion floatValue] >= 7){
                self.voteTableView.contentInset = UIEdgeInsetsMake(-28, 0, 0, 0);
            }
        }
        [self.bodyView addSubview:_voteTableView];
        _voteTableView.userInteractionEnabled = NO;
    
    }
    return self;
}

- (void)setMessage:(MessageEntity *)message
{
    [super setMessage:message];
    
    self.titleLabel.text = message.title;
    
    NSArray *choices = [NSKeyedUnarchiver unarchiveObjectWithData:message.content];
    
    UIImage *checkImage = [UIImage imageNamed:@"uncheck_btn"];

    _voteOptions = [choices mutableCopy];
    [_voteRows removeAllObjects];
    
    
    for (UIView *row in _choicesView.subviews) {
        [row removeFromSuperview];
    }
    self.didSetupConstraints = NO;
    
    if (_voteOptions && _voteOptions.count > 0) {
        for (NSDictionary *choice in _voteOptions) {
            NSString *name = choice[@"name"];
            if (name == (id)[NSNull null]) {
                NSLog(@"ROW WITH NULL NAME knote id: %@", message.message_id);
                continue;
            }
            
            UIView *choiceRow = [[UIView alloc] initWithFrame:CGRectZero];
            choiceRow.backgroundColor = [UIColor clearColor];
     
            UILabel *choiceNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            choiceNameLabel.backgroundColor = [UIColor clearColor];
            choiceNameLabel.textColor = [DesignManager knoteBodyTextColor];
            choiceNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12]/*[UIFont systemFontOfSize:12.0]*/;
            choiceNameLabel.text = name;
            
            [choiceRow addSubview:choiceNameLabel];
            
            UIButton *choiceButton = [[UIButton alloc] initWithFrame:CGRectZero];
            NSArray *voters = choice[@"voters"];
            if (message.type == C_LIST) {
                if ([voters count]>0) {
                    checkImage = [UIImage imageNamed:@"check_btn"];
                }
                [choiceButton setImage:checkImage forState:UIControlStateNormal];
            } else if (message.type == C_VOTE) {
                for (NSString *vote in voters) {
                    if ([vote isKindOfClass:[NSString class]]) {
                        if ([vote isEqualToString:self.my_account_id]) {
                            checkImage = [UIImage imageNamed:@"check_btn"];
                            break;
                        }
                    }
                }
                [choiceButton setImage:checkImage forState:UIControlStateNormal];
                THProgressView *progressView = [[THProgressView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-20, 200, 20)];
                progressView.borderTintColor = kCustomColorBlue;
                progressView.progressTintColor = kCustomColorBlue;
                
                CGFloat process = 0.0f;
                if (voters && [voters count]>0 && self.participators && [self.participators count]>0) {
                    process = ((CGFloat)[voters count]*1.0)/(CGFloat)[self.participators count];
                }
                progressView.progress = process;
                
                [choiceRow addSubview:progressView];
                [progressView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(@(60.0));
                    make.right.equalTo(choiceRow.mas_right).offset(-6);
                    make.centerY.equalTo(choiceRow.mas_centerY);
                    make.height.equalTo(@8.0);
                }];
            }
            [choiceButton setImage:checkImage forState:UIControlStateNormal];
            
            [choiceRow addSubview:choiceButton];
            
            UIView *topLine = [[UIView alloc] initWithFrame:CGRectZero];
            topLine.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
            [choiceRow addSubview:topLine];
            
            UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectZero];
            bottomLine.backgroundColor = topLine.backgroundColor;
            bottomLine.hidden = YES;
            bottomLine.tag = BOTTOM_LINE_TAG;
            [choiceRow addSubview:bottomLine];
            
            [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@0.0);
                make.right.equalTo(@0.0);
                make.top.equalTo(@0.0);
                make.height.equalTo(@1.0);
            }];
            
            [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@0.0);
                make.right.equalTo(@0.0);
                make.bottom.equalTo(@0.0);
                make.height.equalTo(@1.0);
            }];

            [choiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@8.0);
                make.centerY.equalTo(choiceRow);
            }];
            
            [choiceNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(choiceButton.mas_right).with.offset(12.0);
                make.centerY.equalTo(choiceRow);

            }];
            
            [_choicesView addSubview:choiceRow];
            [_voteRows addObject:choiceRow];
        }
        
    }
    
     
}

- (void)updateConstraints
{
    if (!self.didSetupConstraints){

        [super updateConstraints];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@6.0);
            make.left.equalTo(self.bodyView);
            make.right.equalTo(self.bodyView);
        }];
        [self.choicesView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).with.offset(12.0);
            make.left.equalTo(self.titleLabel);
            make.right.equalTo(self.titleLabel);
            make.bottom.equalTo(@0.0);
        }];
        [self.voteTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bodyView);
            make.right.equalTo(self.bodyView);
            make.top.equalTo(self.titleLabel.mas_bottom).offset(4.0);
            make.bottom.equalTo(self.bodyView);
        }];
        
        for (int i = 0; i < _voteRows.count; i++) {
            UIView *row = _voteRows[i];
            UIView *rowAbove = nil;
            if (i > 0) {
                rowAbove = _voteRows[i-1];
            }
            [row mas_makeConstraints:^(MASConstraintMaker *make) {
                row.hidden = YES;
                if (rowAbove) {
                    make.top.equalTo(rowAbove.mas_bottom).with.offset(0.0);
                } else {
                    make.top.equalTo(@0.0);
                }
                
                make.height.equalTo(@40.0);
                make.left.equalTo(@0.0);
                make.right.equalTo(@0.0);
                
                UIView *bottomLine = [row viewWithTag:BOTTOM_LINE_TAG];
                if (i == _voteRows.count - 1) {
                    make.bottom.equalTo(@0.0);
                    bottomLine.hidden = NO;
                } else {
                    bottomLine.hidden = YES;
                }
            }];
        }
    } else {
        [super updateConstraints];

    }
}


#pragma mark UITableViewDateSource && delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_voteOptions == nil) return 0;
    return [_voteOptions count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 38;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(tintColor)])
    {
        cell.backgroundColor = UIColor.clearColor;
        CAShapeLayer *layer = [self tableView:tableView layerForCell:cell forRowAtIndexPath:indexPath withColor:cell.backgroundColor];
        CGRect bounds = CGRectInset(cell.bounds, 5, 0);
        UIView *testView = [[UIView alloc] initWithFrame:bounds];
        [testView.layer insertSublayer:layer atIndex:0];
        testView.backgroundColor = UIColor.clearColor;
        cell.backgroundView = testView;
        cell.selectedBackgroundView = [self backgroundCellView:cell indexPath:indexPath tableView:tableView];
    }
}
- (UIView *)backgroundCellView:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    CAShapeLayer *layer = [self tableView:tableView layerForCell:cell forRowAtIndexPath:indexPath withColor:[UIColor redColor]];
    CGRect bounds = CGRectInset(cell.bounds, 5, 0);
    UIView *testView = [[UIView alloc] initWithFrame:bounds];
    [testView.layer insertSublayer:layer atIndex:0];
    return testView;
}

- (CAShapeLayer *)tableView:(UITableView *)tableView layerForCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withColor:(UIColor *)color
{
    CGFloat cornerRadius = 6.f;
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    CGMutablePathRef pathRef = CGPathCreateMutable();
    CGRect bounds = CGRectInset(cell.bounds, 5, 0);
    BOOL addLine = NO;
    if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
        CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
    } else if (indexPath.row == 0) {
        CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
        CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
        addLine = YES;
    } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
        CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
        CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
        CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
    } else {
        CGPathAddRect(pathRef, nil, bounds);
        addLine = YES;
    }
    layer.path = pathRef;
    CFRelease(pathRef);
    
    layer.strokeColor = tableView.separatorColor.CGColor;
    layer.fillColor = color.CGColor;
    layer.lineWidth = 0.8;
    if (addLine == YES) {
        CALayer *lineLayer = [[CALayer alloc] init];
        CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
        lineLayer.frame = CGRectMake(CGRectGetMinX(bounds), bounds.size.height-lineHeight, bounds.size.width, lineHeight);
        lineLayer.backgroundColor = tableView.separatorColor.CGColor;
        [layer addSublayer:lineLayer];
    }
    return layer;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
	VoteItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (nil == cell)
	{
		cell = [[VoteItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
	}
    cell.backgroundColor = [UIColor redColor];
    NSDictionary* info = _voteOptions[indexPath.row];
    cell.type = self.message.type;
    cell.index = [indexPath row];
    cell.my_account_id = self.my_account_id;
    cell.participators = self.participators;
    [cell setInfo:info tableView:tableView forRowAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

@end
