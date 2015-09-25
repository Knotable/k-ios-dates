//
//  ComposeThreadViewController.h
//  Knotable
//
//  Created by backup on 13-12-20.
//
//

#import <UIKit/UIKit.h>
#import "LCNoteTextView.h"
#import "CItem.h"
#import "CEditBaseItemView.h"
#import "UserEntity.h"
#import "BaseViewController.h"
#import "CKeyNoteItem.h"
#import "ContactsEntity.h"
#import "AppDelegate.h"
#import "UPStackMenu.h"


@interface ComposeThreadViewController : BaseViewController

@property (nonatomic, strong) NSString *topic_id;
//@property (strong, nonatomic) UIView *contentView;
@property (nonatomic) int32_t topic_type;
@property (nonatomic, strong) NSString *subject;

@property (nonatomic) BOOL shouldPopToMainView;

@property (weak, nonatomic) id<EditorViewControllerDelegate> delegate;

@property (nonatomic, strong) CItem *item;
@property (nonatomic, strong) CKeyNoteItem *keyItem;
@property(nonatomic) BOOL wasFirstKeyboardDisplayed;
@property (nonatomic, assign) ItemOpType opType;
@property (nonatomic, assign) ItemLifeCycle itemLifeCycleStage;
@property (nonatomic, strong) ContactsEntity *current_contact;

- (id)initForNewPad;
- (id)initWithItem:(CItem *)item;
- (id)initWithItemType:(int) type;
- (id)initWithString:(NSString *)text;
- (id)initWithData: (NSDictionary*) data;
- (void)postData;

- (void) ComposePopBack;

- (NSString*) contentText;

+ (void) backupWithData: (NSDictionary*) dict;
@end

extern NSString* lastComposeKey;