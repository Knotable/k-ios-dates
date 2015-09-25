//
//  AnalyticsManager.m
//  Knotable
//
//  Created by Agustin Guerra on 8/26/14.
//
//

#import "AnalyticsManager.h"
#import "PostingManager.h"

#import "Singleton.h"
#import <OMPromises/OMPromises.h>
#import "ServerConfig.h"

@interface AnalyticsManager()

- (OMPromise *)sendAnalyticsInformationWithParameters:(NSMutableDictionary *)parameters;

@end

@implementation AnalyticsManager

SYNTHESIZE_SINGLETON_FOR_CLASS(AnalyticsManager);

- (OMPromise *)sendAnalyticsInformationWithParameters:(NSMutableDictionary *)parameters {

    AppDelegate *app = [AppDelegate sharedDelegate];
    
    NSArray *parametersKeys = [parameters allKeys];
    BOOL userIdSet = [parametersKeys containsObject:@"userId"];
    
    if (!userIdSet) {
        if (app.meteor.userId != nil) {
            [parameters setObject:app.meteor.userId forKey:@"userId"];
            userIdSet = YES;
        }
    }

    BOOL validParameters = (userIdSet);
    if (validParameters) {
        AppDelegate *app = [AppDelegate sharedDelegate];
        [parameters setObject:@"ios" forKey:@"platform"];
        [parameters setObject:[app.server.server_id lowercaseString] forKey:@"domain"];
        return [[PostingManager sharedInstance] enqueueMeteorMethod:@"trackEvent" parameters:@[parameters]];
    } else {
        return [[OMPromise alloc] init];
    }
}

- (void) sendAndLogAnalyticsInformation :(NSMutableDictionary *) analyticsParameters withTag: (NSString *) tag{
    
    OMPromise *promise = [AnalyticsManager.sharedInstance sendAnalyticsInformationWithParameters:analyticsParameters];
    if (promise != nil) {
        [[promise fulfilled:^(id result) {
            NSLog(@"Analytics: %@ result: %@",tag, result);
        }] failed:^(NSError *error) {
            NSLog(@"Analytics: %@  error: %@", tag, error);
        }];
    } else {
        NSLog(@"Analytics: %@  could not be sent", tag);
    }
}


- (void)notifyUserLoggedIn:(NSString *)type {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]
                                       initWithObjects:@[type]
                                       forKeys:@[@"eventName"]];
    if ([type isEqualToString:@"login"]) {
        [parameters setObject:@"signIn" forKey:@"loginVector"];
    } else if ([type isEqualToString:@"session"]) {
        [parameters setObject:@"loginToken" forKey:@"loginVector"];
    }

    [self sendAndLogAnalyticsInformation: parameters withTag:@"notifyUserLoggedIn"];
}

- (void)notifyUserChangedPasswordWithParameters:(NSDictionary *)parameters {
    NSMutableDictionary *analyticsParameters = [[NSMutableDictionary alloc]
                                                initWithObjects: @[@"password set"]
                                                forKeys: @[@"eventName"]];
    
    
    [self sendAndLogAnalyticsInformation: analyticsParameters withTag:@"notifyUserChangedPasswordWithParameters"];
}

- (void)notifyAccountWasCreatedWithParameters:(NSDictionary *)parameters {
    NSMutableDictionary *analyticsParameters = [[NSMutableDictionary alloc]
                                       initWithObjects: @[@"account created", @"signup", parameters[@"userId"]]
                                       forKeys: @[@"eventName", @"registrationType", @"userId"]];
    
    
    [self sendAndLogAnalyticsInformation: analyticsParameters withTag:@"notifyAccountWasCreatedWithParameters"];
}

- (void)notifyContactWasAddedWithParameters:(NSDictionary *)parameters {
    NSDictionary *userIdResolution = @{ @"$userIdByEmail": parameters[@"contactEmail"] };
    NSDictionary *resolution = @{ @"targetUserId": userIdResolution };
    
    NSMutableDictionary *analyticsParameters = [[NSMutableDictionary alloc]
                                       initWithObjects: @[@"contact created manually", @"signup", resolution]
                                       forKeys: @[@"eventName", @"registrationType", @"$resolve"]];
    
    
    [self sendAndLogAnalyticsInformation: analyticsParameters withTag:@"notifyContactWasAddedWithParameters"];
}

- (void)notifyPadWasCreatedWithParameters:(NSDictionary *)parameters {
    NSMutableDictionary *analyticsParameters = [[NSMutableDictionary alloc]
                                                initWithObjects: @[@"pad created", parameters[@"topicId"]]
                                                forKeys: @[@"eventName", @"relevantPadId"]];
    
    [self sendAndLogAnalyticsInformation: analyticsParameters withTag:@"notifyPadWasCreatedWithParameters"];
}

- (void)notifyKNoteWasAddedWithParameters:(NSDictionary *)parameters {
    NSMutableDictionary *analyticsParameters = [[NSMutableDictionary alloc]
                                                initWithObjects: @[@"native text posted", parameters[@"topicId"], parameters[@"knoteId"]]
                                                forKeys: @[@"eventName", @"relevantPadId", @"knoteId"]];
    
    
    [self sendAndLogAnalyticsInformation: analyticsParameters withTag:@"notifyKNoteWasAddedWithParameters"];
}

- (void)notifyDateNoteWasAddedWithParameters:(NSDictionary *)parameters {
    NSMutableDictionary *analyticsParameters = [[NSMutableDictionary alloc]
                                                initWithObjects: @[@"date posted", parameters[@"topicId"], parameters[@"knoteId"]]
                                                forKeys: @[@"eventName", @"relevantPadId", @"knoteId"]];
    
    
    [self sendAndLogAnalyticsInformation: analyticsParameters withTag:@"notifyDateNoteWasAddedWithParameters"];
}

- (void)notifyVoteNoteWasAddedWithParameters:(NSDictionary *)parameters {
    NSMutableDictionary *analyticsParameters = [[NSMutableDictionary alloc]
                                                initWithObjects: @[@"vote posted", parameters[@"topicId"], parameters[@"knoteId"]]
                                                forKeys: @[@"eventName", @"relevantPadId", @"knoteId"]];
    
    
    [self sendAndLogAnalyticsInformation: analyticsParameters withTag:@"notifyVoteNoteWasAddedWithParameters"];
}

- (void)notifyListNoteWasAddedWithParameters:(NSDictionary *)parameters {
    NSMutableDictionary *analyticsParameters = [[NSMutableDictionary alloc]
                                                initWithObjects: @[@"checklist posted", parameters[@"topicId"], parameters[@"knoteId"]]
                                                forKeys: @[@"eventName", @"relevantPadId", @"knoteId"]];
    
    
    [self sendAndLogAnalyticsInformation: analyticsParameters withTag:@"notifyListNoteWasAddedWithParameters"];
}

- (void)notifyCommentAddedOnKnoteWithParameters:(NSDictionary *)parameters
{
    AppDelegate *app = [AppDelegate sharedDelegate];
    
    NSMutableDictionary *analyticsParameters = [[NSMutableDictionary alloc]
                                                initWithObjects: @[@"knote commented", parameters[@"topicId"], parameters[@"noteId"], app.meteor.userId]
                                                forKeys: @[@"eventName", @"relevantPadId", @"knoteId", @"originalAuthor"]];
    
    [self sendAndLogAnalyticsInformation: analyticsParameters withTag:@"notifyCommentAddedOnKnoteWithParameters"];
}

- (void)notifyContactWasAddedToPadWithParameters:(NSDictionary *)parameters {
    NSDictionary *userIdResolution = @{ @"$userIdByEmail": parameters[@"contactEmail"] };
    NSDictionary *resolution = @{ @"targetUserId": userIdResolution };
    
    NSMutableDictionary *analyticsParameters = [[NSMutableDictionary alloc]
                                                initWithObjects: @[@"contact created manually", @"signup", resolution]
                                                forKeys: @[@"eventName", @"registrationType", @"$resolve"]];
    
    [self sendAndLogAnalyticsInformation: analyticsParameters withTag:@"notifyContactWasAddedToPadWithParameters"];
}

- (void)notifyContactWasRemovedFromPadWithParameters:(NSDictionary *)parameters {
    NSDictionary *userIdResolution = @{ @"$userIdByEmail": parameters[@"contactEmail"] };
    NSDictionary *resolution = @{ @"targetUserId": userIdResolution };
    
    NSMutableDictionary *analyticsParameters = [[NSMutableDictionary alloc]
                                                initWithObjects: @[@"contact removed from pad", parameters[@"topicId"], resolution]
                                                forKeys: @[@"eventName", @"relevantPadId", @"$resolve"]];
    
    
    [self sendAndLogAnalyticsInformation: analyticsParameters withTag:@"notifyContactWasRemovedFromPadWithParameters"];
}

- (void)notifyContactWasDeletedWithParameters:(NSDictionary *)parameters {
    NSMutableDictionary *analyticsParameters = [[NSMutableDictionary alloc]
                                                initWithObjects: @[@"contact deleted", parameters[@"removedContactId"]]
                                                forKeys: @[@"eventName", @"targetUserId"]];
    
    
    [self sendAndLogAnalyticsInformation: analyticsParameters withTag:@"notifyContactWasDeletedWithParameters"];
}



- (void)notifyKnoteReceivedVoteWithParameters:(NSDictionary *)parameters {
    
    NSMutableDictionary *analyticsParameters = [[NSMutableDictionary alloc]
                                                initWithObjects: @[@"knote received vote", parameters[@"topicId"], parameters[@"noteId"], ]
                                                forKeys: @[@"eventName", @"relevantPadId", @"knoteId"]];
    [self sendAndLogAnalyticsInformation: analyticsParameters withTag:@"notifyKnoteReceivedVoteWithParameters"];
   
}

- (void)notifyKnoteReceivedReVoteWithParameters:(NSDictionary *)parameters {
    
    NSMutableDictionary *analyticsParameters = [[NSMutableDictionary alloc]
                                                initWithObjects: @[@"knote received revote", parameters[@"topicId"], parameters[@"noteId"], ]
                                                forKeys: @[@"eventName", @"relevantPadId", @"knoteId"]];
    [self sendAndLogAnalyticsInformation: analyticsParameters withTag:@"notifyKnoteReceivedReVoteWithParameters"];
    
}

- (void)notifyKnoteReceivedCheckWithParameters:(NSDictionary *)parameters {
    
    NSMutableDictionary *analyticsParameters = [[NSMutableDictionary alloc]
                                                initWithObjects: @[@"knote received check", parameters[@"topicId"], parameters[@"noteId"], ]
                                                forKeys: @[@"eventName", @"relevantPadId", @"knoteId"]];
    [self sendAndLogAnalyticsInformation: analyticsParameters withTag:@"notifyKnoteReceivedCheckWithParameters"];
    
}


- (void)notifyTextKnoteEditedWithParameters:(NSDictionary *)parameters {
    
    NSMutableDictionary *analyticsParameters = [[NSMutableDictionary alloc]
                                                initWithObjects: @[@"text knote edited", parameters[@"topicId"], parameters[@"noteId"], ]
                                                forKeys: @[@"eventName", @"relevantPadId", @"knoteId"]];
    [self sendAndLogAnalyticsInformation: analyticsParameters withTag:@"notifyTextKnoteEditedWithParameters"];
    
}
@end
