//
//  PostingManager.h
//  Knotable
//
//  Created by Martin Ceperley on 6/19/14.
//
//

#import <Foundation/Foundation.h>
#import "TopicManager.h"

@class OMPromise;

static NSString *ADD_CONTACT_FROM_EMAIL = @"ADD_CONTACT_FROM_EMAIL";
static NSString *ADD_CONTACT_FROM_USERNAME = @"ADD_CONTACT_FROM_USERNAME";

static NSString *METEOR_METHOD_ADD_NEW_CONTACT = @"add_new_contact";

static NSString *NEW_CONTACT_ADDED_NOTIFICATION = @"NEW_CONTACT_ADDED_NOTIFICATION";

static NSString *DELETE_MESSAGE_BY_ID = @"/messages/remove";
static NSString *DELETE_CONTACT_BY_ID = @"/contacts/remove";

@interface PostingManager : NSObject

+ (PostingManager *)sharedInstance;

- (void)startMonitoring;

- (OMPromise *)enqueueMeteorMethod:(NSString *)methodName parameters:(NSArray *)params;

- (OMPromise *)enqueueLocalMethod:(NSString *)methodName parameters:(id)params;

- (void)periodicCheck;

- (void)postKnote:(MessageEntity *)message;

@end
