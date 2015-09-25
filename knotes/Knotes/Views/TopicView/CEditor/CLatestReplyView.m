//
//  CLatestReplyView.m
//  Knotable
//
//  Created by Dhruv on 3/23/15.
//
//

#import "CLatestReplyView.h"
#import "MessageEntity.h"
#import "UIImage+FontAwesome.h"

@implementation CLatestReplyView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.btn_Reply=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 200, 20)];

        [self.btn_Reply setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.btn_Reply.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.0]];
        
        [self.btn_Reply setImage:[UIImage imageWithIcon:@"fa-comment-o" backgroundColor:[UIColor clearColor] iconColor:[UIColor grayColor] andSize:CGSizeMake(22, 22)] forState:UIControlStateNormal];
        
        
        [self.btn_Reply addTarget:self action:@selector(tapOnReply) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.btn_Reply];
        _arrOfComments=[[NSMutableArray alloc]init];
        self.tblOfComments=[[UITableView alloc]init];
        self.tblOfComments.delegate=self;
        self.tblOfComments.dataSource=self;
        self.tblOfComments.bounces = NO;        
        self.tblOfComments.separatorStyle=UITableViewCellSeparatorStyleNone;
        [self addSubview:self.tblOfComments];
    }
    return self;
}
-(void)setItemData:(CItem *)itemData
{
    _itemData=itemData;
    
    if (itemData.userData.replys)
    {
        _arrOfComments= [NSKeyedUnarchiver unarchiveObjectWithData:itemData.userData.replys];
    }
    else
    {
        _arrOfComments = [NSMutableArray array];
    }
    _arrOfComments = [[[_arrOfComments reverseObjectEnumerator] allObjects] mutableCopy];
    if (_arrOfComments.count>= 1)
    {
        [self.btn_Reply setTitle:[NSString stringWithFormat:@" %lu",(unsigned long)_arrOfComments.count] forState:UIControlStateNormal];
    }
    else
    {
        [self.btn_Reply setTitle:@"" forState:UIControlStateNormal];
    }
    
    
    

    if (_itemData.userData.isReplyExpanded)
    {
        self.tblOfComments.hidden=NO;
        [self.tblOfComments reloadData];
    }
    else
    {
        self.tblOfComments.hidden=YES;
    }
    [self setNeedsUpdateConstraints];
}
-(void)updateConstraints
{
    [super updateConstraints];
    [self.btn_Reply mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(2));
        make.height.equalTo(@(20));
        //make.right.equalTo(self).offset(-20);
        make.right.equalTo(self).offset(-4);

    }];
    [self.tblOfComments mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.btn_Reply.mas_bottom);
        make.height.equalTo(@(self.tblOfComments.contentSize.height+10));
        make.left.equalTo(self);
        //make.right.equalTo(self).offset(-16);
    }];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_arrOfComments.count>3 && !_itemData.userData.isAllExpanded)
    {
        if (indexPath.row==4)
        {
            return 35;
        }
        else if (indexPath.row==0)
        {
            return 44;
        }
        else
        {
            CreplyUtils *celltemp=[[CreplyUtils alloc]init];
            return [celltemp getHeightOfCell:[_arrOfComments objectAtIndex:_arrOfComments.count-(4-indexPath.row)]];
        }
    }
    else
    {
        if (indexPath.row==_arrOfComments.count)
        {
            return 35;
        }
        else
        {
            CreplyUtils *celltemp=[[CreplyUtils alloc]init];
            return [celltemp getHeightOfCell:[_arrOfComments objectAtIndex:indexPath.row]];
        }
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_itemData.userData.isReplyExpanded)
    {
        if(_arrOfComments.count>3 && !_itemData.userData.isAllExpanded)
        {
            return 3+1+1;
        }
        else
        {
            return _arrOfComments.count+1;
        }
    }
    else
    {
        return 0;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(_arrOfComments.count>3 && !_itemData.userData.isAllExpanded)
    {
        if (indexPath.row==0)
        {
            static NSString *historyID=@"historyID";
            HIstoryCommentsCell *cellh=(HIstoryCommentsCell *)[tableView dequeueReusableCellWithIdentifier:historyID];
            if (cellh==nil)
            {
                cellh=[[HIstoryCommentsCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:historyID];
            }
            cellh.selectionStyle=UITableViewCellSelectionStyleNone;
            
            return cellh;
        }
        else if (indexPath.row==4)
        {
            static NSString *tempID=@"textField";
            CReplyTextFieldCell *cellt=(CReplyTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:tempID];
            if (cellt==nil)
            {
                cellt=[[CReplyTextFieldCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tempID];
            }
            cellt.deleGate=self.commentDelegate;
            cellt.selectionStyle=UITableViewCellSelectionStyleNone;
            cellt.itempost=self.itemData;
            self.instance=cellt.txtPost;
            return cellt;
        }
        else
        {
            static NSString *cellID=@"identifier";
            CReplyCell *cell=(CReplyCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
            if (cell==nil)
            {
                cell=[[CReplyCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            }
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            cell.delegate=self.commentDelegate;
            cell.gotReply=[_arrOfComments objectAtIndex:_arrOfComments.count-(4-indexPath.row)];
            return cell;
        }
    }
    else
    {
        if (_arrOfComments.count==indexPath.row)
        {
            static NSString *tempID=@"textField";
            CReplyTextFieldCell *cellt=(CReplyTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:tempID];
            if (cellt==nil)
            {
                cellt=[[CReplyTextFieldCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tempID];
            }
            cellt.deleGate=self.commentDelegate;
            cellt.selectionStyle=UITableViewCellSelectionStyleNone;
            cellt.itempost=self.itemData;
            self.instance=cellt.txtPost;
            return cellt;
        }
        else
        {
            static NSString *cellID=@"identifier";
            CReplyCell *cell=(CReplyCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
            if (cell==nil)
            {
                cell=[[CReplyCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            }
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            cell.delegate=self.commentDelegate;
            cell.gotReply=[_arrOfComments objectAtIndex:indexPath.row];
            return cell;
        }
    }
   }

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_arrOfComments.count>3 && !_itemData.userData.isAllExpanded && indexPath.row==0)
    {
        if (self.instance)
        {
            [self.instance resignFirstResponder];
        }
        if (self.commentDelegate && [self.commentDelegate respondsToSelector:@selector(ShowAllReplies:)])
        {
            [self.commentDelegate ShowAllReplies:_itemData];
        }
    }
}
-(void)tapOnReply
{
    if (self.instance)
    {
        [self.instance resignFirstResponder];
    }
    if (self.commentDelegate && [self.commentDelegate respondsToSelector:@selector(replyClickedOnItem:)])
    {
        [self.commentDelegate replyClickedOnItem:_itemData];
    }
}

@end
