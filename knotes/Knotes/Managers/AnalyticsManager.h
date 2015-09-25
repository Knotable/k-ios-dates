//
//  AnalyticsManager.h
//  Knotable
//
//  Created by Agustin Guerra on 8/26/14.
//
//

#import <Foundation/Foundation.h>

@class OMPromise;

@interface AnalyticsManager : NSObject

+ (AnalyticsManager *)sharedInstance;

- (void)notifyUserLoggedIn:(NSString *)type;
- (void)notifyUserChangedPasswordWithParameters:(NSDictionary *)parameters;
- (void)notifyAccountWasCreatedWithParameters:(NSDictionary *)parameters;
- (void)notifyContactWasAddedWithParameters:(NSDictionary *)parameters;
- (void)notifyPadWasCreatedWithParameters:(NSDictionary *)parameters;
- (void)notifyKNoteWasAddedWithParameters:(NSDictionary *)parameters;
- (void)notifyDateNoteWasAddedWithParameters:(NSDictionary *)parameters;
- (void)notifyVoteNoteWasAddedWithParameters:(NSDictionary *)parameters;
- (void)notifyListNoteWasAddedWithParameters:(NSDictionary *)parameters;
- (void)notifyCommentAddedOnKnoteWithParameters:(NSDictionary *)parameters;
- (void)notifyContactWasAddedToPadWithParameters:(NSDictionary *)parameters;
- (void)notifyContactWasRemovedFromPadWithParameters:(NSDictionary *)parameters;
- (void)notifyContactWasDeletedWithParameters:(NSDictionary *)parameters;
- (void)notifyKnoteReceivedVoteWithParameters:(NSDictionary *)parameters;
- (void)notifyKnoteReceivedReVoteWithParameters:(NSDictionary *)parameters;
- (void)notifyKnoteReceivedCheckWithParameters:(NSDictionary *)parameters;
- (void)notifyTextKnoteEditedWithParameters:(NSDictionary *)parameters;


@end
