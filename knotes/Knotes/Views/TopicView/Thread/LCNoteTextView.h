//
//  LCNoteTextView.h
//  RevealControllerProject
//
//  Created by Chen on 9/28/13.
//
//

#import <UIKit/UIKit.h>

@interface LCNoteTextView : UITextView
@property (nonatomic, strong) UIColor *horizontalLineColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *verticalLineColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) BOOL showLine;//default is YES
@property (nonatomic) UIEdgeInsets margins UI_APPEARANCE_SELECTOR;
@end
