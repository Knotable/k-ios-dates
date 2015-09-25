//
//  FKCCTextField.h
//  FCHK_Iphone
//
//  Created by Chen on 5/7/13.
//  Copyright (c) 2013 FCHK Holdings Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LCTextField : UITextField
{
    @protected
    /**
     @brief Left padding for display text
     It can be set runtime attribute 'leftPadding' as Integer
     Default value is 0
     */
    int leftPadding;
}

@property (nonatomic) int leftPadding;
@end
