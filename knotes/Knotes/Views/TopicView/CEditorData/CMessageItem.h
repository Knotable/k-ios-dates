//
//  CMessageItem.h
//  RevealControllerProject
//
//  Created by backup on 13-10-17.
//
//

#import "CItem.h"

#define kPersionFont kCustomLightFont(kDefaultFontSize)

@interface CMessageItem : CItem

@property (nonatomic, assign) BOOL isHeader;
@property (nonatomic, strong) NSAttributedString *attributedString;
@property (nonatomic, strong) NSAttributedString *lessAttString;

@end
