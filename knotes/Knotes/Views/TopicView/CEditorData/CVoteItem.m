//
//  CVoteItem.m
//  RevealControllerProject
//
//  Created by backup on 13-10-17.
//
//

#import "CVoteItem.h"
#import "CEditBaseItemView.h"
#import "CUtil.h"
#import "CEditVoteItemView.h"
#import "CEditVoteInfo.h"

#define kVoteTitleFont [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]
@implementation CVoteItem

@synthesize height = _height;

-(id)initWithMessage:(MessageEntity *)message
{
    self = [super initWithMessage:message];
    if (self) {
        self.type = C_VOTE;
        self.titleFont = kVoteTitleFont;
        self.voteList = [NSMutableArray array];
    }
    return self;
}

-(int) getHeight
{
    return _height;
}
#if !NEW_DESIGN
-(int) getCellHeight
{
    CGRect rect = [CUtil getTextRect:self.title Font:self.titleFont Width:kDefaultCtlWidth];
#if NEW_DESIGN
    _height = [_voteList count]*kItemDefaultHeight + kDefalutBtnBarH + rect.size.height+90;
#else
    _height = [_voteList count]*kItemDefaultHeight + kDefalutTitleBarH + kDefalutBtnBarH + rect.size.height;
#endif
    _height += 40;
    
    if (!self.userData.expanded) {
        _height-=35;
    } else {
        if (self.userData.replys) {
            _height+=20;
        }
    }
    
    return self.height<kItemMinH?kItemMinH:self.height;
    
}
#else
-(int) getCellHeight
{
    CreplyUtils *cre=[[CreplyUtils alloc]init];
    _height = [_voteList count]*kItemDefaultHeight + kDefalutBtnBarH +[cre getHeightOfTitleInfo:self.userData]+30 ;
    _height+=[cre getSizeOfReplyView:self];
    return _height;
}
#endif
-(void)setVoteList:(NSMutableArray *)voteList
{
    _voteList = voteList;
    
    return;
    
#if NEW_DESIGN
#else
    CGRect rect = [CUtil getTextRect:self.title Font:self.titleFont Width:kDefaultCtlWidth];
    _height = [voteList count]*kItemDefaultHeight + kDefalutTitleBarH + kDefalutBtnBarH + rect.size.height+8;
    if ([[self likesId] count]>0) {
        _height += kDefalutInfoBarH;
    }
#endif
   
}

- (void) reCalHeight
{
    [self getCellHeight];
}

-(void)setCommonValueByMessage:(MessageEntity *)message
{
    [super setCommonValueByMessage:message];
    NSArray *a = [NSKeyedUnarchiver unarchiveObjectWithData:message.content];
    NSMutableArray *vote = [[NSMutableArray alloc] initWithCapacity:3];
    for (NSDictionary *dic in a) {
        CEditVoteInfo * info = [[CEditVoteInfo alloc] initWithDic:dic];
        info.type = message.type;
        [vote addObject:info];
    }
    self.voteList = vote;
}

- (NSMutableDictionary *)dictionaryValue
{
    NSMutableDictionary *dict = [super dictionaryValue];

    dict[@"title"] = self.userData.title;
    dict[@"cname"] = @"knotes";
    if (self.type == C_VOTE) {
        dict[@"type"] = @"poll";
    } else if (self.type == C_LIST) {
        dict[@"type"] = @"checklist";
    }
    NSArray *a = [NSKeyedUnarchiver unarchiveObjectWithData:self.userData.content];
    dict[@"options"] = a;
    dict[@"voted"] = [NSArray new];
    return dict;
}

+ (CGFloat)getCustomHeight:(MessageEntity *)message
{
    CGFloat height = 60;
    NSArray *a = [NSKeyedUnarchiver unarchiveObjectWithData:message.content];
    
    NSMutableArray *vote = [[NSMutableArray alloc] initWithCapacity:3];
    
    for (NSDictionary *dic in a)
    {
        if ([dic isKindOfClass:[NSDictionary class]] && [dic count]>0)
        {
            [vote addObject:dic];
        }
    }
    
    CGRect rect = [CUtil getTextRect:message.title Font:kVoteTitleFont Width:kDefaultCtlWidth];
    
#if NEW_DESIGN
    height = [vote count]*kItemDefaultHeight  + kDefalutBtnBarH + rect.size.height +90;
#else
    height = [vote count]*kItemDefaultHeight + kDefalutTitleBarH + kDefalutBtnBarH + rect.size.height +20;
#endif
    return height;
}
@end
