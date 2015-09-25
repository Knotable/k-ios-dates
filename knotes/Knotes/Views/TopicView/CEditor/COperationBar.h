//
//  COperationBar.h
//  Knotable
//
//  Created by leejan97 on 13-12-16.
//
//

#import <UIKit/UIKit.h>
#import "GMProtocol.h"
#import <SDWebImage/UIButton+WebCache.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "ContactsEntity.h"

@class COperationBar;
@protocol COperationBarDelegate <NSObject>
@optional
- (void) operationButtonClickWithTag:(NSInteger)tag;
- (NSInteger) numberOfLikes;
@end


@interface COperationBar : UIView
@property (nonatomic, weak) id<COperationBarDelegate> delegate;
-(void)updateLikesNow:(NSNotification *)notification;
- (void)setImageWithContact:(ContactsEntity *)contact;
- (void)setButtonsArray:(NSArray *)array;
-(void)likesVisible;

@end
