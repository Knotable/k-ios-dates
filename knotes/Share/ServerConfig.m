//
//  ServerConfig.m
//  Knotable
//
//  Created by Martin Ceperley on 1/13/14.
//
//

#import "ServerConfig.h"
#import "Constant.h"

#define METEOR_DDP_URL_FORMAT @"ws://%@/websocket"


@implementation ServerConfig

-(id)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        
        self.name = dict[@"name"];
        self.server_id = dict[@"id"];
        self.application_host = dict[@"application_host"];
        self.mongodb_host = dict[@"mongodb_host"];
        self.mongodb_database = dict[@"mongodb_database"];
        NSNumber *needsAuth = dict[@"mongodb_needs_auth"];
        if (needsAuth != nil) {
            self.mongodb_needs_auth = needsAuth.boolValue;
        } else {
            self.mongodb_needs_auth = NO;
        }
        self.mongodb_username = dict[@"mongodb_username"];
        self.mongodb_password = dict[@"mongodb_password"];
        self.s3_bucket = dict[@"s3_bucket"];
        self.s3_access_key = dict[@"s3_access_key"];
        self.s3_secret_key = dict[@"s3_secret_key"];
        self.google_client_id = dict[@"google_client_id"];
        self.google_client_secret = dict[@"google_client_secret"];

        // Lin - Added to use static google client
        
        if (UseStaticGoogleClient)
        {
            [self useStaticGoogleInfo];
        }
        
        self.google_redirectURI = @"http://localhost";
        
        // Lin - Ended
        
        if (dict[@"mongodb_host_index"]) {
            NSInteger index = [dict[@"mongodb_host_index"] integerValue];
            NSArray *serArr = dict[@"mongodb_host1"];
            if(!serArr)
                serArr=[dict[@"mongodb_host"] componentsSeparatedByString:@","];
            if (index < [serArr count]) {
                self.mongodb_host = serArr[index];
            } else {
                self.mongodb_host = serArr[0];
                NSMutableDictionary *tDic = [dict mutableCopy];
                tDic[@"mongodb_host_index"] = @(0);
                dict = [tDic copy];
            }
        } else {
            NSLog(@"check");
        }
        if (dict[@"application_host_index"]) {
            NSInteger index = [dict[@"application_host_index"] integerValue];
            NSArray *serArr = dict[@"application_host1"];
            if (index< [serArr count]) {
                self.application_host = serArr[index];
//                self.application_host = @"desktop1.knotable.com";// serArr[index];
            } else {
                self.application_host = serArr[0];
                NSMutableDictionary *tDic = [dict mutableCopy];
                tDic[@"application_host_index"] = @(0);
                dict = [tDic copy];
            }
        } else {
            NSLog(@"check");
        }
        if (!self.mongodb_host) {
            self.mongodb_host = dict[@"mongodb_host"];
        }
        if (!self.application_host) {
            self.application_host = dict[@"application_host"];
        }
        
        self.dic = dict;
    }
    
    return self;
}

-(NSString *)meteorWebsocketURL
{
    // Sever setting for long's test
//    return [NSString stringWithFormat:METEOR_DDP_URL_FORMAT, @"192.168.1.101:3000"];
    
    return [NSString stringWithFormat:METEOR_DDP_URL_FORMAT, self.application_host];
    
}

// Lin - Added to use static google client information

- (void) useStaticGoogleInfo
{
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
   // DLog(@"APP ID : %@", bundleIdentifier);
    
    if ([bundleIdentifier isEqualToString:@"com.knotable.knotabledev"])
    {
        // KnoteDev
        self.google_client_id = @"960565156214-6bv72201f63g9kagmn50v7027plq381f.apps.googleusercontent.com";
        self.google_client_secret = @"bg1AU6HKVsG_tJG33gw6iayL";
    }
    else if ([bundleIdentifier isEqualToString:@"com.knotable.knotestaging"])
    {
        // KnoteStage
        self.google_client_id = @"170426069497-vfr0v5ibtj2apq65prbougti9hamb6tb.apps.googleusercontent.com";
        self.google_client_secret = @"gnKaKQwAtQZAz7EFFANA7cNT";
    }
    else if ([bundleIdentifier isEqualToString:@"com.knotable.knoteprealpha"])
    {
        // KnoteAlpha
        self.google_client_id = @"878886050904-o1l41t2f8av04stbjm58t3kunuu8n986.apps.googleusercontent.com";
        self.google_client_secret = @"kYpTsrJyjT6PUSNQ2Z1d_937";
    }
    else if ([bundleIdentifier isEqualToString:@"com.knotable.knoteprebeta"])
    {
        // KnotePreBeta
//        self.google_client_id = @"878886050904-o1l41t2f8av04stbjm58t3kunuu8n986.apps.googleusercontent.com";
//        self.google_client_secret = @"kYpTsrJyjT6PUSNQ2Z1d_937";
    }
    
    self.google_redirectURI = @"http://localhost";
}

// Lin - Ended

@end
