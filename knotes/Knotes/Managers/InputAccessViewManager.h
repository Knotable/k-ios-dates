//
//  InputAccessViewManager.h
//  Knotable
//
//  Created by backup on 14-7-3.
//
//

#import <UIKit/UIKit.h>
#import "Singleton.h"
@protocol InputAccessViewManagerDelegate <NSObject>
@optional
- (void)cameraButtonClicked;
- (void)sharedButtonClicked;
- (void)postButtonClicked;

@end
@interface InputAccessViewManager : NSObject
@property(nonatomic, weak) id <InputAccessViewManagerDelegate>delegate;
+ (InputAccessViewManager *)sharedInstance;
- (UIToolbar *)inputAccessViewWithCameraDup;
- (UIToolbar *)inputAccessViewWithCamera;
- (UIToolbar *)inputAccessViewWithOutCameraDup;
- (UIToolbar *)inputAccessViewWithOutCamera;
@end
