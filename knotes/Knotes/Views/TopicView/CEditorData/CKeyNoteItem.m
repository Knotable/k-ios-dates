//
//  CKeyItem.m
//  RevealControllerProject
//
//  Created by backup on 13-10-17.
//
//

#import "CKeyNoteItem.h"
#import "ThreadItemManager.h"

#define kKeyMaxLine 10
@implementation CKeyNoteItem

@synthesize height = _height;

-(id)init {
    self = [super init];
    if (self) {
        self.type = C_KEYKNOTE;
        self.checkInCloud = YES;
        self.isButtonHidden = YES;
    }
    return self;
}

-(int) getHeight
{
    return 0;
}

-(int) getCellHeight
{
    if (self.body) {
        CGRect rect = [CUtil getTextRect:self.body Font:kCustomLightFont(kDefaultFontSize) Width:kDefaultCtlWidth-20];
        
        if (rect.size.height > kKeyMaxLine*kDefaultLineHeight && rect.size.height >= (kKeyMaxLine)*kDefaultLineHeight) {
            rect.size.height = kKeyMaxLine*kDefaultLineHeight;
            self.needShowMoreButton = YES;
        }
        rect.size.height+=38;//text in top gap
        rect.size.height+=4;//text in bottom gap
        
#if NEW_DESIGN
        _height = 90 + kDefalutBtnBarH + rect.size.height;
#else
        _height = kDefalutTitleBarH + kDefalutBtnBarH + rect.size.height;
#endif
        _height+=10;//top gap in cell
        _height+=4; //bottom gap in cell
        _height+=26;//enlarger btn
        
        if ([[self likesId] count]>0) {
            _height += kDefalutInfoBarH;
        }
        if ([self files]&& [self.files count]>0) {
            NSInteger num = ceilf(([self.files count]+1)/5.0);
            _height += num*kGridViewH;
        }
        if (self.height < kItemMinH) {
            self.height = kItemMinH;
        }
    } else {
        if (self.isButtonHidden)
            return 0;
        else
            self.height = 66;
    }

    return self.height;
}

- (void) reCalHeight
{
    [self getCellHeight];
}

- (NSMutableDictionary *)dictionaryValue
{
    NSMutableDictionary *dict = [super dictionaryValue];
    
    dict[@"body"] = self.userData.body;
    dict[@"cname"] = @"key_notes";
    dict[@"note"] =  self.userData.body;
    dict[@"type"] = @"key_knote";

    return dict;
}

-(void)checkToUpdataSelf
{
    [self.cell showProcess];
    [[ThreadItemManager sharedInstance] sendInsertKey:self withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData, id userData2, id userData3) {
        switch (success) {
            case NetworkSucc:
            {
                [self.cell stopProcess];
                self.itemId = (NSString *)userData;
                self.userData.message_id = self.itemId;
                self.needSend = NO;
                self.userData.need_send = NO;
                self.uploadRetryCount = 3;
                self.topic.key_id = self.itemId;
            }
                break;
            case NetworkTimeOut:
            case NetworkErr:
            case NetworkFailure:
            {
                if (self.uploadRetryCount>0) {
                    self.uploadRetryCount--;
                    [self checkToUpdataSelf];
                } else {
                    [self.cell showInfo:InfoWarrning];
                }
            }
                break;
            default:
                break;
        }
    }];

}

@end
