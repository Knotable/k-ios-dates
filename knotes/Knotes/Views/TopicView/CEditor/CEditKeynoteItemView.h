//
//  CEditKeynoteItemView.h
//  RevealControllerProject
//
//  Created by backup on 13-10-11.
//
//

#import "CEditBaseItemView.h"

@interface CEditKeynoteItemView : CEditBaseItemView
@property (nonatomic, assign) BOOL isLocked;
@property (nonatomic, assign) BOOL isButtonsHidden;

- (void)startFlashEffect;
@end
