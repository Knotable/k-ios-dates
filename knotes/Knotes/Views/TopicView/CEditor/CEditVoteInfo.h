//
//  CEditVoteInfo.h
//  RevealControllerProject
//
//  Created by backup on 13-11-8.
//
//

#import <Foundation/Foundation.h>
#import "CItem.h"
@interface CEditVoteInfo : NSObject
@property (nonatomic) BOOL editor;
@property (nonatomic) CItemType type;
@property (nonatomic, assign) BOOL checked;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger num;
@property (nonatomic, strong) NSArray *voters;
@property (nonatomic, retain) UIImage* checkedImage;
@property (nonatomic, retain) UIImage* uncheckedImage;
@property (nonatomic, retain) UIImage* checkedImage1;
@property (nonatomic, retain) UIImage* uncheckedImage1;
@property (nonatomic, retain) UIButton* checkBtn;
@property (nonatomic, retain) UIButton* addButton;
- (id)initWithDic:(NSDictionary *)dic;
- (void)setByDic:(NSDictionary *)dic;
- (NSDictionary *)dictionary;
@end
