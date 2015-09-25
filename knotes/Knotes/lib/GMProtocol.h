//
//  CustomProtocol.h
//  RevealControllerProject
//
//  Created by backup on 13-10-8.
//
//

#import <Foundation/Foundation.h>

#define kBtnTitle @"BtnTitle"
#define kBtnBG @"BtnBG"
#define kBtnIconName @"BtnIconName"
#define kBtnTag @"BtnTag"

#define kMenuRedColor [UIColor colorWithRed:106./255. green:162./255. blue:187./255. alpha:1.]
#define kMenuLightBlueColor [UIColor colorWithRed:146./255. green:72./255. blue:78./255. alpha:1.]
#define kMenuBlueColor [UIColor colorWithRed:60.0/255. green:86./255. blue:177./255. alpha:1.]
#define kMenuGrayColor [UIColor clearColor]

typedef enum _gmBtnOperator
{
    GmDeleteTag = 2,
    GmEditTag,
    GmLikeTag,
    GmNoteTag,
    GmKeyTag,
    GmDateTag,
    GmVoteTag,
    GmLockTag,
    GmackTag,
}gmBtnOperator;

@protocol CustomProtocol <NSObject>
- (void)gmButtonClickAtIndex:(NSInteger)index withObject:(id)obj;
@end
