//
//  FKCCTextView.h
//  FCHK_Iphone
//
//  Created by Chen on 5/6/13.
//  Copyright (c) 2013 FCHK Holdings Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LCTextView : UITextView{
	
@private
	
	NSString *_placeholder;
	UIColor *_placeholderColor;
    
	BOOL _shouldDrawPlaceholder;
}

/**
 @brief The string that is displayed when there is no other text in the text view.
 
 The default value is nil.
 */
@property (nonatomic, retain) NSString *placeholder;

/**
 @brief The color of the placeholder.
 
 The default is [UIColor lightGrayColor].
 */
@property (nonatomic, retain) UIColor *placeholderColor;

// add by Chen 05/07/2013
/**
 @brief initialize function.
 It will be called from initWithFrame and can be called from another function for example awakefromnib
 */
-(void) initialize;

/**
 @brief The image that is displayed in background. If it is nil, will be no drawn.
 
 The default value is nil.
 */
@property (nonatomic, assign) UIImage *backImage;

@end
