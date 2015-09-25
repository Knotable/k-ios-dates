//
//  ServerConfig.h
//  Knotable
//
//  Created by Martin Ceperley on 1/13/14.
//
//

#import <Foundation/Foundation.h>

@interface ServerConfig : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *server_id;
@property (nonatomic, copy) NSString *application_host;
@property (nonatomic, copy) NSString *mongodb_host;
@property (nonatomic, copy) NSString *mongodb_database;
@property (nonatomic, assign) BOOL mongodb_needs_auth;
@property (nonatomic, copy) NSString *mongodb_username;
@property (nonatomic, copy) NSString *mongodb_password;
@property (nonatomic, copy) NSString *s3_bucket;
@property (nonatomic, copy) NSString *s3_access_key;
@property (nonatomic, copy) NSString *s3_secret_key;
@property (nonatomic, copy) NSString *google_client_id;
@property (nonatomic, copy) NSString *google_client_secret;
@property (nonatomic, copy) NSString *google_redirectURI;

@property (nonatomic, strong) NSDictionary *dic;
-(id)initWithDictionary:(NSDictionary *)dict;

-(NSString *)meteorWebsocketURL;

// Lin - Added to use static google client information

- (void) useStaticGoogleInfo;

// Lin - Ended


@end
