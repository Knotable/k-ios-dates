//
//  CreplyUtils.h
//  Knotable
//
//  Created by Dhruv on 3/24/15.
//
//

#import <Foundation/Foundation.h>
#import "CItem.h"
#import "DesignManager.h"
#import "HybridDocument.h"
#import "ThreadItemManager.h"
@interface CreplyUtils : NSObject
-(CGFloat)getSizeOfReplyView:(CItem *)item;
-(CGFloat)getHeightOfCell:(NSDictionary *)tempReply;
-(CGFloat)getHeightOfTitleInfo:(MessageEntity *)Omessage;
-(CGFloat)getHeightOfTableCommentsFromReplyData:(CItem *)itme;
@end