//
//  TIToken.h
//  Mailer
//
//  Created by wuli on 14-5-12.
//  Copyright (c) 2014年 Knotable. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	TITokenAccessoryTypeNone = 0,
	TITokenAccessoryTypeDisclosureIndicator = 1,
} TITokenAccessoryType;

@interface TIToken : UIControl {
	

}
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) UIFont * font;
@property (nonatomic, strong) id representedObject;
@property (nonatomic, strong) UIColor * tintColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, assign) TITokenAccessoryType accessoryType;

- (id)initWithTitle:(NSString *)aTitle;
- (id)initWithTitle:(NSString *)aTitle representedObject:(id)object;
- (id)initWithTitle:(NSString *)aTitle representedObject:(id)object font:(UIFont *)aFont;

@end