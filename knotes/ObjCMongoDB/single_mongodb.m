//
//  single_mongodb.m
//  RevealControllerProject
//
//  Created by yanbo on 13-11-8.
//
//

#import "single_mongodb.h"
#import "ObjCMongoDB.h"
#import "NSString+Knotable.h"
#import "BSONTypes.h"
#import "TopicsEntity.h"
#import "ContactsEntity.h"
#import "MCAWSS3Client.h"

#import "MultiConnGenerator.h"
#import "MonoConn.h"
#import "FileInfo.h"
#import "FileEntity.h"
#import "FileManager.h"
#import "ServerConfig.h"
#import "MongoConnection+Knotable.h"
#import "AccountEntity.h"
#import "ThreadConst.h"
#import "AppDelegate.h"
#import "Constant.h"
#import "SVProgressHUD.h"
#import "MessageEntity.h"
#import "DataManager.h"
#import "ReachabilityManager.h"
@implementation single_mongodb

static single_mongodb *sharedInstance;


+(single_mongodb *)sharedInstanceMethod
{

    /*
    @synchronized(self)
    {
        if (sharedInstance == nil)
            sharedInstance = [[self alloc] init];
        [sharedInstance connect_to_server];
    }

    return sharedInstance;
     */
    static single_mongodb *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[single_mongodb alloc] init];
    });
    
    return _sharedInstance;
}

+ (void)releaseSharedInstance
{
	if (sharedInstance)
	{
		[sharedInstance release] ;
		sharedInstance = nil ;
	}
}




+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;
        }
    }
    return nil;
}

//copy返回单例本身
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


- (void)dealloc
{
	[super dealloc];
}

+(void)disconnect_to_server
{
}


-(id)init
{
    if (self = [super init])
    {
    }
    return self;
}

// Converted
+(NSString*)mongo_id_generator
{
    int i = 0;
    
    char result[20] = {0};
    const char *str = "23456789ABCDEFGHJKLMNPQRSTWXYZabcdefghijkmnopqrstuvwxyz";

    
    for (i=0; i< 17; i++)
    {
        uint32_t bytes[4]={0x00};
        
        if (0 != SecRandomCopyBytes(0, 10, (uint8_t*)bytes))
        {
             return nil;
        }
   
        double_t index = bytes[0] * 2.3283064365386963e-10 * strlen(str);
        
        result[i] = str[ (int)floor(index) ];
    }
    
    NSString *ret = [[[NSString alloc] initWithBytes:result length:strlen(result) encoding:NSASCIIStringEncoding] autorelease];
    
    NSLog(@"id generator: %@ ", ret);
    return ret;
}

-(MongoConnection *)generateConnection
{
    if ([ReachabilityManager sharedInstance].currentNetStatus != NotReachable) {

        NSError *error = nil;
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        MongoConnection *connection = [MongoConnection connectionForServer:app.server.mongodb_host error:&error];
        if (error) {
            if (error.code != MONGO_CONN_SUCCESS) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNeedChangeMongoDbServer object:nil];
                error = nil;
                connection = [MongoConnection connectionForServer:app.server.mongodb_host error:&error];
                if (error) {
                    if (error.code != MONGO_CONN_SUCCESS) {
                        if (!app.hasLogin) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:kNeedGoBackToLoginView object:nil];
                        }
                    }
                }
            }
            NSLog(@"Error connecting to MongoDB host %@: %@", app.server.mongodb_host, error);
        }
        if (app.server.mongodb_needs_auth) {
            if (connection != nil) {
                error = nil;
                BOOL authenticated = [connection authenticate:app.server.mongodb_database
                                                     username:app.server.mongodb_username
                                                     password:app.server.mongodb_password
                                                        error:&error];
                if (!authenticated || error) {
                    NSLog(@"Mongo Authentication Failed: %@", error);
                }
            }
        }
        
        return connection;
    } else {
        return nil;
    }
}

// Do not use this function
+(void)sendRequestLogin:(NSString *)name Password:(NSString *)pass withDelegate:(id)delegate
{
    id<MongoEngineDelegate> delegate_local = delegate;
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        NSError *error = nil;
        NSDictionary *resultDict = nil;
        BSONDocument *resultDoc = nil;
        NSInteger ret =  NetworkFailure;
        
        if ( dbconn ) {
            
            coll = [dbconn collectionNamed:METEORCOLLECTION_USERS];
            if(coll != nil && name != nil) {
                
                NSString *lowercaseName = [name lowercaseString];
                MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
                [pred1 keyPath:@"username" matches:lowercaseName];
                error = nil;
                
                resultDoc = [coll findOneWithPredicate:pred1 error:&error];
                
                if ( resultDoc ) {
                    
                    resultDict = [resultDoc dictionaryValue];
                    
                    NSArray *emails = nil;
                    emails = [resultDict objectForKey:@"emails"];
                    NSDictionary *email = [emails objectAtIndex:0];
                    NSString *m = [email objectForKey:@"address"];
                    NSLog(@"email %@", m);
                    
                    NSDictionary *services = nil;
                    services = [resultDict objectForKey:@"services"];
                    NSDictionary *password = nil;
                    password = [services objectForKey:@"password"];
                    NSDictionary *srp = nil;
                    srp = [password objectForKey:@"srp"];
                    
                    NSLog(@"identity %@ ",[srp objectForKey:@"identity"]);
                    NSLog(@"salt %@ ",[srp objectForKey:@"salt"]);
                    ret = NetworkSucc;
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{

            if (delegate_local && [delegate_local respondsToSelector:@selector(loginNetworkResult:withCode:)]) {
                [delegate_local loginNetworkResult:resultDict withCode:ret];
            }
        });
        conn.isFinished = YES;
    } withTimeOut:^(MonoConn *conn) {
        
        if (delegate_local && [delegate_local respondsToSelector:@selector(loginNetworkResult:withCode:)]) {
            [delegate_local loginNetworkResult:nil withCode:NetworkTimeOut];
        }
    }];
}

//deprecated code
+(void)sendRequestContactList:(NSString *)user_id withDelegate:(id)delegate
{
    id<MongoEngineDelegate> delegate_local = delegate;

    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        
        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        NSError *error = nil;
        NSArray *resultDocArray = nil;
        NSString *account_id = nil;
        NSInteger ret =  NetworkFailure;

        if ( dbconn ) {
            
            if ([single_mongodb sharedInstanceMethod].account_id == nil)
            {
                [single_mongodb sharedInstanceMethod].account_id = [single_mongodb getAccountID:user_id withMongoConnection:dbconn];
            }
            account_id = [single_mongodb sharedInstanceMethod].account_id;
            coll = [dbconn collectionNamed:METEORCOLLECTION_PEOPLE];
            
            if( coll != nil && account_id != nil ) {
                MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
                [pred1 keyPath:@"account_id" matches:account_id];
                //[pred1 keyPath:@"archived" doesNotMatchAnyObjects: @(YES), nil];
                [pred1 keyPath:@"deleted" doesNotMatchAnyObjects: @"deleted", nil];

                error = nil;
                
                MongoFindRequest *req1 = [MongoFindRequest findRequestWithPredicate:pred1];
                [req1 includeKey:@"fullname"];
                [req1 includeKey:@"emails"];
                [req1 includeKey:@"gravatar_exist"];
                [req1 includeKey:@"bgcolor"];
                [req1 includeKey:@"phone"];
                [req1 includeKey:@"website"];
                [req1 includeKey:@"twitter_link"];
                [req1 includeKey:@"facebook_link"];
                [req1 includeKey:@"account_id"];
                [req1 includeKey:@"archived"];
                [req1 includeKey:@"username"];
                [req1 includeKey:@"position"];
                [req1 includeKey:@"total_topics"];
                [req1 includeKey:@"type"];
                [req1 includeKey:@"belongs_to_account_id"];

                
                resultDocArray = [coll findWithRequest:req1 error:&error];
                if(!error) {
                    ret = NetworkSucc;
                } else {
                    DLog(@"####Error: %@", error);
                    ret = NetworkFailure;
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (delegate_local && [delegate_local respondsToSelector:@selector(gotContactResult:withCode:)]) {
                [delegate_local gotContactResult:resultDocArray withCode:ret];
            }
        });
        NSLog(@"getting account ID for user ID: %@", user_id);
 
        conn.isFinished = YES;
    } withTimeOut:^(MonoConn *conn) {
        
        if (delegate_local && [delegate_local respondsToSelector:@selector(gotContactResult:withCode:)]) {
            [delegate_local gotContactResult:nil withCode:NetworkTimeOut];
        }
    }];
    NSLog(@"sendRequestContactList user_id: %@", user_id);
}

// Do not use
+(NSArray *)topicsWithPredicate:(MongoPredicate *)predicate connection:(MongoConnection *)connection
{
    if(!connection){
        NSLog(@"Error no MongoConnection present");
        return @[];
    }
    MongoDBCollection *coll = [connection collectionNamed:METEORCOLLECTION_TOPICS];
    if(!coll){
        NSLog(@"Error no Topics collection");
        return @[];
    }

    MongoFindRequest *req1 = [MongoFindRequest findRequestWithPredicate:predicate];
    [req1 includeKey:@"_id"];
    [req1 includeKey:@"subject"];
    [req1 includeKey:@"changed_subject"];
    [req1 includeKey:@"participators"];
    [req1 includeKey:@"topic_type"];
    [req1 includeKey:@"key_id"];
    [req1 includeKey:@"locked_id"];
    [req1 includeKey:@"created_time"];
    [req1 includeKey:@"updated_time"];
    [req1 includeKey:@"archived"];
    [req1 includeKey:@"account_id"];
    [req1 includeKey:@"order"];
    [req1 includeKey:@"shared_account_ids"];
    [req1 includeKey:@"participator_account_ids"];
    [req1 includeKey:@"currently_contact_edit"];
    [req1 includeKey:@"new"];
    [req1 includeKey:@"untouched"];
    [req1 includeKey:@"viewers"];


    NSError *error = nil;
    NSArray *results = [coll findWithRequest:req1 error:&error];

    if(error){
        NSLog(@"Error fetching topics predicate: %@ : %@", predicate, error);
    }
    if(!results){
        return @[];
    }
    return results;
}

// Do not use
+(void)sendRequestTopicList:(NSString *)email userEmail:(NSString*)user_email userData:(id) data withDelegate:(id)delegate
{
    NSLog(@"sendRequestTopicList email: %@ userEmail: %@", email, user_email);
    id<MongoEngineDelegate> delegate_local = delegate;
    
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        MongoConnection * dbconn = conn.conn;

        NSInteger ret =  NetworkFailure;
        NSArray *resultDocArray = nil;
        NSString *email_addr = [[email componentsSeparatedByString:@","] objectAtIndex:0];

        MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
        if ( [email_addr isEqualToString:user_email]) {
            [pred1 keyPath:@"participators" arrayContainsAllObjects:email_addr,nil];
            //[pred1 keyPath:@"participators" arrayCountIsEqualTo:1];
        } else {
            NSLog(@"looking for topics with participants: %@ and %@", email_addr, user_email);
            [pred1 keyPath:@"participators" arrayContainsAllObjects:email_addr, user_email, nil];
        }

        [pred1 keyPath:@"untouched" doesNotMatchAnyObjects:@(YES), nil];
        [pred1 keyPath:@"is_sub" doesNotMatchAnyObjects:@(YES), nil];
        [pred1 keyPath:@"status" doesNotMatchAnyObjects:@"DRAFT", nil];

        //Filter archived out in UI, not from server. Archived is now stored as a list of UserIDs
        //[pred1 keyPath:@"archived" doesNotMatchAnyObjects: @(YES), nil];

        resultDocArray = [[self topicsWithPredicate:pred1 connection:dbconn] copy];


        NSLog(@"Topic list length: %d", (int)resultDocArray.count);
        ret = NetworkSucc;


        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate_local && [delegate_local respondsToSelector:@selector(gotTopicResult:userData:withCode:)]) {
                [delegate_local gotTopicResult:resultDocArray userData:data withCode:ret];
            }
        });
        conn.isFinished = YES;
    } withTimeOut:^(MonoConn *conn) {
        
        if (delegate_local && [delegate_local respondsToSelector:@selector(gotTopicResult:userData:withCode:)]) {
            [delegate_local gotTopicResult:nil userData:data withCode:NetworkTimeOut];
        }
    }];
}

// Deleted
+(void)sendRequestTopicsByID:(NSArray *)ids withDelegate:(id)delegate
{
    id<MongoEngineDelegate> delegate_local = delegate;

    NSLog(@"sendRequestTopicsByID: %@", ids);
    
    if(!ids || ids.count == 0)
    {
        if (delegate_local && [delegate_local respondsToSelector:@selector(gotTopicResult:userData:withCode:)])
        {
            [delegate_local gotTopicResult:@[] userData:nil withCode:NetworkSucc];
        }
        
        return;
    }

    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        
        MongoConnection * dbconn = conn.conn;

        NSInteger ret =  NetworkFailure;
        
        NSArray *resultDocArray = nil;

        MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
        
        [pred1 keyPath:@"_id" matchesAnyFromArray:ids];

        resultDocArray = [[self topicsWithPredicate:pred1 connection:dbconn] copy];

        NSLog(@"Topic by id list length: %d", (int)resultDocArray.count);
        ret = NetworkSucc;

        dispatch_async(dispatch_get_main_queue(), ^{
            if (delegate_local && [delegate_local respondsToSelector:@selector(gotTopicResult:userData:withCode:)]) {
                [delegate_local gotTopicResult:resultDocArray userData:nil withCode:ret];
            }
        });
        conn.isFinished = YES;
    } withTimeOut:^(MonoConn *conn) {

        if (delegate_local && [delegate_local respondsToSelector:@selector(gotTopicResult:userData:withCode:)]) {
            [delegate_local gotTopicResult:nil userData:nil withCode:NetworkTimeOut];
        }
    }];
}

// Converted
+(void)sendUpdatedTopicSubject:(NSString *)topic_id withContent:(NSString *)subject  withCompleteBlock:(MongoCompletion)block
{
    if (!((topic_id && topic_id.length>0) && (subject && subject.length>0)))
    {
        block(NetworkErr,nil,nil);
        return;
    }
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        
        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        WM_NetworkStatus ret = NetworkFailure;
        if ( dbconn ) {
            
            coll = [dbconn collectionNamed:METEORCOLLECTION_TOPICS];
            if ( coll ) {
                
                MongoKeyedPredicate *predicate = [MongoKeyedPredicate predicate];
                id objID = [BSONObjectID objectIDWithString:topic_id];
                if (!objID) {
                    objID = topic_id;
                }
                if (objID) {
                    [predicate keyPath:@"_id" matches:objID];
                    MongoUpdateRequest *req = [MongoUpdateRequest updateRequestWithPredicate:predicate firstMatchOnly:YES];
                    [req keyPath:@"subject" renameToKey:@"original_subject"];
                    [req keyPath:@"changed_subject" setValue:subject];
                    NSError *error = nil;
                    [coll updateWithRequest:req error:&error];
                    [req keyPath:@"subject" setValue:subject];
                    [coll updateWithRequest:req error:&error];

                    if(!error) {
                        ret = NetworkSucc;
                    } else {
                        NSLog(@"Error updating knote order: %@", error);
                        NSLog(@"server error: %@", [dbconn serverError]);
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(ret,nil,nil);
                    });
                }
            }
        }
        conn.isFinished = YES;
    } withTimeOut:^(MonoConn *conn) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(NetworkTimeOut,nil,nil);
        });
    }];
    
}

// Converted
+(void)sendUpdatedTopicViewed:(NSString *)topic_id accountID:(NSString *)account_id reset:(BOOL)shouldReset
{
    if(!(topic_id && account_id)){
        NSLog(@"Error: sendUpdatedTopicViewed without enough data topic: %@ account: %@", topic_id, account_id);
        return;
    }

    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {

        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        WM_NetworkStatus ret = NetworkFailure;
        if ( dbconn ) {

            coll = [dbconn collectionNamed:METEORCOLLECTION_TOPICS];
            if ( coll ) {

                MongoKeyedPredicate *predicate = [MongoKeyedPredicate predicate];
                id objID = [BSONObjectID objectIDWithString:topic_id];
                if (!objID) {
                    objID = topic_id;
                }
                if (objID) {
                    [predicate keyPath:@"_id" matches:objID];
                    MongoUpdateRequest *req = [MongoUpdateRequest updateRequestWithPredicate:predicate firstMatchOnly:YES];
                    if(shouldReset){
                        //Remove all other viewers
                        [req keyPath:@"viewers" setValue:@[account_id]];
                    } else {
                        //Add the account id if not already present
                        [req setForKeyPath:@"viewers" addValue:account_id];
                    }

                    NSError *error = nil;
                    [coll updateWithRequest:req error:&error];
                    if(!error) {
                        ret = NetworkSucc;
                        NSLog(@"Success adding viewer %@ to topic %@ reset? %d", account_id, topic_id, shouldReset);
                    } else {
                        NSLog(@"Error updating topic viewed: %@", error);
                        NSLog(@"server error: %@", [dbconn serverError]);
                    }

                }
            }
        }
        conn.isFinished = YES;
    } withTimeOut:^(MonoConn *conn) {

    }];

}

// Converted
+(void)sendRequestMessages:(NSArray *)topic_ids withCompleteBlock:(MongoCompletion)block
{
    if(topic_ids == nil || topic_ids.count == 0){
        NSLog(@"ERROR: sendRequestMessages called with topic_ids empty: %@", topic_ids);
        block(NetworkFailure,nil,nil);
        return;
    }

    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        NSError *error = nil;
        WM_NetworkStatus ret =  NetworkFailure;

        
        NSArray *resultDocArray = nil;

        if ( dbconn ) {
            
            coll = [dbconn collectionNamed:METEORCOLLECTION_MESSAGES];
            
            if(coll != nil) {
                
                ret = NetworkSucc;
                
                MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
                //[pred1 keyPath:@"topic_id" matches:topic_id];
                [pred1 keyPath:@"topic_id" matchesAnyFromArray:topic_ids];
                
                error = nil;
                
                MongoFindRequest *req1 = [MongoFindRequest findRequestWithPredicate:pred1];
                [req1 includeKey:@"type"];
                [req1 includeKey:@"topic_type"];
                [req1 includeKey:@"topic_id"];
                [req1 includeKey:@"currently_contact_edit"];
                [req1 includeKey:@"order"];
                [req1 includeKey:@"From"];
                [req1 includeKey:@"from"];
                
                [req1 includeKey:@"body-plain"];
                [req1 includeKey:@"text"];
                [req1 includeKey:@"timestamp"];
                
                [req1 includeKey:@"has_sub_messages"];
                [req1 includeKey:@"is_sub_message"];
                [req1 includeKey:@"changed_text"];
                
                [req1 includeKey:@"_id"];
                [req1 includeKey:@"account_id"];
                [req1 includeKey:@"name"];
                [req1 includeKey:@"title"];
                [req1 includeKey:@"liked_account_ids"];
                [req1 includeKey:@"file_ids"];
                [req1 includeKey:@"archived"];
                [req1 includeKey:@"editors"];
                [req1 includeKey:@"replys"];
                
                error = nil;
                resultDocArray = [coll findWithRequest:req1 error:&error];
                if(error) {
                    DLog(@"####Error: %@", error);
                    ret = NetworkFailure;
                }
            }
        }
        if (!conn.isFinished) {
            NSArray *dicts = [resultDocArray valueForKey:@"dictionaryValue"];
            dispatch_async(dispatch_get_main_queue(), ^{
                block(ret,nil,dicts);
            });
            conn.isFinished = YES;
        }
    } withTimeOut:^(MonoConn *conn) {
        
        block(NetworkTimeOut,nil,nil);
    }];
}

// Converted
+(void)sendRequestContactByAccountId:(NSString *)account_id withCompleteBlock:(MongoCompletion)block
{
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        NSError *error = nil;
        id resultDoc = nil;
        
        WM_NetworkStatus ret =  NetworkFailure;
        if ( dbconn ) {
            
            coll = [dbconn collectionNamed:METEORCOLLECTION_PEOPLE];
            
            if( coll != nil ) {
                MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
                [pred1 keyPath:@"type" matches:@"me"];
                [pred1 keyPath:@"account_id" matches:account_id];
                
                MongoFindRequest *req1 = [MongoFindRequest findRequestWithPredicate:pred1];
                
                error = nil;
                resultDoc = [coll findWithRequest:req1 error:&error];
                
                if(!error) {
                    ret = NetworkSucc;
                } else {
                    DLog(@"####Error: %@", error);
                    ret = NetworkFailure;
                }
            }
        }
        if (!conn.isFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(ret,nil,resultDoc);
            });
            conn.isFinished = YES;
        }
        
    } withTimeOut:^(MonoConn *conn) {
        block(NetworkTimeOut,nil,nil);
    }];
}

// Not using
+(void)sendRequestBelongIdsByAccountId:(NSString *)account_id withCompleteBlock:(MongoCompletion)block
{
    return;
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        NSError *error = nil;
        id resultDoc = nil;
        
        WM_NetworkStatus ret =  NetworkFailure;
        if ( dbconn ) {
            
            coll = [dbconn collectionNamed:METEORCOLLECTION_PEOPLE];
            
            if( coll != nil ) {
                MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
                [pred1 keyPath:@"belongs_to_account_id" matches:account_id];

                MongoFindRequest *req1 = [MongoFindRequest findRequestWithPredicate:pred1];
                [req1 includeKey:@"account_id"];

                error = nil;
                resultDoc = [coll findWithRequest:req1 error:&error];
                
                if(!error) {
                    ret = NetworkSucc;
                } else {
                    DLog(@"####Error: %@", error);
                    ret = NetworkFailure;
                }
            }
        }
        if (!conn.isFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(ret,nil,resultDoc);
            });
            conn.isFinished = YES;
        }
        
    } withTimeOut:^(MonoConn *conn) {
        block(NetworkTimeOut,nil,nil);
    }];
}

// Converted
+(void)sendRequestContactByEmail:(NSString *)email withCompleteBlock:(MongoCompletion)block
{
    if (!(email && email.length>0))
    {
        return;
    }
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        NSError *error = nil;
        id resultDoc = nil;
        
        WM_NetworkStatus ret =  NetworkFailure;
        if ( dbconn ) {
            
            coll = [dbconn collectionNamed:METEORCOLLECTION_PEOPLE];
            
            if( coll != nil ) {
                MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
                [pred1 keyPath:@"type" matches:@"me"];
                [pred1 keyPath:@"emails" matchesAnyFromArray:@[email]];
                
                MongoFindRequest *req1 = [MongoFindRequest findRequestWithPredicate:pred1];
                
                error = nil;
                resultDoc = [coll findWithRequest:req1 error:&error];
                
                if(!error) {
                    ret = NetworkSucc;
                } else {
                    DLog(@"####Error: %@", error);
                    ret = NetworkFailure;
                }
            }
        }
        if (!conn.isFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(ret,nil,resultDoc);
            });
            conn.isFinished = YES;
        }

    } withTimeOut:^(MonoConn *conn) {
        block(NetworkTimeOut,nil,nil);
    }];
}

// Not using
+(void)sendRequestMeIds:(NSArray *)contacts withCompleteBlock:(MongoCompletion)block
{
    NSMutableDictionary *contactsByEmail = [[NSMutableDictionary alloc] initWithCapacity:contacts.count];
    NSMutableArray *emails = [[NSMutableArray alloc] initWithCapacity:contacts.count];
    for(ContactsEntity *contact in contacts){
        for(NSString *address in [contact.email componentsSeparatedByString:@","]){
            contactsByEmail[address] = contact;
            [emails addObject:address];
        }
    }
//    NSLog(@"sendRequestMeIds contactsByEmail: %@", contactsByEmail);
    //Remove duplicates
    emails = [[[NSSet setWithArray:emails] allObjects] mutableCopy];

    NSUInteger batch_count = 50;

    while(emails.count > 0){

        NSRange range = NSMakeRange(0, MIN(batch_count, emails.count));
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];


        NSArray *emailBatch = [emails objectsAtIndexes:indexSet];
        [emails removeObjectsAtIndexes:indexSet];

//        NSLog(@"sendRequestMeIds for index set: %@ emails: %@ mainThread? %d", indexSet, emailBatch, [[NSThread currentThread] isMainThread]);


        [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
            MongoDBCollection *coll = nil;
            MongoConnection * dbconn = conn.conn;
            NSError *error = nil;
            id resultDoc = nil;

            WM_NetworkStatus ret =  NetworkFailure;
            if ( dbconn )
            {

                coll = [dbconn collectionNamed:METEORCOLLECTION_PEOPLE];

                if( coll != nil )
                {
                    MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
                    [pred1 keyPath:@"type" matches:@"me"];
                    [pred1 keyPath:@"emails" matchesAnyFromArray:emailBatch];

                    MongoFindRequest *req1 = [MongoFindRequest findRequestWithPredicate:pred1];
                    [req1 includeKey:@"_id"];
                    [req1 includeKey:@"emails"];
                    [req1 includeKey:@"account_id"];

                    error = nil;
                    resultDoc = [coll findWithRequest:req1 error:&error];
                    if(!error)
                    {
                        ret = NetworkSucc;

                        for(BSONDocument *bsonDocument in resultDoc)
                        {
                            ContactsEntity *matchingContact = nil;

                            NSDictionary *dict = [bsonDocument dictionaryValue];
                            NSArray *contactEmails = dict[@"emails"];
                            if(!contactEmails) continue;
                            for(NSString *email in contactEmails)
                            {
                                ContactsEntity *savedContact = contactsByEmail[email];
                                if(savedContact)
                                {
                                    matchingContact = savedContact;
                                    break;
                                }
                            }

                            if(matchingContact && ![matchingContact isFault] && [matchingContact objectID])
                            {
                                [glbAppdel.managedObjectContext lock];
                                matchingContact = (ContactsEntity *)[glbAppdel.managedObjectContext existingObjectWithID:[matchingContact objectID] error:nil];

                                matchingContact.account_id = dict[@"account_id"];
                                matchingContact.me_id = dict[@"_id"];
                                [glbAppdel.managedObjectContext unlock];
                            }
                            else
                            {
                                NSLog(@"No contact found for emails: %@", contactEmails);
                            }
                        }

                    }
                    else
                    {
                        DLog(@"####Error: %@", error);
                        ret = NetworkFailure;
                    }
                }
            }
            if (!conn.isFinished)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(ret,nil,resultDoc);
                });
                conn.isFinished = YES;
            }
        } withTimeOut:^(MonoConn *conn) {

            block(NetworkTimeOut,nil,nil);
        }];

    }
}

// Not using
+(void)sendRequestEmails:(NSString *)_id withParticipators:(NSArray *)participators withCompleteBlock:(MongoCompletion)block
{
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        NSError *error = nil;
        NSArray *resultDocArrayParticipators = nil;

        WM_NetworkStatus ret =  NetworkFailure;
        if ( dbconn ) {
            
            coll = [dbconn collectionNamed:METEORCOLLECTION_PEOPLE];
            
            if(coll != nil && participators != nil && [participators count] > 0) {
                
                MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
                [pred1 keyPath:@"type" matches:@"me"];
                [pred1 keyPath:@"emails" matchesAnyFromArray:participators];
                
                MongoFindRequest *req1 = [MongoFindRequest findRequestWithPredicate:pred1];
                [req1 includeKey:@"_id"];
                [req1 includeKey:@"emails"];
                
                error = nil;
                resultDocArrayParticipators = [coll findWithRequest:req1 error:&error];
                if(!error) {
                    ret = NetworkSucc;
                } else {
                    DLog(@"####Error: %@", error);
                    ret = NetworkFailure;
                }
            }
        }
        if (!conn.isFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(ret,nil,resultDocArrayParticipators);
            });
            conn.isFinished = YES;
        }
    } withTimeOut:^(MonoConn *conn) {
        
        block(NetworkTimeOut,nil,nil);
    }];
}

// Converted
+(void)sendRequestKnotes:(NSArray *)topic_ids withCompleteBlock:(MongoCompletion)block
{
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        NSError *error = nil;
        NSArray *resultDocArray = nil;
        WM_NetworkStatus ret =  NetworkFailure;

        if ( dbconn ) {
            

            coll = [dbconn collectionNamed:METEORCOLLECTION_KNOTES];
            
            if(coll != nil) {
                
                ret = NetworkSucc;
                
                
                MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
                [pred1 keyPath:@"topic_id" matchesAnyFromArray:topic_ids];
                [pred1 keyPath:@"type" doesNotMatchAnyObjects: @"lock", @"unlock", nil];
                
                error = nil;
                
                MongoFindRequest *req1 = [MongoFindRequest findRequestWithPredicate:pred1];
                [req1 includeKey:@"_id"];
                [req1 includeKey:@"account_id"];
                [req1 includeKey:@"topic_id"];
                [req1 includeKey:@"type"];
                [req1 includeKey:@"currently_contact_edit"];
                [req1 includeKey:@"order"];
                [req1 includeKey:@"name"];
                
                [req1 includeKey:@"body"];
                [req1 includeKey:@"deadline_subject"];
                [req1 includeKey:@"deadline"];
                [req1 includeKey:@"pinned"];
                [req1 includeKey:@"timestamp"];
                [req1 includeKey:@"title"];
                [req1 includeKey:@"options"];
                [req1 includeKey:@"htmlBody"];
                [req1 includeKey:@"liked_account_ids"];
                [req1 includeKey:@"file_ids"];
                [req1 includeKey:@"archived"];
                [req1 includeKey:@"editors"];
                [req1 includeKey:@"replys"];
                [req1 includeKey:@"usertags"];
                error = nil;
                
                resultDocArray = [coll findWithRequest:req1 error:&error];
                
                if(error) {
                    DLog(@"####Error: %@", error);
                    ret = NetworkFailure;
                }
                    
                

            }
        }
        if (!conn.isFinished) {
            NSArray *knote_dicts = [resultDocArray valueForKey:@"dictionaryValue"];
            dispatch_async(dispatch_get_main_queue(), ^{
                block(ret,nil,knote_dicts);
            });
            conn.isFinished = YES;
        }
    } withTimeOut:^(MonoConn *conn) {
        
        block(NetworkTimeOut,nil,nil);
    }];
    
}

// Converted
+(void)sendUpdatedTopicOrder:(NSString *)topic_id accountID:(NSString *)account_id OrderRank:(NSString*)order reset:(BOOL)shouldReset
{
    if(!(topic_id && account_id)){
        NSLog(@"Error: sendUpdatedTopicOrderRank without enough data topic: %@ account: %@", topic_id, account_id);
        return;
    }
    
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        
        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        WM_NetworkStatus ret = NetworkFailure;
        if ( dbconn ) {
            
            coll = [dbconn collectionNamed:METEORCOLLECTION_TOPICS];
            if ( coll ) {
                
                MongoKeyedPredicate *predicate = [MongoKeyedPredicate predicate];
                id objID = [BSONObjectID objectIDWithString:topic_id];
                if (!objID) {
                    objID = topic_id;
                }
                if (objID) {
                    [predicate keyPath:@"_id" matches:topic_id];
                    MongoUpdateRequest *req = [MongoUpdateRequest updateRequestWithPredicate:predicate firstMatchOnly:YES];
                    
//                    NSString *orderstring = [NSString stringWithFormat:@"\"order\":{\"%@\":%@}",account_id,order];  \\\This too not working
                    [req keyPath:@"order" setValue:order];
                    
              
                    
                    NSError *error = nil;
                    [coll updateWithRequest:req error:&error];
                    if(!error) {
                        ret = NetworkSucc;
                        NSLog(@"Success setting order for %@ to topic %@ reset? %d", account_id, topic_id, shouldReset);
                    } else {
                        NSLog(@"Error updating order: %@", error);
                        NSLog(@"server error: %@", [dbconn serverError]);
                    }
                    
                }
            }
        }
        conn.isFinished = YES;
    } withTimeOut:^(MonoConn *conn) {
        
    }];
    
}

// Converted
+(void)sendUpdatedTopicOrders:(NSArray *)messages
{
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        
        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        
        if ( dbconn ) {
            
            coll = [dbconn collectionNamed:METEORCOLLECTION_TOPICS];
            if ( coll ) {
                
                for(NSManagedObject *message in messages){
                    
                    NSString *topicid = [message valueForKey:@"topic_id"];
                    NSNumber *order = [message valueForKey:@"order"];
                    if(!topicid)
                        continue;
                    if(!order)
                        continue;

                    MongoKeyedPredicate *predicate = [MongoKeyedPredicate predicate];
                    
                    [predicate keyPath:@"_id" matches:topicid];
                    MongoUpdateRequest *req = [MongoUpdateRequest updateRequestWithPredicate:predicate firstMatchOnly:YES];
                    
                    [req keyPath:@"order" setValue:order];
                    
                    NSError *error = nil;
                    [coll updateWithRequest:req error:&error];
                    if(!error) {
                        //                                NSLog(@"Success setting order for %@ to topic %@ reset? %d", account_id, topic_id, shouldReset);
                    } else {
                        NSLog(@"Error updating order: %@", error);
                        NSLog(@"server error: %@", [dbconn serverError]);
                    }
                    
                    
                }
            }
            
        }
        conn.isFinished = YES;
    } withTimeOut:^(MonoConn *conn) {
        NSLog(@"todo Time out");
    }];
    
}

// Converted
+(void)sendUpdatedKnoteOrders:(NSArray *)messages
{
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {

        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;

        if ( dbconn ) {
            
            NSArray *knotes = [messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %d", C_KNOTE]];
            NSArray *emails = [messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %d", C_MESSAGE]];

            coll = [dbconn collectionNamed:METEORCOLLECTION_KNOTES];
            if ( coll ) {
                
                for(NSManagedObject *message in knotes){
                    NSString *knoteID = [message valueForKey:@"message_id"];
                    NSNumber *order = [message valueForKey:@"order"];
                    NSLog(@"Updating knote order to %@ on %@", order, knoteID);
                    
                    MongoKeyedPredicate *predicate = [MongoKeyedPredicate predicate];
                    id objID = [BSONObjectID objectIDWithString:knoteID];
                    if (!objID) {
                        objID = knoteID;
                    }
                    if (objID) {
                        [predicate keyPath:@"_id" matches:objID];
                        MongoUpdateRequest *req = [MongoUpdateRequest updateRequestWithPredicate:predicate firstMatchOnly:YES];
                        [req keyPath:@"order" setValue:order];
                        
                        NSError *error = nil;
                        [coll updateWithRequest:req error:&error];
                        if(error)
                        {
                            NSLog(@"Error updating knote order: %@", error);
                        }
                    }                    
                }
            }
            
            coll = [dbconn collectionNamed:METEORCOLLECTION_MESSAGES];
            if ( coll ) {
                
                for(NSManagedObject *message in emails){
                    NSString *knoteID = [message valueForKey:@"message_id"];
                    NSNumber *order = [message valueForKey:@"order"];
                    NSLog(@"Updating email order to %@ on %@", order, knoteID);
                    
                    MongoKeyedPredicate *predicate = [MongoKeyedPredicate predicate];
                    id objID = [BSONObjectID objectIDWithString:knoteID];
                    if (!objID) {
                        objID = knoteID;
                    }
                    if (objID) {
                        [predicate keyPath:@"_id" matches:objID];
                        MongoUpdateRequest *req = [MongoUpdateRequest updateRequestWithPredicate:predicate firstMatchOnly:YES];
                        [req keyPath:@"order" setValue:order];
                        
                        NSError *error = nil;
                        [coll updateWithRequest:req error:&error];
                        if(error)
                        {
                            NSLog(@"Error updating knote order: %@", error);
                        }
                    }
                }
            }

        }
        conn.isFinished = YES;
    } withTimeOut:^(MonoConn *conn) {
        NSLog(@"todo Time out");
    }];

}

// Converted
+(ContactsEntity *)sendRequestContactByContactID:(NSString *)ContactID
{
    MongoDBCollection *coll = nil;
    NSError *error = nil;
    NSDictionary *resultDict = nil;
    BSONDocument *resultDoc = nil;
    ContactsEntity *contact = nil;
    
    MongoConnection * dbconn = [[single_mongodb sharedInstanceMethod] generateConnection];
    if ( dbconn == nil)
        return contact;
    
    coll = [dbconn collectionNamed:METEORCOLLECTION_PEOPLE];
    
    if(coll != nil)
    {
        MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
        [pred1 keyPath:@"_id" matches:ContactID];
        
        MongoFindRequest *req1 = [MongoFindRequest findRequestWithPredicate:pred1];
        
        resultDoc = [coll findOneWithRequest:req1 error:&error];
        
        if ( resultDoc != Nil)
        {
            resultDict = [resultDoc dictionaryValue];
            
            contact=[ContactsEntity contactWithDict:resultDict];
            
            NSLog(@"ContactsEntity[%@]",contact);
        }
        
    }
    return contact;
}

// Converted
+(void)sendUpdatedContact:(NSManagedObject *)contactEntity
{
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {

        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;

        if ( dbconn ) {
            
            coll = [dbconn collectionNamed:METEORCOLLECTION_PEOPLE];
            if (coll != nil){
                
                ContactsEntity *contact = (ContactsEntity *)contactEntity;
                NSString *contactID = contact.contact_id;
                
                MongoKeyedPredicate *predicate = [MongoKeyedPredicate predicate];
                id objID = [BSONObjectID objectIDWithString:contactID];
                if (!objID) {
                    objID = contactID;
                }
                if (objID) {
                    [predicate keyPath:@"_id" matches:objID];
                }
                MongoUpdateRequest *req = [MongoUpdateRequest updateRequestWithPredicate:predicate firstMatchOnly:YES];
                if (contact.website) {
                    [req keyPath:@"website" setValue:contact.website];
                }
                if (contact.phone) {
                    [req keyPath:@"phone" setValue:contact.phone];
                }

                NSArray *emails = [[NSOrderedSet orderedSetWithArray:[contact.email componentsSeparatedByString:@","]] array];
                
                if (emails) {
                    [req keyPath:@"emails" setValue:emails];
                }

                NSError *error = nil;
                [coll updateWithRequest:req error:&error];
                if(error)
                {
                    NSLog(@"Error updating contact: %@", error);
                }
            }
        }
        
        conn.isFinished = YES;
    } withTimeOut:^(MonoConn *conn) {
        NSLog(@"todo Time out");
    }];

}

// Converted
+(void)sendUpdatedContactWithImage:(NSManagedObject *)contactEntity URL:(NSDictionary *)Urls
{
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        
        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        
        if ( dbconn ) {
            
            coll = [dbconn collectionNamed:METEORCOLLECTION_PEOPLE];
            if (coll != nil){
                
                ContactsEntity *contact = (ContactsEntity *)contactEntity;
                NSString *contactID = contact.contact_id;
                
                MongoKeyedPredicate *predicate = [MongoKeyedPredicate predicate];
                id objID = [BSONObjectID objectIDWithString:contactID];
                if (!objID) {
                    objID = contactID;
                }
                [predicate keyPath:@"_id" matches:objID];
                MongoUpdateRequest *req = [MongoUpdateRequest updateRequestWithPredicate:predicate firstMatchOnly:YES];
                [req keyPath:@"gravatar_exist" setValue:@"2"];
                [req keyPath:@"avatar_uploaded" setValue:Urls];
                [req keyPath:@"avatar" setValue:Urls];
                [req keyPath:@"website" setValue:contact.website];
                [req keyPath:@"phone" setValue:contact.phone];
                
                NSArray *emails = [[NSOrderedSet orderedSetWithArray:[contact.email componentsSeparatedByString:@","]] array];
                [req keyPath:@"emails" setValue:emails];
                
                NSError *error = nil;
                [coll updateWithRequest:req error:&error];
                if(error)
                {
                    NSLog(@"Error updating contact: %@", error);
                }
            }
        }
        
        conn.isFinished = YES;
    } withTimeOut:^(MonoConn *conn) {
        NSLog(@"todo Time out");
    }];
    
}

// Converted
+(void)sendUpdatedKnoteCurrentlyEditing:(NSArray *)messages ContactID:(NSString *)ContactID
{
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        
        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        
        if ( dbconn ) {
            
            NSArray *knotes = [messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %d", C_KNOTE]];
            coll = [dbconn collectionNamed:METEORCOLLECTION_KNOTES];
            if ( coll ) {
                
                for(NSManagedObject *message in knotes){
                    NSString *knoteID = [message valueForKey:@"message_id"];
                    NSNumber *order = [message valueForKey:@"order"];
                    NSLog(@"Updating knote order to %@ on %@", order, knoteID);
                    
                    MongoKeyedPredicate *predicate = [MongoKeyedPredicate predicate];
                    id objID = [BSONObjectID objectIDWithString:knoteID];
                    if (!objID) {
                        objID = knoteID;
                    }
                    if (objID) {
                        [predicate keyPath:@"_id" matches:objID];
                        MongoUpdateRequest *req = [MongoUpdateRequest updateRequestWithPredicate:predicate firstMatchOnly:YES];
                        [req keyPath:@"currently_contact_edit" setValue:ContactID];
                        
                        NSError *error = nil;
                        [coll updateWithRequest:req error:&error];
                        if(error)
                        {
                            NSLog(@"Error updating knote order: %@", error);
                        }
                    }
                }
            }
        }
        conn.isFinished = YES;
    } withTimeOut:^(MonoConn *conn) {
        NSLog(@"todo Time out");
    }];
    
}

// Converted
+(void)sendUpdatedKnoteUnsetCurrentlyEditing:(NSArray *)messages
{
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        
        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        
        if ( dbconn ) {
            
            NSArray *knotes = [messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %d", C_KNOTE]];
            coll = [dbconn collectionNamed:METEORCOLLECTION_KNOTES];
            if ( coll ) {
                
                for(NSManagedObject *message in knotes){
                    NSString *knoteID = [message valueForKey:@"message_id"];
                    NSLog(@"Updating knote order to on %@", knoteID);
                    
                    MongoKeyedPredicate *predicate = [MongoKeyedPredicate predicate];
                    id objID = [BSONObjectID objectIDWithString:knoteID];
                    if (!objID) {
                        objID = knoteID;
                    }
                    if (objID) {
                        [predicate keyPath:@"_id" matches:objID];
                        MongoUpdateRequest *req = [MongoUpdateRequest updateRequestWithPredicate:predicate firstMatchOnly:YES];
                        [req keyPath:@"currently_contact_edit" setValue:@""];
                        
                        NSError *error = nil;
                        [coll updateWithRequest:req error:&error];
                        if(error)
                        {
                            NSLog(@"Error updating knote order: %@", error);
                        }
                    }
                }
            }
        }
        conn.isFinished = YES;
    } withTimeOut:^(MonoConn *conn) {
        NSLog(@"todo Time out");
    }];
    
}

// Converted
+(WM_NetworkStatus)postedKnotesTopicID:(NSString *)topicID userID:(NSString *)userID knoteID:(NSString *)knoteID
{
    NSLog(@"postedKnotesTopicID: %@ userID: %@ knoteID: %@", topicID, userID, knoteID);
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    //old format
    //NSString *strUrl = [NSString stringWithFormat:@"http://%@/post_knotes/%@/%@", app.server.application_host, topicID, userID];
    
    //new format -- not yet live?
    NSString *strUrl = [NSString stringWithFormat:@"http://%@/post_knotes/%@/%@/%@", app.server.application_host, topicID, userID, knoteID];
    NSLog(@"post_knotes URL: %@", strUrl);
    
    NSURL *url = [NSURL URLWithString:strUrl];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setHTTPMethod:@"POST"];
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *str = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    if ([[str lowercaseString] isEqualToString:@"success"]) {
        NSLog(@"post_knotes successfull");
        return NetworkSucc;
    } else {
        NSLog(@"post_knotes not successfull: %@", str);
        return NetworkSucc;
        //return NetworkErr;
    }
}

// Converted
+(void)sendUpdateKnotesFileIds:(NSMutableDictionary *)knote withAccountId:(NSString *)account_id withUseData:(id)userData withCompleteBlock:(MongoCompletion)block
{
    NSLog(@". knote id: %@ file ids: %@",knote[@"_id"],knote[@"file_ids"]);
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        int key = 0;
        __block WM_NetworkStatus ret = NetworkFailure;
        
        if ( dbconn ) {

            [knote setObject:account_id forKey:@"account_id"];
            
            if ([[knote objectForKey:@"type"] isEqualToString:@"key_knote"] == YES ) {
                key = 1;
                coll = [dbconn collectionNamed:METEORCOLLECTION_KEY];
            } else {
                coll = [dbconn collectionNamed:METEORCOLLECTION_KNOTES];
            }
            if ( coll ) {
                NSError *error = nil;
                MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
                
                NSString *pre_id = [knote objectForKey:@"_id"];
                
                if ( [pre_id length] == 17) {
                    [pred1 keyPath:@"_id" matches:pre_id];
                } else {
                    [pred1 keyPath:@"_id" matches:[BSONObjectID objectIDWithString:pre_id]];
                }
                MongoFindRequest *req1 = [MongoFindRequest findRequestWithPredicate:pred1];

                [req1 includeKey:@"file_ids"];
                
                MongoUpdateRequest *req = [MongoUpdateRequest updateRequestWithPredicate:pred1 firstMatchOnly:YES];
                if ([knote objectForKey:@"file_ids"]) {
                    [req keyPath:@"file_ids" setValue:[knote objectForKey:@"file_ids"]];
                }
                if ([knote objectForKey:@"htmlBody"]) {
                    [req keyPath:@"htmlBody" setValue:[knote objectForKey:@"htmlBody"]];
                    [req keyPath:@"body" setValue:[knote objectForKey:@"htmlBody"]];
                }
                [coll updateWithRequest:req error:&error];
                
                NSLog(@"update result[%@]",error);
                if (!error) {
                    ret = NetworkSucc;
                }
                
                if (!conn.isFinished) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(ret,nil,knote);
                    });
                    conn.isFinished = YES;
                }
            }
        }
    } withTimeOut:^(MonoConn *conn) {
        block(NetworkTimeOut,nil,nil);
    }];
}

// Converted
+(void)sendInsertKnotes:(NSMutableDictionary *)knote withUserId:(NSString *)userId withUseData:(id)userData withCompleteBlock:(MongoCompletion3)block
{
    NSMutableDictionary *postDic = knote;
    id uData = userData;
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        
        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        int key = 0;
        __block WM_NetworkStatus ret = NetworkFailure;
        __block NSString *new_id = nil;

        if ( dbconn ) {
            
            if ([single_mongodb sharedInstanceMethod].account_id == nil)
            {
                [single_mongodb sharedInstanceMethod].account_id = [single_mongodb getAccountID:userId withMongoConnection:dbconn];
            }
            NSLog(@"%@",[single_mongodb sharedInstanceMethod].account_id);
            if ([single_mongodb sharedInstanceMethod].account_id) {
                [knote setObject:[single_mongodb sharedInstanceMethod].account_id forKey:@"account_id"];
                
                if ([[knote objectForKey:@"type"] isEqualToString:@"key_knote"] == YES ) {
                    key = 1;
                    coll = [dbconn collectionNamed:METEORCOLLECTION_KEY];
                } else {
                    coll = [dbconn collectionNamed:METEORCOLLECTION_KNOTES];
                }
                
                
                if ( coll ) {
                    NSError *error = nil;
                    NSString *item_id = [knote objectForKey:@"_id"];
                    if ( item_id != nil && ![item_id hasPrefix:kKnoteIdPrefix])
                    {
                        NSLog(@"Updating existing knote");
                        new_id = item_id;
                        MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
                        
                        NSString *pre_id = [knote objectForKey:@"_id"];
                        
                        if ( [pre_id length] == 17) {
                            [pred1 keyPath:@"_id" matches:pre_id];
                        } else {
                            [pred1 keyPath:@"_id" matches:[BSONObjectID objectIDWithString:pre_id]];
                        }
                        
                        MongoUpdateRequest *req = [MongoUpdateRequest updateRequestWithPredicate:pred1 firstMatchOnly:YES];
                        //[req replaceDocumentWithDictionary:knote];
                        [req keyPath:@"timestamp" setValue:[knote objectForKey:@"timestamp"]];
                        if (key) {
                            
                            [req keyPath:@"note" setValue:[knote objectForKey:@"note"]];
                        } else if ([[knote objectForKey:@"type"] isEqualToString:@"poll"] == YES || [[knote objectForKey:@"type"] isEqualToString:@"checklist"] == YES ) {
                            
                            [req keyPath:@"options" setValue:[knote objectForKey:@"options"]];
                            [req keyPath:@"title" setValue:[knote objectForKey:@"title"]];
                            [req keyPath:@"message_subject" setValue:[knote objectForKey:@"message_subject"]];
                        } else if ([[knote objectForKey:@"type"] isEqualToString:@"deadline"] == YES ) {
                            
                            [req keyPath:@"deadline" setValue:[knote objectForKey:@"deadline"]];
                            [req keyPath:@"local_deadline" setValue:[knote objectForKey:@"local_deadline"]];
                            [req keyPath:@"deadline_subject" setValue:[knote objectForKey:@"deadline_subject"]];
                            [req keyPath:@"message_subject" setValue:[knote objectForKey:@"message_subject"]];
                        } else {
                            
                            [req keyPath:@"body" setValue:[knote objectForKey:@"body"]];
                            [req keyPath:@"htmlBody" setValue:[knote objectForKey:@"htmlBody"]];
                        }
                        [req keyPath:@"date" setValue:[knote objectForKey:@"date"]];
                        if ([knote objectForKey:@"file_ids"]) {
                            [req keyPath:@"file_ids" setValue:[knote objectForKey:@"file_ids"]];
                        }
                        if ([knote objectForKey:@"usertags"]) {
                            [req keyPath:@"usertags" setValue:[knote objectForKey:@"usertags"]];
                        }
                        [coll updateWithRequest:req error:&error];
                        
                        NSLog(@"update result[%@]",error);
                    } else {
                        NSLog(@"Creating new knote item_id: %@", item_id);
                        new_id = [item_id noPrefix:kKnoteIdPrefix];
                        if (!new_id || [new_id length]<10) {
                            new_id = [single_mongodb mongo_id_generator];
                            
                        }
                        
                        NSLog(@"item_id no prefix: %@", [item_id noPrefix:kKnoteIdPrefix]);
                        
                        [knote setObject:new_id forKey:@"_id"];

                        [coll insertDictionary:knote writeConcern:nil error:&error];
                        
                        NSLog(@"insert knote result[%@]",error);
                        
                        if(error)
                        {
                            NSError *serverError = [dbconn serverError];
                            
                            NSLog(@"connection [dbconn serverError]: %@", serverError);
                            
                            if(serverError.code == 11000)
                            {
                                if (!conn.isFinished)
                                {
                                    ret = NetworkSucc;
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        
                                        block(ret,nil,new_id,uData,postDic);
                                        
                                    });
                                    
                                    conn.isFinished = YES;
                                    
                                    return;
                                }

                            }

                        }
                    }
                    
                    NSLog(@">>>>>>>>debug:new_id:%@",new_id);
                    
                    if( error == nil)
                    {
                        ret = NetworkSucc;
                        
                        if (ret != NetworkSucc)
                        {
                            new_id = nil;
                        }
                    }
                }
            }
        }
        if (!conn.isFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(ret,nil,new_id,uData,postDic);
            });
            conn.isFinished = YES;
        }
    } withTimeOut:^(MonoConn *conn) {
        block(NetworkTimeOut,nil,nil,uData,postDic);
    }];

}

// Converted
+(NSString*)getAccountID:(NSString *)user_id withMongoConnection:(MongoConnection *)dbconn
{
    MongoDBCollection *coll = nil;
    NSError *error = nil;
    NSDictionary *resultDict = nil;
    BSONDocument *resultDoc = nil;
    NSString *_id = nil;
    
    if ( dbconn == nil)
        return _id;
    
    coll = [dbconn collectionNamed:METEORCOLLECTION_ACCOUNTS];
    
    if(coll != nil)
    {
        MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
        [pred1 keyPath:@"user_ids" arrayContainsAllObjects:user_id, nil];
        
        error = nil;
        
        MongoFindRequest *req1 = [MongoFindRequest findRequestWithPredicate:pred1];
        
        [req1 includeKey:@"_id"];
        error = nil;
        resultDoc = [coll findOneWithRequest:req1 error:&error];
        
        if ( resultDoc != Nil)
        {
            resultDict = [resultDoc dictionaryValue];
            
            _id = [resultDict objectForKey:@"_id"];
            
            NSLog(@"account_id[%@]",_id);
        }
        
    }
    
    return _id;
    
}

// Converted
+(void)sendRequestAccountID:(NSString *)user_id withCompleteBlock:(MongoCompletion)block
{
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        MongoConnection * dbconn = conn.conn;
        NSString *account_id = [single_mongodb getAccountID:user_id withMongoConnection:dbconn];
        
        if (!conn.isFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) {
                    block(NetworkSucc,nil,account_id);
                }
            });
            conn.isFinished = YES;
        }
    } withTimeOut:^(MonoConn *conn) {

        block(NetworkTimeOut,nil,nil);
    }];
}

// Converted
+(void)sendRequestUser:(NSString *)username email:(NSString *)email withCompleteBlock:(MongoCompletion)block
{
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        
        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        NSError *error = nil;
        BSONDocument *resultDoc = nil;
        NSDictionary *resultDict = nil;
        WM_NetworkStatus ret = NetworkFailure;
        if(username || email)
        {
            if ( dbconn ) {
                coll = [dbconn collectionNamed:METEORCOLLECTION_USERS];
                if ( coll )
                {
                    MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
                    if(username && username.length > 0){
                        [pred1 keyPath:@"username" matches:username];
                    }
                    if(email && email.length > 0){
                        [pred1 keyPath:@"emails.address" matches:email];
                    }
                    
                    MongoFindRequest *req1 = [MongoFindRequest findRequestWithPredicate:pred1];
                    
                    [req1 includeKey:@"_id"];
                    [req1 includeKey:@"emails"];
                    [req1 includeKey:@"username"];
                    
                    error = nil;
                    resultDoc = [coll findOneWithRequest:req1 error:&error];
                    NSLog(@"after looking for user error: %@ resultDoc: %@", error, resultDoc);
                    if (error == nil) {
                        ret = NetworkSucc;
                        if (resultDoc) {
                            resultDict = [resultDoc dictionaryValue];
                        }
                    } else {
                        NSLog(@"%@",error);
                    }
                }
            }
        }
        if (!conn.isFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(ret,nil,resultDict);
            });
            conn.isFinished = YES;
        }
    } withTimeOut:^(MonoConn *conn) {

        block(NetworkTimeOut,nil,nil);
    }];

}

// Not using
+(void)sendRequestKeyNotes:(NSString *)_id withCompleteBlock:(MongoCompletion)block
{
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        NSError *error = nil;
        NSArray *resultDocArray = nil;
        WM_NetworkStatus ret = NetworkFailure;
        
        if ( dbconn ) {
            coll = [dbconn collectionNamed:METEORCOLLECTION_KEY];
            
            
            if(coll != nil) {
                MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
                [pred1 keyPath:@"_id" matches:_id];
                
                error = nil;
                
                MongoFindRequest *req1 = [MongoFindRequest findRequestWithPredicate:pred1];
                [req1 includeKey:@"type"];
                [req1 includeKey:@"account_id"];
                [req1 includeKey:@"name"];
                [req1 includeKey:@"note"];
                [req1 includeKey:@"order"];
                [req1 includeKey:@"archived"];

                
                [req1 includeKey:@"message_subject"];
                [req1 includeKey:@"timestamp"];
                [req1 includeKey:@"liked_account_ids"];
                [req1 includeKey:@"file_ids"];

                error = nil;
                resultDocArray = [coll findWithRequest:req1 error:&error];
                if(!error) {
                    ret = NetworkSucc;
                } else {
                    DLog(@"####Error: %@", error);
                    ret = NetworkFailure;
                }
            }
        }
        if (!conn.isFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(ret, nil,resultDocArray);
            });
            conn.isFinished = YES;
        }
    } withTimeOut:^(MonoConn *conn) {
        block(NetworkTimeOut, nil,nil);
    }];
    
}

// Not using
+(void)sendRequestLockInfo:(NSString *)_id withCompleteBlock:(MongoCompletion)block
{
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        NSError *error = nil;
        NSDictionary *resultDict = nil;
        BSONDocument *resultDoc = nil;
        WM_NetworkStatus ret = NetworkFailure;
        

        if ( dbconn ) {
            coll = [dbconn collectionNamed:METEORCOLLECTION_KNOTES];
            
            if(coll != nil) {
                MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
                [pred1 keyPath:@"_id" matches:_id];
                
                error = nil;
                
                MongoFindRequest *req1 = [MongoFindRequest findRequestWithPredicate:pred1];
                
                [req1 includeKey:@"body"];
                [req1 includeKey:@"htmlBody"];
                
                [req1 includeKey:@"type"];
                [req1 includeKey:@"name"];
                [req1 includeKey:@"note"];
                [req1 includeKey:@"liked_account_ids"];
                [req1 includeKey:@"timestamp"];
                
                error = nil;
                NSLog(@"lockInfo findOne");
                resultDoc = [coll findOneWithRequest:req1 error:&error];
                NSLog(@"lockInfo fafter findOne");
                
                if ( error == nil && resultDoc != nil)
                {
                    resultDict = [resultDoc dictionaryValue];
                    ret = NetworkSucc;
                    NSLog(@"htmlBody[%@]",[resultDict objectForKey:@"htmlBody"]);
                }
            }
        }
        if (!conn.isFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(ret, nil, resultDoc);
            });
            conn.isFinished = YES;
        }

    } withTimeOut:^(MonoConn *conn) {
        block(NetworkTimeOut, nil, nil);
    }];
}

// Converted
-(int)sendRequestUpdateTopicLockedIdKeyId:(NSString *)topic_id field:(NSString *)_id keyValue:(NSString*)value withMongoConnection:(MongoConnection *)dbconn
{
    MongoDBCollection *coll = nil;

    if ( dbconn == nil) {
        return NetworkFailure;
    }
    
    coll = [dbconn collectionNamed:METEORCOLLECTION_TOPICS];
    
    
    if ( coll != nil) {
        NSError *error = nil;
        
        if ( topic_id != nil )
        {
            MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
          
            [pred1 keyPath:@"_id" matches:topic_id];
            
            
            MongoUpdateRequest *req = [MongoUpdateRequest updateRequestWithPredicate:pred1 firstMatchOnly:YES];
            
            if ( _id != nil )
            {
               [req keyPath:_id setValue:value];
            }
            
            [coll updateWithRequest:req error:&error];
            
            NSLog(@"update result[%@]",error);
            if( error != NULL)
                return NetworkFailure;
            
        }
    }
    return NetworkSucc;
}

// Converted
+(void)sendRequestTopic:(NSString *)topic_id withUserId:(NSString *)userId withCompleteBlock:(MongoCompletion)block
{
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        
        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        WM_NetworkStatus ret = NetworkSucc;
        __block NSArray *results = nil;
        
        if ( dbconn ) {
            
            if ([single_mongodb sharedInstanceMethod].account_id == nil)
            {
                [single_mongodb sharedInstanceMethod].account_id = [single_mongodb getAccountID:userId withMongoConnection:dbconn];
            }
            
            coll = [dbconn collectionNamed:METEORCOLLECTION_TOPICS];
            MongoKeyedPredicate *predicate = [MongoKeyedPredicate predicate];
            [predicate keyPath:@"_id" matches:topic_id];
            MongoFindRequest *req1 = [MongoFindRequest findRequestWithPredicate:predicate];
            [req1 includeKey:@"_id"];
            [req1 includeKey:@"subject"];
            [req1 includeKey:@"changed_subject"];
            [req1 includeKey:@"participators"];
            [req1 includeKey:@"topic_type"];
            [req1 includeKey:@"key_id"];
            [req1 includeKey:@"locked_id"];
            [req1 includeKey:@"created_time"];
            [req1 includeKey:@"updated_time"];
            [req1 includeKey:@"archived"];
            [req1 includeKey:@"account_id"];
            [req1 includeKey:@"order"];
            [req1 includeKey:@"shared_account_ids"];
            [req1 includeKey:@"participator_account_ids"];
            [req1 includeKey:@"new"];
            [req1 includeKey:@"untouched"];
            [req1 includeKey:@"viewers"];
            [req1 includeKey:@"currently_contact_edit"];
            
            NSError *error = nil;
            results = [[coll findWithRequest:req1 error:&error] copy];
            if (!error) {
                ret = NetworkSucc;
            }
        }
        if (!conn.isFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(ret,nil,results);
            });
            conn.isFinished = YES;
        }
    } withTimeOut:^(MonoConn *conn) {
        block(NetworkTimeOut,nil,nil);
    }];
}

// Converted
+(void)sendRequestlockAction:(NSMutableDictionary *)knote withUserId:(NSString *)userId topicId:(NSString *)topic_id withUseData:(id)data  withCompleteBlock:(MongoCompletion3)block
{
    id uData = data;
    NSDictionary *postDic = knote;
    
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        
        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        WM_NetworkStatus ret = NetworkSucc;
        NSString *new_id = nil;

        
        if ( dbconn ) {
        
            if ([single_mongodb sharedInstanceMethod].account_id == nil)
            {
                [single_mongodb sharedInstanceMethod].account_id = [single_mongodb getAccountID:userId withMongoConnection:dbconn];
            }
            [knote setObject:[single_mongodb sharedInstanceMethod].account_id forKey:@"account_id"];
            
            coll = [dbconn collectionNamed:METEORCOLLECTION_KNOTES];
            
            if ( coll != nil)
            {
                NSError *error = nil;
                
                new_id = [single_mongodb mongo_id_generator];
                
                [knote setObject: new_id  forKey:@"_id"] ;
                [coll insertDictionary:knote writeConcern:nil error:&error];
                NSLog(@"insert knote lock result[%@]",error);
                
                if ( error == nil)
                {
                    if ( [sharedInstance sendRequestUpdateTopicLockedIdKeyId:topic_id field:@"locked_id" keyValue:new_id withMongoConnection:dbconn] != 0)
                        ret = NetworkFailure;
                    
                }
                else
                {
                    ret = NetworkFailure;
                }
                
                if(ret == NetworkSucc)
                {
                    ret = [self postedKnotesTopicID:postDic[@"topic_id"] userID:userId knoteID:postDic[@"_id"]];
                    if (ret != NetworkSucc) {
                        new_id = nil;
                    }

                }
            }
        }
        if (!conn.isFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(ret,nil,new_id,uData,knote);
            });
            conn.isFinished = YES;
        }
    } withTimeOut:^(MonoConn *conn) {
        block(NetworkTimeOut,nil,nil,uData,knote);
    }];
    
}

// Converted
+(void)sendRequestUnlockAction:(NSMutableDictionary *)knote withUserId:(NSString *)userId topicId:(NSString *)topic_id withCompleteBlock:(MongoCompletion)block
{
    NSDictionary *postDic = knote;
    
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        
        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        WM_NetworkStatus ret = NetworkFailure;
        
        if ( dbconn ) {
            
            if ([single_mongodb sharedInstanceMethod].account_id == nil)
            {
                [single_mongodb sharedInstanceMethod].account_id = [single_mongodb getAccountID:userId withMongoConnection:dbconn];
            }
            [knote setObject:[single_mongodb sharedInstanceMethod].account_id forKey:@"account_id"];
            
            coll = [dbconn collectionNamed:METEORCOLLECTION_KNOTES];
            
            
            if ( coll != nil) {
                
                NSError *error = nil;
                NSString *new_id = nil;
                
                new_id = [single_mongodb mongo_id_generator];
                
                [knote setObject: new_id  forKey:@"_id"] ;
                [coll insertDictionary:knote writeConcern:nil error:&error];
                NSLog(@"insert knote unlock result[%@]",error);
                
                if ( error == nil) {
                    if ( [sharedInstance sendRequestUpdateTopicLockedIdKeyId:topic_id field:@"locked_id" keyValue:@"" withMongoConnection:dbconn] != 0) {
                        ret = NetworkFailure;
                    } else {
                        ret = NetworkSucc;
                    }
                }
                
                if( ret == NetworkSucc) {
                    ret = [self postedKnotesTopicID:postDic[@"topic_id"] userID:userId knoteID:postDic[@"_id"]];
                }
            }
        }
        if (!conn.isFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(ret,nil,nil);
            });
            conn.isFinished = YES;
        }
    } withTimeOut:^(MonoConn *conn) {
        block(NetworkTimeOut,nil,nil);
    }];

}

// Converted
+(void)sendRequestArchiveKnote:(NSString *)_id Archived:(BOOL)arhived isMessage:(BOOL)isMessage withCompleteBlock:(MongoCompletion)block
{
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        
        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        WM_NetworkStatus ret = NetworkFailure;
        NSError *error = nil;
        
        
        if ( dbconn ) {
            if (isMessage) {
                coll = [dbconn collectionNamed:METEORCOLLECTION_MESSAGES];
            } else {
                coll = [dbconn collectionNamed:METEORCOLLECTION_KNOTES];
            }
            
            if ( coll != nil && _id != nil)
            {
                MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
                
                [pred1 keyPath:@"_id" matches:_id];
                
                
                MongoUpdateRequest *req = [MongoUpdateRequest updateRequestWithPredicate:pred1 firstMatchOnly:YES];
                
                
                [req keyPath:@"archived" setValue:@(arhived)];
                
                [coll updateWithRequest:req error:&error];
                
                NSLog(@"update result[%@]",error);
                if( error == nil) {
                    ret = NetworkSucc;
                }
            }
        }
        if (!conn.isFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(ret,nil,nil);
            });
            conn.isFinished = YES;
        }
    } withTimeOut:^(MonoConn *conn) {
        block(NetworkTimeOut,nil,nil);
    }];
    return;

}

+(void)sendRequestUpdateKeyNote:(NSMutableDictionary *)knote withUserId:(NSString *)userId topicId:(NSString *)topic_id withUseData:(id)data withCompleteBlock:(MongoCompletion3)block
{
    id uData = data;
    NSDictionary *postDic = knote;
    
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        
        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        WM_NetworkStatus ret = NetworkSucc;
        NSString *new_id = nil;

        if ( dbconn ) {
            
            if ([single_mongodb sharedInstanceMethod].account_id == nil)
            {
                [single_mongodb sharedInstanceMethod].account_id = [single_mongodb getAccountID:userId withMongoConnection:dbconn];
            }
            [knote setObject:[single_mongodb sharedInstanceMethod].account_id forKey:@"account_id"];
        
            coll = [dbconn collectionNamed:METEORCOLLECTION_KEY];
            
            if ( coll != nil) {
                
                NSError *error = nil;
                
                new_id = [single_mongodb mongo_id_generator];
                
                [knote setObject: new_id  forKey:@"_id"] ;
                [coll insertDictionary:knote writeConcern:nil error:&error];
                NSLog(@"update key knote result[%@]",error);
                
                if ( error == nil) {
                    
                    if ( [sharedInstance sendRequestUpdateTopicLockedIdKeyId:topic_id field:@"key_id" keyValue:new_id withMongoConnection:dbconn] != 0)
                        ret = NetworkSucc;
                    
                } else {
                    new_id = nil;
                }
                
                if( ret == NetworkSucc) {

                    ret = [self postedKnotesTopicID:postDic[@"topic_id"] userID:userId knoteID:knote[@"_id"]];
                    if (ret != NetworkSucc) {
                        ret = NetworkFailure;
                        new_id = nil;
                    }
                }
            }
            

        }
        if (!conn.isFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(ret,nil,new_id,uData,postDic);
            });
            conn.isFinished = YES;
        }
    } withTimeOut:^(MonoConn *conn) {
        block(NetworkTimeOut,nil,nil,uData,postDic);
    }];
}

// Converted
+(void)sendRequestDeleteKeyNote:(NSString *)_id topicId:topic_id withCompleteBlock:(MongoCompletion)block
{
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        
        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        WM_NetworkStatus ret = NetworkFailure;
        NSError *error = nil;
        
        if ( dbconn ) {
            coll = [dbconn collectionNamed:METEORCOLLECTION_KEY];
            
            
            if ( coll != nil && _id != nil)
            {
                MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
                
                [pred1 keyPath:@"_id" matches:_id];
                
                
                MongoUpdateRequest *req = [MongoUpdateRequest updateRequestWithPredicate:pred1 firstMatchOnly:YES];
                
                
                [req keyPath:@"archived" setValue:@(YES)];
                
                [coll updateWithRequest:req error:&error];
                
                NSLog(@"update result[%@]",error);
                if( error != NULL)
                {
                    ret = NetworkFailure;
                }
                else
                {
                    if ( [sharedInstance sendRequestUpdateTopicLockedIdKeyId:topic_id
                                                                       field:@"key_id"
                                                                    keyValue:@""
                                                         withMongoConnection:dbconn] == 0) {
                        ret = NetworkSucc;
                    }
                }
            }
        }
        if (!conn.isFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block( ret, nil, nil);
            });
            conn.isFinished = YES;
        }
    } withTimeOut:^(MonoConn *conn) {
        
        block( NetworkTimeOut, nil, nil);
    }];
    return;

}

// Not using
+(void)sendRequestAddTopic:(NSMutableDictionary *)topic withUserId:(NSString *)userId withUseData:(id)data  withCompleteBlock:(MongoCompletion2)block
{
    NSLog(@"sendRequestAddTopic: %@", topic);

    NSMutableDictionary *knote = topic;

    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        
        NSString *new_id = nil;

        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        WM_NetworkStatus ret = NetworkFailure;
        
        if ( dbconn ){
            
            if ([single_mongodb sharedInstanceMethod].account_id == nil)
            {
                [single_mongodb sharedInstanceMethod].account_id = [single_mongodb getAccountID:userId withMongoConnection:dbconn];
            }
            NSString *accountID = [single_mongodb sharedInstanceMethod].account_id;
            if(!topic[@"account_id"]){
                topic[@"account_id"] = accountID;
            }
            if(!topic[@"shared_account_ids"]){
                topic[@"shared_account_ids"] = @[accountID];
            }
            
            topic[@"participator_account_ids"] = topic[@"shared_account_ids"];
            [topic removeObjectForKey:@"shared_account_ids"];

            coll = [dbconn collectionNamed:METEORCOLLECTION_TOPICS];
            
            if ( coll != nil) {
                NSError *error = nil;
                new_id = topic[@"_id"];
                if (!new_id){
                    new_id = [single_mongodb mongo_id_generator];
                } else if ([new_id hasPrefix:kKnoteIdPrefix]) {
                    new_id = [new_id noPrefix:kKnoteIdPrefix];
                }
                
                [knote setObject:new_id  forKey:@"_id"] ;
                [coll insertDictionary:topic writeConcern:nil error:&error];
                NSLog(@"insert topic result[%@]",error);
                
                if ( error == nil) {
                    ret = NetworkSucc;
                } else {
                    NSError *serverError = [coll serverError];
                    NSLog(@"serverError: %@", [coll serverError]);
                    if(serverError.code == 11000){
                        //Duplicate key error, was already uploaded
                        ret = NetworkSucc;


                    } else {
                        new_id = nil;

                    }
                }
            }
        }
        if (!conn.isFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(ret,nil,new_id,data);
            });
            conn.isFinished = YES;
        }
    } withTimeOut:^(MonoConn *conn) {
        block(NetworkTimeOut,nil,nil,data);
    }];

}

// Converted
+(void)sendRequestFile:(NSString *)file_id withCompleteBlock:(MongoCompletion)block
{
    AppDelegate* app = [AppDelegate sharedDelegate];
    
    NSLog(@"%@", app.meteor);
    
    NSLog(@"sendRequestFile file_id: %@", file_id);
    
    [[AppDelegate sharedDelegate] sendRequestFile:file_id
                                withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData)
    {
        
    }];
    
    if(!file_id){
        NSLog(@"ERROR: sendRequestFile has nil file_id");
        return;
    }

    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        NSError *error = nil;
        //NSArray *resultDocArray = nil;
        __block WM_NetworkStatus ret = NetworkFailure;
        __block FileEntity* file = nil;
        if ( dbconn ) {
            
            coll = [dbconn collectionNamed:METEORCOLLECTION_FILES];
            
            if(coll != nil && file_id != nil)
            {
                MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
                [pred1 keyPath:@"_id" matches:file_id];
                
                MongoFindRequest *req1 = [MongoFindRequest findRequestWithPredicate:pred1];
                [req1 includeKey:@"data"];
                [req1 includeKey:@"name"];
                [req1 includeKey:@"s3_url"];
                [req1 includeKey:@"short_photo_url"];
                
                error = nil;
                BSONDocument *doc = [coll findOneWithRequest:req1 error:&error];
                if (error) {
                    NSLog(@"mongo error findOneWithRequest %@", error);
                }
                
                if (doc)
                {
                    NSDictionary *docDict = [doc dictionaryValue];
                    NSLog(@"GOT FILE FROM MONGO:\n%@", docDict);

                    
                    NSString *name = docDict[@"name"];
                    NSData *data = docDict[@"data"];
                    
                    [[MagicalRecordStack defaultStack] saveWithBlock:^(NSManagedObjectContext *localContext) {
                        //
                        file = [FileEntity MR_findFirstByAttribute:@"file_id" withValue:file_id inContext:localContext];
                        if (file == nil) {
                            file = [FileEntity MR_createEntity];
                            file.file_id = file_id;
                            NSLog(@"creating new FileEntity: %@", file_id);

                        }
                        if ([file isFault]) {
                            [file MR_refresh];
                        }
                        
                        NSString *extension = [name pathExtension];
                        if (extension == nil || extension.length == 0) {
                            extension = @"jpg";
                        } else {
                            extension = [extension lowercaseString];
                        }
                        
                        BOOL isImage = NO;
                        BOOL isPNG = NO;
                        BOOL isPDF = NO;
                        
                        if ([@[@"jpg",@"jpeg"] containsObject:extension]) {
                            isImage = YES;
                        } else if([extension isEqualToString:@"png"]){
                            isImage = YES;
                            isPNG = YES;
                        } else if([extension isEqualToString:@"pdf"]){
                            isPDF = YES;
                        }
                        
                        file.name = name;
                        file.isImage = @(isImage);
                        file.isPNG = @(isPNG);
                        file.isPDF = @(isPDF);
                        file.ext = extension;
                        file.size = @([data length]);
                        file.full_url = docDict[@"s3_url"];
                        file.sendFlag = @(SendSuc);
                        if (data && [data length]>0) {
                            [FileManager saveData:data fileID:file_id extension:extension];
                        }
                        file.isDownloaded = @(YES);
                        ret = NetworkSucc;
                    } completion:^(BOOL success, NSError *error) {
                        if (!conn.isFinished) {
                            if (block) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    block(ret,nil,file_id);
                                });
                            }
                            conn.isFinished = YES;
                        }
                    }];
                }
                else
                {
                    if (!conn.isFinished) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (block) {
                                block(ret,nil,file_id);
                            }
                        });
                        conn.isFinished = YES;
                    }
                }
            }
        } else {
            if (!conn.isFinished) {
                if (!conn.isFinished) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(ret,nil,nil);
                    });
                    conn.isFinished = YES;
                }
            }
        }

    } withTimeOut:^(MonoConn *conn) {
        block(NetworkTimeOut,nil,nil);
    }];
}

// Converted
+(void)sendRequestAddFile:(id)fileInfo withAccountId:(NSString *)account_id withUseData:(id)userData withCompleteBlock:(MongoCompletion)block
{
    FileInfo *fInfo = fileInfo;
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        NSError *error = nil;
        MongoConnection * dbconn = conn.conn;
        WM_NetworkStatus ret = NetworkFailure;

        if (dbconn) {
    
            MongoDBCollection *coll = [dbconn collectionNamed:METEORCOLLECTION_FILES];
            //NSLog(@"maxBSONSize %d", [dbconn maxBSONSize]);
            
            NSLog(@"new id is %@", fInfo.imageId);
            
            error = nil;

            
            NSString *mime = [[fInfo.imageName lowercaseString] hasSuffix:@"png"] ? @"image/png" : @"image/jpg";
            
            AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;

            NSString *full_url = [NSString stringWithFormat:@"https://%@.s3.amazonaws.com/uploads/%@_%@",app.server.s3_bucket,fInfo.imageId,fInfo.imageName];
            NSDictionary *postDic = @{
                                      @"_id":fInfo.imageId,
                                      @"account_id":account_id,
                                      @"name":fInfo.imageName,
                                      @"type":mime,
                                      @"s3_url":full_url,
                                      @"size":@(fInfo.imageSize)
                                      };
            [coll insertDictionary:postDic
                      writeConcern:nil
                             error:&error];
            
            NSLog(@"FILE WROTE IN MONGO:\n%@", postDic);
            
            if (error) {
                DLog(@"error writing mongo file object: %@", error);
                MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
                [pred1 keyPath:@"_id" matches:fInfo.imageId];
                
                MongoFindRequest *req1 = [MongoFindRequest findRequestWithPredicate:pred1];
                [req1 includeKey:@"_id"];
                error = nil;
                NSArray * resultDocArray = [coll findWithRequest:req1 error:&error];
                if ([resultDocArray count]>0) {
                    ret = NetworkSucc;
                } else {
                    DLog(@"error writing mongo file object: %@", error);
                }
            } else {
                ret = NetworkSucc;
                DLog(@"wrote file in mongo");
            }
        }
        if (!conn.isFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(ret,nil,nil);
            });
            conn.isFinished = YES;
        }
    } withTimeOut:^(MonoConn *conn) {
        block(NetworkTimeOut,nil,nil);
    }];
}

// Converted
+(void)sendRequestAddPin:(BOOL )pinned itemType:(CItemType)type knoteId:(NSString *)knote_id order:(int64_t)neworder withCompleteBlock:(MongoCompletion)block;
{
    NSLog(@".");
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        
        MongoDBCollection *coll = nil;
        MongoConnection *dbconn = conn.conn;
        WM_NetworkStatus ret = NetworkFailure;
        
        
        if ( dbconn ) {
            if (type != C_KEYKNOTE) {
                coll = [dbconn collectionNamed:METEORCOLLECTION_KNOTES];
            } else {
                coll = [dbconn collectionNamed:METEORCOLLECTION_KEY];
            }
            
            
            if (coll != nil) {
                NSError *error = nil;
                MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
                
                [pred1 keyPath:@"_id" matches:knote_id];
                
                MongoUpdateRequest *req = [MongoUpdateRequest updateRequestWithPredicate:pred1 firstMatchOnly:YES];
                
                
                [req keyPath:@"pinned" setValue:@(pinned)];
                
                [coll updateWithRequest:req error:&error];
                
                NSLog(@"update error?[%@]",error);
                
                
                if (error == nil) {
                    ret = NetworkSucc;
                }
            }
        }
        if (!conn.isFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(ret, nil, nil);
            });
            conn.isFinished = YES;
        }
    } withTimeOut:^(MonoConn *conn) {
        block(NetworkTimeOut,nil,nil);
    }];
}

// Converted
+(void)sendRequestAddLike:(NSMutableArray *)liked_array itemType:(CItemType)type knoteId:(NSString *)knote_id withCompleteBlock:(MongoCompletion)block
{
    NSLog(@".");
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        
        MongoDBCollection *coll = nil;
        MongoConnection *dbconn = conn.conn;
        WM_NetworkStatus ret = NetworkFailure;
        
        
        if ( dbconn ) {
            if (type != C_KEYKNOTE) {
                coll = [dbconn collectionNamed:METEORCOLLECTION_KNOTES];
            } else {
                coll = [dbconn collectionNamed:METEORCOLLECTION_KEY];
            }
            
            
            if (coll != nil) {
                NSError *error = nil;
                MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
                
                [pred1 keyPath:@"_id" matches:knote_id];
                
                MongoUpdateRequest *req = [MongoUpdateRequest updateRequestWithPredicate:pred1 firstMatchOnly:YES];
                
                
                [req keyPath:@"liked_account_ids" setValue:liked_array];
                NSLog(@"setting liked_account_ids to: %@", liked_array);
                
                [coll updateWithRequest:req error:&error];
                
                NSLog(@"update error?[%@]",error);
                
                
                if (error == nil) {
                    ret = NetworkSucc;
                }
            }
        }
        if (!conn.isFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(ret, nil, nil);
            });
            conn.isFinished = YES;
        }
    } withTimeOut:^(MonoConn *conn) {
        block(NetworkTimeOut,nil,nil);
    }];
}

// Converted, but not using.

+(void)sendRequestUpdteParticipators:(NSMutableArray *)new_participators withTopicId:(NSString *)topicId withUseData:(id)userData withCompleteBlock:(MongoCompletion)block
{
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        
        MongoDBCollection *coll = nil;
        MongoConnection *dbconn = conn.conn;
        WM_NetworkStatus ret = NetworkFailure;
        
        if ( dbconn ) {
            coll = [dbconn collectionNamed:METEORCOLLECTION_TOPICS];
            
            if (coll != nil) {
                NSError *error = nil;
                MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
                
                [pred1 keyPath:@"_id" matches:topicId];
                
                MongoUpdateRequest *req = [MongoUpdateRequest updateRequestWithPredicate:pred1 firstMatchOnly:YES];
                
                [req keyPath:@"participators" setValue:new_participators];
                
                [coll updateWithRequest:req error:&error];
                
                NSLog(@"update result[%@]",error);
                
                if (error == nil) {
                    ret = NetworkSucc;
                }
            }
        }
        if (!conn.isFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(ret,nil,nil);
            });
            conn.isFinished = YES;
        }
    } withTimeOut:^(MonoConn *conn) {
        block(NetworkTimeOut,nil,nil);
    }];

}

// Converted
+(void)sendRequestDeleteTopic:(NSString *)_id withArchived:(NSArray*)archived withCompleteBlock:(MongoCompletion)block
{
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        
        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        WM_NetworkStatus ret = NetworkFailure;
        NSError *error = nil;
        
        if ( dbconn )
        {
            coll = [dbconn collectionNamed:METEORCOLLECTION_TOPICS];
            
            if ( coll != nil && _id != nil)
            {
                MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
                
                [pred1 keyPath:@"_id" matches:_id];
                
                MongoUpdateRequest *req = [MongoUpdateRequest updateRequestWithPredicate:pred1 firstMatchOnly:YES];
                
//                [req keyPath:@"participators" setValue:@[]];
                [req keyPath:@"archived" setValue:archived];
                
                [coll updateWithRequest:req error:&error];
                
                NSLog(@"sendRequestDeleteTopic update result[%@]",error);
                
                if( error == NULL)
                {
                    ret = NetworkSucc;
                }
                else
                {
                    NSLog(@"server error: %@", [dbconn serverError]);
                }
            }
        }
        
        if (!conn.isFinished)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(ret, nil, archived);
            });
        
            conn.isFinished = YES;
        }
        
    } withTimeOut:^(MonoConn *conn) {
      
        block(NetworkTimeOut,nil,nil);
        
    }];
    
    return;
}

// Converted but not using.
+ (void)sendRequestArchivePeople:(NSString *)_id Archived:(BOOL)arhived withCompleteBlock:(MongoCompletion)block
{
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        
        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        WM_NetworkStatus ret = NetworkFailure;
        NSError *error = nil;
        
        if ( dbconn ) {

            coll = [dbconn collectionNamed:METEORCOLLECTION_PEOPLE];
            
            if ( coll != nil && _id != nil) {
                
                MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
                
                [pred1 keyPath:@"_id" matches:_id];
#if false
                MongoUpdateRequest *req = [MongoUpdateRequest updateRequestWithPredicate:pred1 firstMatchOnly:YES];
                
                [req keyPath:@"archived" setValue:@(arhived)];
                
                [coll updateWithRequest:req error:&error];
#else
                
                [coll removeWithPredicate:pred1 writeConcern:nil error:&error];
                
#endif
                
                NSLog(@"sendRequestArchivePeople update result[%@]",error);
                if( error == nil) {
                    ret = NetworkSucc;
                }
            } 
        }
        if (!conn.isFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(ret, nil, nil);
            });
            conn.isFinished = YES;
        }
    } withTimeOut:^(MonoConn *conn) {
        block(NetworkTimeOut,nil,nil);
    }];
}

// Converted
+ (void)sendRequestUpdateList:(NSString *)_id withOptionArray:(NSArray *)array withCompleteBlock:(MongoCompletion)block
{
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        
        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        WM_NetworkStatus ret = NetworkFailure;
        NSError *error = nil;
        
        if ( dbconn ) {
            
            coll = [dbconn collectionNamed:METEORCOLLECTION_KNOTES];
            
            if ( coll != nil && _id != nil) {
                
                MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
                
                [pred1 keyPath:@"_id" matches:_id];
                
                MongoUpdateRequest *req = [MongoUpdateRequest updateRequestWithPredicate:pred1 firstMatchOnly:YES];
                [req keyPath:@"options" setValue:array];

                
                [coll updateWithRequest:req error:&error];
                
                NSLog(@"sendRequestUpdateList update result[%@]",error);
                if( error == nil) {
                    ret = NetworkSucc;
                }
            }
        }
        if (!conn.isFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(ret, nil, nil);
            });
            conn.isFinished = YES;
        }
    } withTimeOut:^(MonoConn *conn) {
        block(NetworkTimeOut,nil,nil);
    }];
}

// Not working
+ (void)sendRequestHotKnotes:(NSString *)account_id withCompleteBlock:(MongoCompletion)block
{
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {

        MongoDBCollection *coll = nil;
        MongoConnection * dbconn0 = conn.conn;
        WM_NetworkStatus ret = NetworkFailure;
        NSError *error = nil;


        if ( dbconn0 ) {

            coll = [dbconn0 collectionNamed:METEORCOLLECTION_TOPICS];

            if ( coll != nil && account_id != nil) {

                MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];

                MongoKeyedPredicate *archivedNotPresent = [MongoKeyedPredicate predicate];
                [archivedNotPresent valueDoesNotExistForKeyPath:@"archived"];

                MongoKeyedPredicate *notArchived = [MongoKeyedPredicate predicate];
                [notArchived keyPath:@"archived" arrayDoesNotContainAllObjects:account_id, nil];

                MongoPredicate *archivedOrPredicate = [MongoPredicate orPredicateWithSubPredicates:archivedNotPresent, notArchived, nil];

                [pred1 keyPath:@"participator_account_ids" matches:account_id];
                [pred1 keyPath:@"untouched" doesNotMatchAnyObjects:@(YES), nil];

                MongoPredicate *finalPredicate = [MongoPredicate andPredicateWithSubPredicates:archivedOrPredicate, pred1, nil];

                MongoFindRequest *findRequest = [MongoFindRequest findRequestWithPredicate:finalPredicate];
                [findRequest includeKey:@"_id"];
//                [findRequest includeKey:@"subject"];

                error = nil;

                NSLog(@"Fetching topic IDs");

                NSArray *topic_documents = [coll findWithRequest:findRequest error:&error];
                ret = NetworkSucc;
                
                if(error){
                    ret = NetworkFailure;
                    NSLog(@"Error fetching all topic IDs: %@", error);
                }
                if(!topic_documents || topic_documents.count == 0){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        block(ret,error,@[]);
                    });
                    conn.isFinished = YES;
                    return;
                }
                [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
                    MongoConnection * dbconn1 = conn.conn;
                    WM_NetworkStatus ret = NetworkFailure;
                    NSError *error = nil;

                    NSArray *topic_dicts = [topic_documents valueForKey:@"dictionaryValue"];
                    NSArray *topic_ids = [topic_dicts valueForKey:@"_id"];
                    
                    NSLog(@"Got all topic IDS count %d", (int)topic_ids.count);
                    
                    MongoKeyedPredicate *knotesPred = [MongoKeyedPredicate predicate];
                    [knotesPred keyPath:@"topic_id" matchesAnyFromArray:topic_ids];
                    [knotesPred keyPath:@"account_id" doesNotMatchAnyObjects:account_id, nil];
                    [knotesPred keyPath:@"is_splitted" doesNotMatchAnyObjects:@(YES), nil];
                    [knotesPred keyPath:@"archived" doesNotMatchAnyObjects:@(YES), nil];
                    
                    MongoFindRequest *messageFindRequest = [MongoFindRequest findRequestWithPredicate:knotesPred];
                    [messageFindRequest sortByKey:@"timestamp" ascending:NO];
                    [messageFindRequest setLimitResults:HOT_KNOTE_FETCH_LIMIT];
                    MongoDBCollection *messagesCollection = [dbconn1 collectionNamed:METEORCOLLECTION_MESSAGES];
                    error = nil;
                    
                    NSLog(@"Requesting hot messages");
                    NSArray *message_documents = [messagesCollection findWithRequest:messageFindRequest error:&error];
                    if(error){
                        ret = NetworkFailure;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            block(ret,error,@[]);
                        });
                        NSLog(@"2.Error fetching all topic IDs: %@", error);
                    }
                    NSLog(@"Got %d hot messages", (int)message_documents.count);
                    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
                        MongoConnection * dbconn2 = conn.conn;
                        WM_NetworkStatus ret = NetworkFailure;
                        NSError *error = nil;
                        NSArray *message_dicts = [message_documents valueForKey:@"dictionaryValue"];
                        NSLog(@"Got %d hot message_dicts", (int)message_dicts.count);
                        
                        [knotesPred keyPath:@"type" doesNotMatchAnyObjects:@"lock", nil];
                        
                        
                        MongoFindRequest *knoteFindRequest = [MongoFindRequest findRequestWithPredicate:knotesPred];
                        [knoteFindRequest sortByKey:@"timestamp" ascending:NO];
                        [knoteFindRequest setLimitResults:HOT_KNOTE_FETCH_LIMIT];
                        
                        MongoDBCollection *knotesCollection = [dbconn2 collectionNamed:METEORCOLLECTION_KNOTES];
                        
                        error = nil;
                        NSLog(@"Requesting hot knotes");
                        NSArray *knote_documents = [knotesCollection findWithRequest:knoteFindRequest error:&error];
                        NSLog(@"Got %d hot knotes", (int)knote_documents.count);
                        if(error){
                            ret = NetworkFailure;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                block(ret,error,@[]);
                            });
                            NSLog(@"2.Error fetching all topic IDs: %@", error);
                        } else {
                            ret = NetworkSucc;
                            NSArray *knote_dicts = [knote_documents valueForKey:@"dictionaryValue"];
                            NSLog(@"Got %d hot knote_dicts", (int)knote_dicts.count);
                            
                            
                            NSArray *combined = [knote_dicts arrayByAddingObjectsFromArray:message_dicts];
                            
                            
                            //Only one latest per topic
                            NSMutableSet *topicsPresent = [NSMutableSet new];
                            NSMutableArray *uniquedDicts = [NSMutableArray new];
                            for(NSDictionary *dict in combined){
                                NSString *topic_id = dict[@"topic_id"];
                                //NSLog(@"hot message: %@ timestamp: %@ id: %@", dict[@"subject"], dict[@"timestamp"], topic_id);
                                if(topic_id && ![topicsPresent containsObject:topic_id]){
                                    //NSLog(@"included");
                                    [uniquedDicts addObject:dict];
                                    [topicsPresent addObject:topic_id];
                                }
                            }
                            
                            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
                            [uniquedDicts sortUsingDescriptors:@[sortDescriptor]];
                            
                            NSArray *limited = [uniquedDicts subarrayWithRange:NSMakeRange(0, MIN(uniquedDicts.count, HOT_KNOTE_DISPLAY_LIMIT))];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                block(ret,error,limited);
                                
                            });
                        }

                        conn.isFinished = YES;
                    } withTimeOut:^(MonoConn *conn) {
                        block(NetworkTimeOut,nil,nil);
                    }];
                    conn.isFinished = YES;
                } withTimeOut:^(MonoConn *conn) {
                    block(NetworkTimeOut,nil,nil);
                }];
            }
        }

        conn.isFinished = YES;
    } withTimeOut:^(MonoConn *conn) {
        block(NetworkTimeOut,nil,nil);
    }];
}

// Not using
+(void)getLatestNotification:(NSString*)email withCompleteBlock:(MongoCompletion)block
{
      [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
          MongoConnection * dbconn = conn.conn;
          WM_NetworkStatus ret = NetworkFailure;
          NSError *error = nil;
          MongoDBCollection *accounts = [dbconn collectionNamed:METEORCOLLECTION_NOTIFICATIONS];
          if(!accounts){
              NSLog(@"Dont have users and notification collections");
              block(ret,nil,nil);
              return;
          }
        
            MongoKeyedPredicate *accountPredicate = [MongoKeyedPredicate predicate];
           [accountPredicate keyPath:@"email" matches:email];
              MongoFindRequest *messageFindRequest = [MongoFindRequest findRequestWithPredicate:accountPredicate];
          [messageFindRequest sortByKey:@"date_created" ascending:NO];
          [messageFindRequest setLimitResults:1];

          NSArray *accountDoc = [accounts findWithRequest:messageFindRequest error:&error];
          
          if(error)
          {
              ret = NetworkFailure;
              dispatch_async(dispatch_get_main_queue(), ^{
                  block(ret,error,@[]);
              });
              NSLog(@"2.Error fetching all topic IDs: %@", error);
              return;
          }
          if(!accountDoc){
              NSLog(@"couldnt find notification  with email: %@", email);
              block(NetworkSucc,nil,nil);
              return;
          }
          else
          {
              ret =NetworkSucc;
              block(ret,error, accountDoc );
          }

        
      } withTimeOut:^(MonoConn *conn) {
          block(NetworkTimeOut,nil,nil);
      }];
}

// Converted
+(void)checkIfUserHasGoogle:(NSString *)account_id withCompleteBlock:(MongoCompletion)block
{
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {

        //step 1.get userIDs
        MongoConnection * dbconn = conn.conn;
        WM_NetworkStatus ret = NetworkFailure;
        NSError *error = nil;
        
        MongoDBCollection *accounts = [dbconn collectionNamed:METEORCOLLECTION_ACCOUNTS];
        
        if(!accounts)
        {
            NSLog(@"Dont have users and user_accounts collections");
            
            block(ret,nil,nil);
            
            return;
        }
        
        MongoKeyedPredicate *accountPredicate = [MongoKeyedPredicate predicate];
        
        [accountPredicate keyPath:@"_id" matches:account_id];
        
        BSONDocument *accountDoc = [accounts findOneWithPredicate:accountPredicate error:&error];
        
        if(!accountDoc)
        {
            NSLog(@"couldnt find account with id: %@", account_id);
            block(NetworkSucc,nil,nil);
            return;
        }
        
        //notificationStatus
        
        NSDictionary *account = [accountDoc dictionaryValue];
        
        __block  NSArray *userIDs = [account[@"user_ids"] copy];
        
        if(!userIDs && [userIDs isKindOfClass:[NSArray class]] && [userIDs count]<1){
            
            NSLog(@"no userIds for account: %@", account_id);
            
            block(NetworkSucc,nil,nil);
            
            return;
        }
        
        [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        
            //step 2.get google_id and user_id by userIDs
            MongoConnection * dbconn = conn.conn;
            WM_NetworkStatus ret = NetworkFailure;
            
            NSError *error = nil;
            
            if (!dbconn)
            {
                NSLog(@"No DB connection");
                
                block(ret,nil,nil);
                
                return;
            }
            
            MongoDBCollection *users = [dbconn collectionNamed:METEORCOLLECTION_USERS];
            
            if(!(users))
            {
                NSLog(@"Dont have users and user_accounts collections");
                block(NetworkSucc,nil,nil);
                return;
            }
            
            if(!account_id || account_id.length == 0)
            {
                NSLog(@"Dont have account_id");
                block(NetworkSucc,nil,nil);
                return;
            }
            
            MongoKeyedPredicate *usersPredicate = [MongoKeyedPredicate predicate];
            
            [usersPredicate keyPath:@"_id" matchesAnyFromArray:userIDs];
            [usersPredicate valueExistsForKeyPath:@"services.google"];
            
            NSArray *googleUserDocs = [users findWithPredicate:usersPredicate error:&error];
            
            NSString *notification =account[@"notificationStatus"];
            
            if(googleUserDocs && googleUserDocs.count > 0)
            {
                NSDictionary *googleUser = [googleUserDocs.firstObject dictionaryValue];
                NSString *user_id = googleUser[@"_id"];
                NSDictionary *googleDict = googleUser[@"services"][@"google"];
                NSString *google_id = googleDict[@"id"];
                
                NSMutableDictionary *userData = [NSMutableDictionary new];
                
                if (google_id)
                {
                    [userData setObject:google_id forKey:@"google_id"];
                }
                
                if (user_id)
                {
                    [userData setObject:user_id forKey:@"user_id"];
                }
                
                if (notification)
                {
                    [userData setObject:notification forKey:@"notificationStatus"];
                }
                
                NSLog(@"User DOES have a google account linked, ids: %@", userData);
                
                block(NetworkSucc,nil,[userData copy]);
            }
            else
            {
                NSLog(@"User DOES NOT have a google account linked");

                NSDictionary *userData = nil;
                
                if(notification)
                {
                    userData = @{@"notificationStatus":notification};
                }
                
                block(NetworkSucc,nil,userData);
            }
            
            conn.isFinished = YES;
            
        } withTimeOut:^(MonoConn *conn) {
            block(NetworkTimeOut,nil,nil);
        }];
        
        conn.isFinished = YES;
        
    } withTimeOut:^(MonoConn *conn) {
        block(NetworkTimeOut,nil,nil);
    }];
}

// Converted
+(void)sendRequestSaveGoogle:(NSDictionary *)serviceData accountID:(NSString *)account_id withCompleteBlock:(MongoCompletion)block
{
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {

        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        
        NSError *error = nil;

        NSString *google_id = serviceData[@"id"];

        if ( dbconn )
        {
            coll = [dbconn collectionNamed:METEORCOLLECTION_USERS];

            if (coll != nil
                && account_id != nil
                && google_id != nil)
            {
                MongoKeyedPredicate *existingUserPredicate = [MongoKeyedPredicate predicate];
                
                [existingUserPredicate keyPath:@"services.google.id" matches:google_id];
                
                BSONDocument *existingUserBSON = [coll findOneWithPredicate:existingUserPredicate error:&error];

                if(error)
                {
                    NSLog(@"Error finding existing google user: %@", error);
                }

                NSString *user_id = nil;

                if(existingUserBSON)
                {
                    //user already exists, update it
                    NSDictionary *existingUserDict = [existingUserBSON dictionaryValue];
                    
                    user_id = existingUserDict[@"_id"];

                    MongoUpdateRequest *userUpdate = [MongoUpdateRequest updateRequestWithPredicate:existingUserPredicate firstMatchOnly:YES];
                    
                    for(NSString *key in serviceData.allKeys)
                    {
                        NSString *absoluteKey = [@"services.google." stringByAppendingString:key];
                        [userUpdate keyPath:absoluteKey setValue:serviceData[key]];
                    }
                    
                    error = nil;
                    
                    BOOL updatedUser = [coll updateWithRequest:userUpdate error:&error];
                    
                    NSLog(@"updated user with new google info? %d error: %@", updatedUser, error);
                }
                else
                {
                    //create new user
                    user_id = [single_mongodb mongo_id_generator];
                    
                    NSDictionary *userDict = @{@"_id":user_id,
                                               @"createdAt":[NSDate date],
                                               @"services":@{@"google":serviceData,
                                                             @"resume":@{@"loginTokens":@[]
                                                                         }
                                                             }
                                               };
                    error = nil;
                    
                    BOOL inserted = [coll insertDictionary:userDict writeConcern:nil error:&error];

                    NSLog(@"Inserted user into database sucess? %d error: %@", inserted, error);
                }

                NSLog(@"google user_id is: %@", user_id);

                error = nil;
                
                MongoDBCollection *accounts = [dbconn collectionNamed:METEORCOLLECTION_ACCOUNTS];
                MongoKeyedPredicate *accountPredicate = [MongoKeyedPredicate predicate];
                [accountPredicate keyPath:@"_id" matches:account_id];
                
                BSONDocument *existingAccountBSON = [accounts findOneWithPredicate:accountPredicate error:&error];
                
                if(error)
                {
                    NSLog(@"Error fetching account id: %@", account_id);
                }
                
                if(existingAccountBSON)
                {
                    NSDictionary *accountDict = [existingAccountBSON dictionaryValue];
                    NSArray *user_ids = accountDict[@"user_ids"];
                    
                    if(![user_ids containsObject:user_id])
                    {
                        //Save user id to account

                        error = nil;

                        MongoUpdateRequest *accountUpdate = [MongoUpdateRequest updateRequestWithPredicate:accountPredicate firstMatchOnly:YES];
                        
                        [accountUpdate arrayForKeyPath:@"user_ids" appendValue:user_id];
                        
                        BOOL savedAccount = [accounts updateWithRequest:accountUpdate error:&error];
                        
                        NSLog(@"saved account with new user id? %d error: %@", savedAccount, error);

                    }
                    else
                    {
                        NSLog(@"user_ids already contains it: %@", user_ids);
                    }

                }
                else
                {
                    NSLog(@"account_id %@ not found to update", account_id);
                }

                if(block && user_id)
                {
                    block(NetworkSucc, nil, user_id);
                }

            }
        }
        conn.isFinished = YES;

    } withTimeOut:^(MonoConn *conn) {
        block(NetworkTimeOut,nil,nil);
    }];
}

// Converted

+(void)sendRecordLoginData:(NSString *)username seconds:(NSTimeInterval)timeTaken error:(NSError *)error reason:(NSString *)reason
{
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        
        NSLog(@"sendRecordLoginData: %@ time: %f error: %@", username, timeTaken, error);
        
        MongoDBCollection *coll = nil;
        MongoConnection * dbconn = conn.conn;
        
        if ( dbconn ) {
            
            
            coll = [dbconn collectionNamed:MONGOCOLLECTION_LOGIN_DATA];
            if ( coll ) {
                
                BOOL isError = error != nil || reason != nil;

                NSDate *date = [NSDate date];
                NSString *loginUserName = username;
                if (!loginUserName) {
                    loginUserName = @"";
                }
                
                
                NSMutableDictionary *dict = [@{
                                       @"_id":[self mongo_id_generator],
                                       @"date":date,
                                       @"date_text":[date description],
                                       @"seconds":@(timeTaken),
                                       @"success":@(!isError),
                                       @"username":loginUserName
                                       } mutableCopy];
                
                if (isError) {
                    NSString *error_reason = reason;
                    if (!error_reason && error && error.userInfo) {
                        NSDictionary *desc = error.userInfo[NSLocalizedDescriptionKey];
                        if (desc && [desc isKindOfClass:[NSDictionary class]]) {
                            error_reason = desc[@"reason"];
                        }
                    }
                    if (!error_reason) {
                        error_reason = (id)[NSNull null];
                    }


                    dict[@"error"] = error ? [error description] : [NSNull null];
                    dict[@"error_reason"] = error_reason;
                }
                
                [coll insertDictionary:dict writeConcern:nil error:nil];
                
            }
            
        }
        conn.isFinished = YES;
    } withTimeOut:^(MonoConn *conn) {
        NSLog(@"todo Time out");
    }];
    
}

// Not using
+(void)sendRequestSaveNotificationStatus:(BOOL)notificationStatus accountID:(NSString *)account_id withCompleteBlock:(MongoCompletion)block
{
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
      
        MongoConnection * dbconn = conn.conn;
        //        WM_NetworkStatus ret = NetworkFailure;
        NSError *error = nil;
        
        if ( dbconn ) {
            
            MongoDBCollection *accounts = [dbconn collectionNamed:METEORCOLLECTION_ACCOUNTS];
            MongoKeyedPredicate *accountPredicate = [MongoKeyedPredicate predicate];
            [accountPredicate keyPath:@"_id" matches:account_id];
            BSONDocument *existingAccountBSON = [accounts findOneWithPredicate:accountPredicate error:&error];
            
            if(error)
            {
                NSLog(@"Error fetching account id: %@", account_id);
            }
            
            if(existingAccountBSON)
            {
//                NSDictionary *accountDict = [existingAccountBSON dictionaryValue];
                
                
                //Save user id to account
                
                error = nil;
                
                MongoUpdateRequest *accountUpdate = [MongoUpdateRequest updateRequestWithPredicate:accountPredicate firstMatchOnly:YES];
                [accountUpdate keyPath:@"notificationStatus" setValue:@(notificationStatus)];
                
                BOOL savedAccount = [accounts updateWithRequest:accountUpdate error:&error];
                NSLog(@"saved account with new user id? %d error: %@", savedAccount, error);
                
                
                
            } else {
                NSLog(@"account_id %@ not found to update", account_id);
            }
            
            
            if(block){
                block(NetworkSucc, nil, nil);
            }
            
        }
        
        conn.isFinished = YES;
        
    } withTimeOut:^(MonoConn *conn) {
        block(NetworkTimeOut,nil,nil);
    }];
}

// Converted
+(void)recordHotknoteHasViewedOnActivites:(NSString*)account_id withKnoteId:(NSString *)knote_id andTopicID:(NSString *)topic_id withCompleteBlock:(MongoCompletion)block
{
#if 0
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        MongoConnection * dbconn = conn.conn;
        WM_NetworkStatus ret = NetworkFailure;
        NSError *error = nil;
        if (account_id && knote_id) {
            MongoDBCollection *coll = [dbconn collectionNamed:METEORCOLLECTION_ACTIVITES];
            
            if ( coll != nil) {
                MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
                [pred1 keyPath:@"knote_id" matches:knote_id];
                [pred1 keyPath:@"has_read_ids" arrayDoesNotContainAllObjects:account_id,nil];

                MongoUpdateRequest *req = [MongoUpdateRequest updateRequestWithPredicate:pred1 firstMatchOnly:NO];
//                [req arrayForKeyPath:@"has_read_ids" appendValue:account_id];
                [req setForKeyPath:@"has_read_ids" addValue:account_id];
                if ([DataManager sharedInstance].currentAccount.hashedToken) {
                    [req setForKeyPath:@"session_when_read" addValue:[DataManager sharedInstance].currentAccount.hashedToken];
                }

                [coll updateWithRequest:req error:&error];
                NSLog(@"sendRequestArchivePeople update result[%@]",error);
                if( error == nil) {
                    ret = NetworkSucc;
                }
            }
        }
        
        if (!conn.isFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(ret, nil, nil);
            });
            conn.isFinished = YES;
        }
        
    } withTimeOut:^(MonoConn *conn) {
        block(NetworkTimeOut,nil,nil);
    }];
#else
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        MongoConnection * dbconn = conn.conn;
        WM_NetworkStatus ret = NetworkFailure;
        NSError *error = nil;
        if (account_id && knote_id) {
            MongoDBCollection *coll = [dbconn collectionNamed:METEORCOLLECTION_ACTIVITES];
            
            if ( coll != nil) {
                MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
                [pred1 keyPath:@"topic_id" matches:topic_id];
                [pred1 keyPath:@"has_read_ids" arrayDoesNotContainAllObjects:account_id,nil];
                [pred1 keyPath:@"notify_ids" arrayContainsAllObjects:account_id,nil];
                
                MongoUpdateRequest *req = [MongoUpdateRequest updateRequestWithPredicate:pred1 firstMatchOnly:NO];
                
                [req setForKeyPath:@"has_read_ids" addValue:account_id];
                
                if ([DataManager sharedInstance].currentAccount.hashedToken)
                {
                    [req setForKeyPath:@"session_when_read" addValue:[DataManager sharedInstance].currentAccount.hashedToken];
                }
                
                [coll updateWithRequest:req error:&error];
                NSLog(@"sendRequestArchivePeople update result[%@]",error);
                if( error == nil) {
                    ret = NetworkSucc;
                }
            }
        }
        
        if (!conn.isFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(ret, nil, nil);
            });
            conn.isFinished = YES;
        }
        
    } withTimeOut:^(MonoConn *conn) {
        block(NetworkTimeOut,nil,nil);
    }];
#endif
}

// Working
+(void)checkHotknoteHasViewedOnActivites:(NSString*)account_id withKnoteId:(NSString *)knote_id withCompleteBlock:(MongoCompletion)block
{
    [[MultiConnGenerator sharedInstance] requestFreeMonoConn:^(MonoConn *conn) {
        MongoConnection * dbconn = conn.conn;
        WM_NetworkStatus ret = NetworkFailure;
        NSError *error = nil;
        NSArray *resultDocArray = nil;
        NSNumber *status = @(kViewedYES);

        if (account_id && knote_id) {
            MongoDBCollection *coll = [dbconn collectionNamed:METEORCOLLECTION_ACTIVITES];
            if ( coll != nil) {
                
                MongoKeyedPredicate *pred1 = [MongoKeyedPredicate predicate];
                [pred1 keyPath:@"knote_id" matches:knote_id];
                [pred1 keyPath:@"has_read_ids" arrayDoesNotContainAllObjects:account_id,nil];
                [pred1 keyPath:@"notify_ids" arrayContainsAllObjects:account_id,nil];

                MongoFindRequest *req1 = [MongoFindRequest findRequestWithPredicate:pred1];
                [req1 includeKey:@"has_read_ids"];
                
                resultDocArray = [coll findWithRequest:req1 error:&error];
                if ([resultDocArray count]>0) {
                    status = @(kViewedNO);
                    //NSLog(@"################uuuuuuuuuuu%@,%@",knote_id,resultDocArray);
                }

                if(!error) {
                    ret = NetworkSucc;
                } else {
                    DLog(@"####Error: %@", error);
                    ret = NetworkFailure;
                }
            }
        }
        
        if (!conn.isFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(ret, nil, status);
            });
            conn.isFinished = YES;
        }
        
    } withTimeOut:^(MonoConn *conn) {
        block(NetworkTimeOut,nil,nil);
    }];
}


-(void)Template:(WM_NetworkStatus)success
{
    switch (success) {
        case NetworkSucc:
        {
        }
            break;
        case NetworkErr:
        {
        }
            break;
        case NetworkTimeOut:
        {
        }
            break;
        case NetworkFailure:
        {
        }
            break;
        default:
            break;
    }
}

@end
