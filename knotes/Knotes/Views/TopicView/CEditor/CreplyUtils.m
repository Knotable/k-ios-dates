//
//  CreplyUtils.m
//  Knotable
//
//  Created by Dhruv on 3/24/15.
//
//

#import "CreplyUtils.h"

@implementation CreplyUtils
-(CGFloat)getSizeOfReplyView:(CItem *)item
{
    CGFloat hight=0;
    if (item.userData.isReplyExpanded)
    {
        NSArray *temp= [NSKeyedUnarchiver unarchiveObjectWithData:item.userData.replys];
        temp = [[temp reverseObjectEnumerator] allObjects];
        if (!item.userData.isAllExpanded && temp.count>3)
        {
            for (int i=0;i<3;i++)
            {
                NSDictionary *a=[temp objectAtIndex:temp.count-(3-i)];
                hight +=[self getHeightOfCell:a];
               
            }
            hight+=44;
        }
        else
        {
            for (NSDictionary *a in temp)
            {
                hight +=[self getHeightOfCell:a];
            }
        }
        hight +=32;
    }
    hight +=28;
    return hight;
}
-(CGFloat)getHeightOfCell:(NSDictionary *)tempReply
{
    CGFloat height=0;
    height += [CUtil getTextRect:[self getString:tempReply] Font:[DesignManager knoteBodyFont] Width:CGRectGetWidth([UIScreen mainScreen].bounds)-30].size.height;
    //Time Label
    height +=10;
    return height - REMOVE_COMMENT_LABEL_EXTRA_VERTICALSPACE;
}
-(NSString *)getString:(NSDictionary *)content
{
    if (!content) {
        return @"";
    }
    NSString *text = content[@"body"] ;
    if (text && [text isKindOfClass:[NSString class]] && (text.length > 3)) {
        HybridDocument *document = [[HybridDocument alloc] initWithHTML:text];
        text = document.text;
        if(!text){
            text = @"";
        }
    }
    return text;
}
-(CGFloat)getHeightOfTitleInfo:(MessageEntity *)Omessage
{
    if (Omessage == nil)
    {
        return 0;
    }
    CGFloat height=15;
    //_message = Omessage;
    ContactsEntity *contact = Omessage.contact;
    
//    if(contact && contact.managedObjectContext != nil)
    {
        NSString *userName = @"";
        if (!contact)
        {
            if (Omessage.account_id)
            {
                contact = [ContactsEntity MR_findFirstByAttribute:@"account_id" withValue:Omessage.account_id];
            }
        }
        if (contact)
        {
            userName = [NSString stringWithFormat:@"%@",contact.name];
        }
        else
        {
            userName = [NSString stringWithFormat:@"%@",Omessage.name];
        }
        if (userName.length < 1)
            userName = @"(null)";// when no exist user, shows in UI "(null)", so, it should be used to get heigh
        height +=[CUtil getTextSize:userName textFont:[DesignManager knoteRealnameFont]].height;
        height +=[CUtil getTextSize:[[ThreadItemManager sharedInstance] getDateTimeIndicate:Omessage.time] textFont:[DesignManager knoteTimeFont]].height;
        
        height +=Omessage.title.length>0?[CUtil getTextRect:Omessage.title Font:[DesignManager knoteSubjectFont] Width:CGRectGetWidth([UIScreen mainScreen].bounds)-12].size.height:0;
    }
    
    return height;
}
-(CGFloat)getHeightOfTableCommentsFromReplyData:(CItem *)itme
{
    CGFloat hight=0;
    if (itme.userData.isReplyExpanded)
    {
        
        NSArray *temp= [NSKeyedUnarchiver unarchiveObjectWithData:itme.userData.replys];
         temp = [[temp reverseObjectEnumerator] allObjects];
        if (!itme.userData.isAllExpanded && temp.count>3)
        {
            for (int i=0;i<3;i++)
            {
                NSDictionary *a=[temp objectAtIndex:temp.count-(3-i)];
                hight +=[self getHeightOfCell:a];
            }
            hight+=44;
        }
        else
        {
            for (NSDictionary *a in temp)
            {
                hight +=[self getHeightOfCell:a];
            }
        }
        hight +=32;
        return hight;
    }
    else
    {
        return 0;
    }
}
@end
