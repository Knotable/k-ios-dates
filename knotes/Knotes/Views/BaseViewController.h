//
//  BaseViewController.h
//  Knotable
//
//  Created by backup on 14-1-7.
//
//

#import <UIKit/UIKit.h>
#import "UIImage+Knotes.h"
#import "ImageCollectionViewCell.h"
#import "FileManager.h"
#import "FileEntity.h"
#import "UserEntity.h"
#import "SVProgressHUD.h"
#import "GMProgressView.h"
#import "ObjCMongoDB.h"
#import "ComposeNewNote.h"

@protocol EditorViewControllerDelegate <NSObject>
@required
- (void)insertItem:(CItem *)item withInfo:(id)info withOpType:(ItemOpType)type;

- (void)gotItem:(CItem *)item withInfo:(id)info withOpType:(ItemOpType)type;

@optional
- (void)insertItem:(CItem *)item withInfo:(id)info withOpType:(ItemOpType)type files:(NSArray *)files contacts:(NSArray *)contacts;

@end

@interface BaseViewController : UIViewController<ComposeNewNoteDelegate>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) ComposeNewNote *cNewNote;
@property (nonatomic, weak) ComposeView *currentView;

- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;

#pragma mark Access Photo Library
-(void)onAddPicture:(id)obj;

@end
