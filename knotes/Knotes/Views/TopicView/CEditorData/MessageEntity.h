//
//  MessageEntity.h
//  RevealControllerProject
//
//  Created by backup on 13-11-15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum {
	kViewedUnkown	= 0,
	kViewedYES		= 1,
	kViewedNO		= 2
} hasViewedType;

#define CONTAINER_NAME_MAIN         @"main"
#define CONTAINER_NAME_ATTACHMENTS  @"attachments"

@class ContactsEntity;
@class HybridDocument;


@interface MessageEntity : NSManagedObject
@property (atomic, assign) BOOL archived;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * account_id;
@property (nonatomic) int64_t mid;
@property (nonatomic, strong) NSString * message_id;
@property (nonatomic, strong) NSString * topic_id; //forgin key
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * body;
@property (nonatomic, strong) NSData * content;
@property (nonatomic, strong) NSData * editors;
@property (nonatomic, strong) NSData * replys;
@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString * containerName; 
@property (nonatomic) int32_t type;
@property (nonatomic) int64_t order;
@property (nonatomic) int64_t time;
@property (nonatomic, strong) NSDate *created_time;
@property (nonatomic) int32_t topic_type;
@property (nonatomic, strong) NSString * currently_contact_edit;
@property (nonatomic, strong) NSString * liked_account_ids;
@property (nonatomic) int16_t likes_count;
@property (nonatomic) BOOL hot;
@property (nonatomic) BOOL removedHot;
@property (nonatomic) BOOL on_cloud;
@property (nonatomic) BOOL need_send;
@property (nonatomic) BOOL pinned;
@property (nonatomic) BOOL expanded;
@property (nonatomic) BOOL isAllExpanded;
@property (nonatomic) BOOL isReplyExpanded;
@property (nonatomic) int16_t has_viewed;
@property (nonatomic, strong) NSString * file_ids;
@property (nonatomic, strong) NSString *file_url;
@property (nonatomic, strong) NSString * highlights;

@property (nonatomic, assign) int32_t view_count;
@property (nonatomic, strong) NSDate * last_viewed;
@property (nonatomic)BOOL isImageDataAvailable;


@property (nonatomic, retain) ContactsEntity *contact;

@property (nonatomic, strong) NSString *embeddedImages;

//@property (nonatomic, strong) HybridDocument *document;
@property (nonatomic, strong) NSString *documentHTML;
@property (nonatomic, strong) NSString *documentHash;
@property (nonatomic, strong) NSString *usertags;
@property (nonatomic) BOOL muted;

+ (void)addThumbnailsHTMLto:(NSMutableString *)output forFileIDS:(NSArray *)fileIDs;


- (void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues withTopicId:(NSString *)topic_id;

- (void)wasJustDisplayedSave:(BOOL)shouldSave;

+ (NSString *)wrapTextInHTML:(NSString *)text;

- (NSString *)convertedHTMLBody;

- (BOOL)hasPhotoAvailable;

- (NSArray *)availableFileIDs;

- (NSArray *)loadedEmbeddedImages;

@end
