//
//  TITokenFieldInternalDelegate.h
//  Mailer
//
//  Created by wuli on 14-5-12.
//  Copyright (c) 2014年 Knotable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TITokenField.h"

@interface TITokenFieldInternalDelegate : NSObject <UITextFieldDelegate> {
	
}
@property (nonatomic, weak) id <UITextFieldDelegate> delegate;
@property (nonatomic, weak) TITokenField * tokenField;
@end