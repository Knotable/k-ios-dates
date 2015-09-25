//
//  CEditVoteItemView.m
//  RevealControllerProject
//
//  Created by backup on 13-10-16.
//
//

#import "CEditVoteItemView.h"

#import "CEditVoteCell.h"
#import "GMProgressView.h"

#import "CEditVoteInfo.h"
#import "CVoteItem.h"
#import "CUtil.h"
#import "DesignManager.h"

@interface CEditVoteItemView() <UITextFieldDelegate,UITableViewDataSource, UITableViewDelegate, CEditVoteCellDelegate,NSFetchedResultsControllerDelegate>

@property (nonatomic, copy)     NSMutableArray* voteArray;
#if !NEW_DESIGN
@property (nonatomic, retain)   UILabel* titleLabel;
#endif
@property (nonatomic, retain)   IBOutlet UITableView* voteTableView;
@property (strong, nonatomic)   IBOutlet GMProgressView *circularProgressView;

@end

@implementation CEditVoteItemView

@synthesize baseItemDelegate = _baseItemDelegate;
@synthesize likedIds = _likedIds;
@synthesize circularProgressView =_circularProgressView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    //NSLog(@". %@", self);
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
#if !NEW_DESIGN
        if (!_titleLabel)
        {
            _titleLabel = [[UILabel alloc] init];
            _titleLabel.backgroundColor = [UIColor clearColor];
            _titleLabel.numberOfLines = 0;
            _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            _titleLabel.textColor = [DesignManager knoteHeaderTextColor];
        }
#endif
        if (!_voteTableView)
        {
            _voteTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
            _voteTableView.delegate = self;
            _voteTableView.dataSource = self;
            _voteTableView.backgroundColor = [UIColor clearColor];
            _voteTableView.scrollEnabled = NO;
            _voteTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        }
        
        _circularProgressView = [[GMProgressView alloc] initWithFrame:CGRectMake(10, 10, 60, 90) backColor:[UIColor blackColor] progressColor:[UIColor blueColor] lineWidth:3 ];
        _circularProgressView.showProgress = YES;

        self.circularProgressView.progressColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        self.circularProgressView.backColor = [UIColor clearColor];
        self.circularProgressView.backgroundColor = [UIColor clearColor];
        self.circularProgressView.titleLabel.backgroundColor = [UIColor clearColor];

        self.circularProgressView.progress = 0.0;
        
        self.circularProgressView.lineWidth = 30;
        
#if !NEW_DESIGN
        [self.bgView addSubview:_titleLabel];
#endif

        [self.bgView addSubview:_circularProgressView];
        
        [self.bgView addSubview:_voteTableView];

    }
    return self;
}

- (void)reloadVoteData
{
    CVoteItem *item = (CVoteItem *)[self getItemData];
    
    [item.voteList removeAllObjects];
    
    NSInteger count = [_voteTableView numberOfRowsInSection:0];
    
    for (int i = 0; i<count; i++)
    {
        NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
        
        CEditVoteCell *cell = (CEditVoteCell *)[_voteTableView cellForRowAtIndexPath:index];
        
        [cell endEditText];
        
        [item.voteList addObject:cell.contentText];
    }
}

- (void)updateConstraints
{
#if !NEW_DESIGN
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgView);
        make.left.equalTo(self.mas_left).offset(kTheadLeftGap);
        make.right.equalTo(self).offset(-4.0);
        make.height.greaterThanOrEqualTo(@(10));
    }];
#endif
   
    [super updateConstraints];
    
    [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {

        make.top.equalTo(self.mas_top).offset(20);
        
        make.bottom.greaterThanOrEqualTo(    @(-(self.vGap+self.btnBarHeight)));
        make.left.equalTo(      @(self.hGap));
        make.right.equalTo(     @(-(self.hGap)));
    }];
    
    [self.voteTableView mas_updateConstraints:^(MASConstraintMaker *make) {
      
#if NEW_DESIGN
        make.left.equalTo(self.mas_left).offset(4);
        make.right.equalTo(self.mas_right).offset(-4);

        CreplyUtils *cre=[[CreplyUtils alloc]init];
        CGFloat newheight=[cre getHeightOfTitleInfo:_itmTemp.userData];
        make.top.equalTo(self).offset(newheight);
        make.height.equalTo(@(self.voteTableView.contentSize.height));
#else
        make.left.equalTo(self.mas_left).offset(kTheadLeftGap-6);
        make.right.equalTo(self.mas_right);

        make.top.lessThanOrEqualTo(self.titleLabel.mas_bottom);

        if (self.pinButton && !self.pinButton.hidden)
        {
            make.bottom.equalTo(self.pinButton.mas_top);
        }
        else
        {
            make.bottom.equalTo(self.bgView);
        }
        #endif
    }];
    
    [self.circularProgressView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.bgView);
    }];
}



-(void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat startY = self.tGap+6.0;
#if !NEW_DESIGN
    CGFloat ctlHeight = _titleLabel.frame.size.height;
    startY += (ctlHeight+self.vGap);
    ctlHeight = _voteArray.count*kItemDefaultHeight;
#else
   CGFloat ctlHeight = _voteArray.count*kItemDefaultHeight;
#endif
    
}

-(BOOL)canAddItem:(NSString *)text
{
    return NO;
}

-(void)addNewItemAtIndex:(NSInteger)index withContent:(NSString *)text
{
}

-(void)removeVoteCellAtIndex:(NSInteger)index
{
}

- (BOOL) isSomeItemChecked{
    BOOL isFirstVote = YES;
    for(int i=0;i< _voteArray.count;i++)
    {
        CEditVoteInfo *thisInfo = _voteArray[i];
        for (int i = 0; i<[thisInfo.voters count]; i++) {
            NSString *aid = [thisInfo.voters objectAtIndex:i];
            if ([aid isEqualToString:self.my_account_id]) {
                isFirstVote = NO;
                break;
            }
        }
    }

    return isFirstVote;
}

- (void)checkSelected:(BOOL)flag withItem:(CEditVoteCell *)item
{
    NSMutableArray *changeEditArray = [[NSMutableArray alloc] initWithCapacity:3];
    CEditVoteInfo* info = _voteArray[item.index];
    VoteModificationType modificationType ;
    if (!self.isMultiSelected) {
        for(int i=0;i< _voteArray.count;i++)
        {
            if(i!= item.index)
            {
                CEditVoteInfo *thisInfo = _voteArray[i];
                thisInfo.checked = NO;
            }
        }
        
        // for Analytics
        /***********Dhruv :Ignored coz not posting properly**********/
        /*if ([self isSomeItemChecked ]){
            modificationType = newVote;
        }
        else{*/
            modificationType = changeVote;
        //}
        
                    
        BOOL find = NO;
        NSInteger findIndex = -1;
        NSMutableArray *voters = [info.voters mutableCopy];
        NSMutableArray *needMovevoters = nil;
        for (int i = 0; i<[voters count]; i++) {
            NSString *aid = [voters objectAtIndex:i];
            if ([aid isEqualToString:self.my_account_id]) {
                find = YES;
                findIndex = i;
                break;
            }
            
        }
        for(CEditVoteCell *cell in [_voteTableView visibleCells])
        {
            [cell.checkBtn setImage:cell.uncheckedImage forState:UIControlStateNormal ];
        }
        
        
        if (!find && self.my_account_id) {//need add
            [voters addObject:self.my_account_id];
            for (CEditVoteInfo *info in _voteArray) {
                needMovevoters = [info.voters mutableCopy];
                for (int i =0; i<[needMovevoters count];i++) {
                    NSString *voter = [needMovevoters objectAtIndex:i];
                    if ([voter isEqualToString:self.my_account_id]) {
                        [needMovevoters removeObjectAtIndex:i];
                        info.voters = [needMovevoters copy];
                        break;
                    }
                }
            }
        } else {//need remove
            if (findIndex>=0&&findIndex<[voters count]) {
                [voters removeObjectAtIndex:findIndex];
            }
        }
        
       
        info.voters = [voters copy];
    } else {
        modificationType = check;
        info.checked = !info.checked;
    }
    
    for (CEditVoteInfo *info in _voteArray) {
        [changeEditArray addObject:[info dictionary]];
    }
    [_voteTableView reloadData];
    
    [self.baseItemDelegate listItemModify:self withOptionArray:changeEditArray atIndex:self.index withModificationType: modificationType isRight:_isRight];
}

-(void) setItemData:(CItem*) itemData
{
    [super setItemData:itemData];
#if NEW_DESIGN
    _itmTemp=itemData;
#endif
    CVoteItem *vItem = (CVoteItem *)itemData;
    self.voteArray = vItem.voteList;
    CGFloat process = .0f;
    if (itemData.type == C_LIST) {
        self.isMultiSelected = YES;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.checked == YES"];
        NSArray *a = [self.voteArray filteredArrayUsingPredicate:predicate];
        process = ((CGFloat)[a count]*1.0)/(CGFloat)[self.voteArray count];

    } else {
        NSMutableArray *reallVotes = [[NSMutableArray alloc] initWithCapacity:3];
        for (CEditVoteInfo *info in self.voteArray) {
            if (info.voters) {
                [reallVotes addObjectsFromArray:info.voters];
            }
        }
        NSArray *distiArray = [[NSSet setWithArray:reallVotes] allObjects];
        int participantCount = 1;
        if (vItem.topic && vItem.topic.shared_account_ids) {
            participantCount = (int)[vItem.topic.shared_account_ids componentsSeparatedByString:@","].count;
        }
        process = ((CGFloat)[distiArray count])/(CGFloat)participantCount;
        self.isMultiSelected = NO;
    }
    
    _circularProgressView.progress = process;
    [_circularProgressView setNeedsDisplay];
#if !NEW_DESIGN
    _titleLabel.font = vItem.titleFont;
    _titleLabel.text = vItem.title;
#endif
    [_voteTableView reloadData];
}

-(CItem*) getItemData
{
    return [super getItemData];
}

#pragma mark UITableViewDateSource && delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_voteArray == nil) return 0;
    return [_voteArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kItemDefaultHeight;
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
    // Code kept for older look: rounded corner square for all entries.
    /*
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
     */
    
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    CGRect bounds = CGRectInset(cell.bounds, 5, 0);
    
    if (indexPath.row < [tableView numberOfRowsInSection:indexPath.section]-1) {
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
	CEditVoteCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (nil == cell)
	{
		cell = [[CEditVoteCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
	}
    cell.backgroundColor = [UIColor clearColor];
    CEditVoteInfo* info = _voteArray[indexPath.row];
    cell.index = [indexPath row];
    cell.my_account_id = self.my_account_id;
    cell.participators = self.participators;
    [cell setInfo:info tableView:tableView forRowAtIndexPath:indexPath];

    [cell setVoteDelegate:self];
    if (indexPath.row == _voteArray.count - 1)
    {
        [cell setAddable];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void) endTextEdit
{
    for (int i = 0; i < _voteArray.count; i++)
    {
        CEditVoteCell* cell = (CEditVoteCell*) [_voteTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        [cell endEditText];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    CVoteItem *item = (CVoteItem *)[self getItemData];
    item.title = textField.text;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    CVoteItem *item = (CVoteItem *)[self getItemData];
    item.title = textField.text;
	return [textField resignFirstResponder];
}

- (void)needShowMenu:(BOOL)flag
{
//    [self showMenuView:flag withAnimated:YES];
}
- (BOOL)canShowMenu
{
    return NO;
}

-(BOOL)isFirstResponder
{
    BOOL flag = NO;
    NSInteger count = [_voteTableView numberOfRowsInSection:0];
    for (int i = 0; i<count; i++) {
        NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
        CEditVoteCell *cell = (CEditVoteCell *)[_voteTableView cellForRowAtIndexPath:index];
        if ([cell isKindOfClass:[CEditVoteCell class]]) {
            if ([cell.tfVote isFirstResponder]) {
                flag = YES;
                break;
            }
        }
    }
    return flag;
}
-(BOOL)resignFirstResponder
{
    BOOL flag = NO;
    if (!flag) {
        NSInteger count = [_voteTableView numberOfRowsInSection:0];
        for (int i = 0; i<count; i++) {
            NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
            CEditVoteCell *cell = (CEditVoteCell *)[_voteTableView cellForRowAtIndexPath:index];
            if ([cell isKindOfClass:[CEditVoteCell class]]) {
                [cell endEditText];
            }
        }
    }
    return flag;
}

@end
