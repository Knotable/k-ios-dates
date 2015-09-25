//
//  CItem.h
//  RevealControllerProject
//
//  Created by backup on 13-10-17.
//
//

#import <Foundation/Foundation.h>
#import "CUtil.h"
#import "ThreadCommon.h"
#import "MessageEntity.h"
#import "ObjCMongoDB.h"
#import "TopicsEntity.h"
#import "KnotesCellProtocal.h"
#import "ReachabilityManager.h"


#if NEW_DESIGN
#define klessInformationTextViewTextLength  160
#else
#define klessInformationTextViewTextLength  100
#endif
#define OperatorThreadItemNotification @"OperatorThreadItemNotification"
#if NEW_DESIGN
#define kNoteMaxWidth (312) //(298.0-kTheadLeftGap)
#else
#define kNoteMaxWidth (280+8) //(298.0-kTheadLeftGap)
#endif

@class CEditBaseItemView;
@class CItem;
@protocol CItemDelegate <NSObject>
-(void)itemSuccessfullyArchived:(CItem *)item;
-(void)failedToArchiveknote:(CItem *)item;
@end
@interface CItem : NSObject
@property (nonatomic, assign) int maximumNumberOfLinesInNotExpandedMode;
@property (atomic, assign) CItemType type;
@property (atomic, assign) CItemOpType opType;
@property (atomic, assign) BOOL archived;
@property (nonatomic, assign) int64_t order;
@property (nonatomic, assign) int64_t timeStamp;
@property (nonatomic, copy) NSString *itemId;//is message_id
@property (nonatomic, retain) NSString *className;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* body;
@property (nonatomic, retain) NSString* highlights;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat maxHeight;
@property (nonatomic, assign) BOOL needShowMoreButton;
@property (nonatomic, assign) BOOL expandedMode;
@property (nonatomic, assign) BOOL notShowUnderLine;
@property (nonatomic, assign) BOOL offline;
@property (atomic, strong) MessageEntity *userData;
@property (nonatomic, copy) NSArray *likesId;
#if !NEW_DESIGN
@property (nonatomic, assign) BOOL isAllReplysExpand;
#endif
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* time;
@property (nonatomic, strong) NSString* imageName;
@property (atomic, assign) BOOL checkInCloud;
@property (atomic, assign) BOOL isLocked;
@property (atomic, assign) BOOL needSend;
@property (atomic, assign) BOOL isSending;
@property (atomic, assign) BOOL needFlash;
@property (atomic, assign) BOOL isUpdating;
@property (nonatomic, retain) NSArray* files;
@property (atomic, retain) NSMutableArray* uploadCache;
@property (atomic, retain) NSMutableArray* likeIdsCaches;
@property (atomic, assign) BOOL needUp;
@property (atomic, assign) NSInteger uploadRetryCount;
@property (atomic, strong) TopicsEntity *topic;
@property (nonatomic, retain) NSMutableArray* subReplys;
@property (nonatomic, assign) BOOL isReplysExpand;
@property (nonatomic,assign)BOOL isPinned;
@property (nonatomic, weak) id <KnotableCellProtocal>cell;
@property (nonatomic,weak)id<CItemDelegate>archiveDelegate;

- (id)initWithMessage:(MessageEntity *)message;
- (void)setCommonValueByMessage:(MessageEntity *)message;
- (NSMutableDictionary *)dictionaryValue;
- (NSArray *)getFileEntitiesFromSelfMessage;
- (int) getHeight;
- (int) getCellHeight;
- (int)getExpandedCellHeight;
- (int)getExpandedCellTextViewHeight;
- (int)getNotExpandedCellTextViewHeight;
- (void) reCalHeight;
- (void) checkToUpdataSelf;
- (NSInteger) numberOfLikes;
- (void) checkToUpdataFiles;
- (void) checkToLike;
- (void) checkToPin:(BOOL)pinned withNewOrder:(int64_t) oroder;
- (void) checkToDelete;

- (BOOL) shouldShowHeader;

- (NSComparisonResult) compare:(id) item;


@end
