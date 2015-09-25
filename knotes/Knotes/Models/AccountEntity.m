//
//  AccountEntity.m
//  RevealControllerProject
//
//  Created by Martin Ceperley on 11/22/13.
//
//

#import "AccountEntity.h"
#import "UserEntity.h"
#import "ThreadConst.h"
#import "ObjCMongoDB.h"

@implementation AccountEntity

@dynamic lastLoggedIn;
@dynamic loggedIn;
@dynamic user;
@dynamic account_id;
@dynamic google_linked;
@dynamic google_id;
@dynamic google_user_id;
@dynamic  notificationStatus;
@dynamic lastNotification;
@dynamic hashedToken;
@dynamic expireDate;
@dynamic belongs_account_ids;

- (void)setTokenInfo:(NSDictionary *)dic
{
    self.hashedToken = dic[@"token"];
    NSNumber *date = dic[@"tokenExpires"][@"$date"];
    NSTimeInterval inteval = date.doubleValue;
    if (inteval > kKnoteTimeIntervalMaxValue)
    {
        inteval = (NSTimeInterval)(inteval/1000.0);
    }
    self.expireDate = [NSDate dateWithTimeIntervalSince1970:inteval];
}

- (void)checkIfUserHasGoogle
{
    if (self.account_id)
    {
        [[AppDelegate sharedDelegate] checkIfUserHasGoogle:self.account_id
                                         withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData) {
                               
            if ([self isFault])
            {
                return;
            }
                               
            if(success == NetworkSucc)
            {
                BOOL hasGoogle = userData != nil;
                
                if (userData)
                {
                    NSDictionary *ids = (NSDictionary *)userData;
                    
                    if(ids[@"user_id"])
                        self.google_linked = @(hasGoogle);
                    
                    if(ids[@"user_id"]){
                        self.google_user_id = ids[@"user_id"];
                        self.google_id = ids[@"google_id"];
                    }
                    else
                    {
                        self.google_user_id = nil;
                        self.google_id = nil;
                    }
                    
                    BOOL Notificationstatus;
                    
                    if(ids[@"notificationStatus"] && [ids[@"notificationStatus"] isKindOfClass:[NSString class]])
                    {
                        Notificationstatus=[ids[@"notificationStatus"] isEqualToString:@"on"];
                        
                    }
                    else if(ids[@"notificationStatus"])
                    {
                        Notificationstatus = [ids[@"notificationStatus"] boolValue];
                    }
                    else
                    {
                        Notificationstatus = NO;
                    }
                    
                    self.notificationStatus = @(Notificationstatus);
                }
                
                [AppDelegate saveContext];
                
            }
        }];
    }
    else
    {
         NSLog(@"NO ACCOUNT ID, getting it for user id %@", self.user.user_id);
        
        if (![AppDelegate sharedDelegate].appUserAccountID)
        {
            [AppDelegate sharedDelegate].appUserAccountID = [[AppDelegate sharedDelegate] getAccountID:self.user.user_id];            
        }
        else
        {
            self.account_id = [AppDelegate sharedDelegate].appUserAccountID;
            
            [AppDelegate saveContext];
        }

    }

}

- (void)saveUserPassword:(NSString *)password
{
    if (password && (!self.user.password || ![self.user.password isEqualToString:password]))
    {
        self.user.password = password;
    }
}
@end
