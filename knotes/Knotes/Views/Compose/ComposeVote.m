//
//  ComposeVote.m
//  Knotable
//
//  Created by backup on 14-1-3.
//
//

#import "ComposeVote.h"
#import "CheckListCell.h"
#import "SVProgressHUD.h"
#import "InputAccessViewManager.h"

@interface ComposeVote ()
<
CheckListCellDelegate,
UITableViewDataSource,
UITableViewDelegate,
UITextFieldDelegate
>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, weak) CheckListCell *lastEditingItem;

@end

@implementation ComposeVote

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        self.itemArray = [[NSMutableArray alloc] initWithCapacity:3];
        
        self.tableView.frame = CGRectMake(0, 60, 320, self.frame.size.height - 60);
        
        NSLog(@"%@", NSStringFromCGRect(self.tableView.frame));
        
        [self addSubview:self.tableView];
        
        self.inputText.delegate = self;
        
//      self.inputText.backgroundColor = [UIColor redColor];
        
    }
    
    return self;
}

#pragma mark UITableViewDateSource && delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_itemArray == nil) return 0;
    
    return [_itemArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 38;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CheckListCell";
    
    CheckListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == Nil)
    {
        cell = [[CheckListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    CEditVoteInfo* info = _itemArray[indexPath.row];
    
    cell.index = [indexPath row];
    
    [cell setInfo:info];
    
    cell.delegate = self;
    
    if (indexPath.row == ([_itemArray count] - 1))
    {
        NSLog(@"Index : %d", indexPath.row);
        
        [cell setAddable:![self.inputText isFirstResponder]];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark Vote

- (BOOL)canAddItem:(NSString *)text
{
    return YES;
}

-(void)removeVoteCellAtIndex:(NSInteger)index
{
    [_itemArray removeObjectAtIndex:index];
    [_tableView reloadData];
}

-(void)checkSelected:(BOOL)flag withItem:(CheckListCell *)item
{
}

- (BOOL)checkIsInlist
{
    BOOL dupFlag = NO;
    
    for (int i = 0; i<[_itemArray count]; i++)
    {
        NSString *str = [[_itemArray objectAtIndex:i] name];
        
        for (int j = 0; j<[_itemArray count]; j++)
        {
            if (i!=j)
            {
                if ([str isEqualToString:[[_itemArray objectAtIndex:j] name]])
                {
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Duplicated item:%@",
                                                        [[_itemArray objectAtIndex:i] name]]
                                              duration:1.2];
                    
                    dupFlag = YES;
                    
                    break;
                }
            }
        }
    }
    
    return !dupFlag;
}

- (BOOL) addNewItemAtIndex:(NSInteger)index withContent:(NSString *)text
{
    BOOL retVal = NO;
    
    self.tableView.frame = CGRectMake(0, 60, 320, self.frame.size.height - 60);

    if ([self checkIsInlist])
    {
        retVal =  YES;
        
        CEditVoteInfo* info = [[CEditVoteInfo alloc] init];
        
        info.editor = YES;
        
        if (!info.name)
        {
            info.name = @"";
        }
        
        info.checked = NO;
        
        [_itemArray addObject:info];
        
        // Reload Table part
        
        [_tableView beginUpdates];
        
        NSInteger newRow = [_itemArray count] - 1;
        NSInteger newSection = 0;
        
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:newRow inSection:newSection];
        
        [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [_tableView endUpdates];

        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        dispatch_time_t local_popTime = dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC);
        dispatch_after(local_popTime, dispatch_get_main_queue(), ^(void){
            
            CheckListCell *cell = (CheckListCell*)[_tableView cellForRowAtIndexPath:indexPath];
            
            [cell setAddable:![self.inputText isFirstResponder]];
            
        });
    }
    
    return retVal;
}

-(void)itemBeginEditing:(CheckListCell *)obj
{
    self.lastEditingItem = obj;
    
    //If user is composing new PAD than we have to show the Toolbar on top of KeyBoard. @malik
    if (self.lifeCycle == ItemNew) {
        obj.inputText.inputAccessoryView = [[InputAccessViewManager sharedInstance] inputAccessViewWithOutCamera];
    }else
    {
        obj.inputText.inputAccessoryView = nil;
    }

}

-(void)removeFromSuperview
{
    [self.inputText resignFirstResponder];
    
    [self.lastEditingItem resignFirstResponder];
    
    [super removeFromSuperview];
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.inputText.mas_bottom).offset(kVGap);
        make.left.equalTo(  @(kHGap));
        make.right.equalTo(     @(-kHGap));
        make.bottom.equalTo(self.mas_bottom).offset(-kVGap);
    }];
    
}

#pragma mark ComposeProtocol

- (void)setTitlePlaceHold:(NSString *)str
{
    if (str && [str length]>0)
    {
        self.inputText.placeholder = str;
    }
}

- (void)setTitleContent:(NSString *)str
{
    if (str && [str length]>0)
    {
        self.inputText.text = str;
    }
}

- (void)setCotent:(id)content
{
}

- (id)getCotent
{
    [self.lastEditingItem endEditText];
    
    return self.itemArray;
}

- (NSString *)getTitle
{
    [self.inputText endEditing:YES];
    
    return self.inputText.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

-(BOOL)becomeFirstResponder
{
    self.inputText.inputAccessoryView =[[InputAccessViewManager sharedInstance] inputAccessViewWithOutCamera];
    
    return [self.inputText becomeFirstResponder];
}

@end
