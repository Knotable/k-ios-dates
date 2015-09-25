//
//  ConnectGoogleController.h
//  Knotable
//
//  Created by Martin Ceperley on 2/19/14.
//
//

#import <UIKit/UIKit.h>

@protocol ConnectGoogleDelegate

-(void)cancelConnectGoogle;
-(void)successConnectingGoogle:(NSString *)google_id user_id:(NSString *)google_user_id;

@end

@interface ConnectGoogleController : UIViewController <UIWebViewDelegate>

@property (nonatomic, weak) id<ConnectGoogleDelegate> delegate;

@end
