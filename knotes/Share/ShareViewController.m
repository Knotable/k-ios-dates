//
//  ShareViewController.m
//  Share
//
//  Created by Nicolas  on 13/5/15.
//
//

#import "ShareViewController.h"
#import "ServerConfig.h"
#import "NSString+Knotes.h"
#import "DataManager.h"
#import "AccountEntity.h"
#import "ContactsEntity.h"
#import "MessageEntity.h"
#import <MagicalRecord/MagicalRecord.h>
#import "AppDelegate.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "FileInfo.h"
#import "Functionalities.h"
#import "NSString+HTML.h"

#import "MCAWSS3Client.h"
#import "ASIS3ObjectRequest.h"
#import "ASIS3BucketRequest.h"

#define kKnoteIdPrefix @"tempId."

@interface ShareViewController ()

@property (nonatomic, strong) NSMutableArray *knotes;
@property (nonatomic, strong) NSString *topic_id;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSMutableDictionary *userInfo;
@property (nonatomic, strong) NSString *sessionToken;
@property (nonatomic, strong) NSURL *dataUrl;
@property (nonatomic, strong) NSString *dataString;
@property (nonatomic, strong) UIImage *dataImage;
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *imageId;
@property (nonatomic, assign) BOOL isPNG;
@property (nonatomic, assign) UIImageOrientation orientation;
@property (nonatomic, strong) NSString *type;

@end

@implementation ShareViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView.layer setZPosition:0];
    self.sharedView.layer.cornerRadius = 10;
    self.sharedView.layer.masksToBounds = YES;
    [self.sharedView.layer setZPosition:1];
    self.notiView.layer.cornerRadius = 10;
    self.notiView.layer.masksToBounds = YES;
    [self.notiView.layer setZPosition:1];
    self.dataString = @"";
    
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^( NSURL  *image, NSError *error) {
                    if(image) {
                        self.type = @"image";
                       
                        NSArray *comps = [[image path] componentsSeparatedByString:@"/"];
                        NSString *fileName = [[comps lastObject] stringByDeletingPathExtension];
                        self.dataImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:image]];
                        self.imageName = fileName;
                        self.isPNG = [[[image pathExtension] lowercaseString] isEqualToString:@"png"];
                        //self.imageName = [[representation filename] lowercaseString];
                        //self.isPNG = [[[self.imageName pathExtension] lowercaseString] isEqualToString:@"png"];
                        
                        
                        /*[library assetForURL: resultBlock:^(ALAsset *asset) {
                            //code success
                            ALAssetRepresentation *representation = [asset defaultRepresentation];
                            self.dataImage = [UIImage imageWithCGImage:[representation fullScreenImage] scale:representation.scale orientation:(UIImageOrientation)0];
                            self.imageName = [[representation filename] lowercaseString];
                            self.isPNG = [[[self.imageName pathExtension] lowercaseString] isEqualToString:@"png"];
                            self.orientation = (UIImageOrientation)representation.orientation;
                        } failureBlock:^(NSError *error) {
                            //code error
                            NSLog(@"error");
                        }];
                        */
        
                    
                        /*[library writeImageToSavedPhotosAlbum:image.CGImage orientation:image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
                            
                            [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                                //code
                                if (asset) {
                                    // Type your code here for successful
                                    ALAssetRepresentation *representation = [asset defaultRepresentation];
                                    self.dataImage = [UIImage imageWithCGImage:[representation fullScreenImage] scale:representation.scale orientation:(UIImageOrientation)0];
                                    self.imageName = [[representation filename] lowercaseString];
                                    self.isPNG = [[[self.imageName pathExtension] lowercaseString] isEqualToString:@"png"];
                                    self.orientation = (UIImageOrientation)representation.orientation;
                                
                                } else {
                                    // Type your code here for not existing asset
                                }

                            } failureBlock:^(NSError *error) {
                                //code
                            }];
                        }];*/
                        
                        /*
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //self.dataImage = image;
                            self.type = @"image";
                           // FileInfo *finfo = [FileInfo fileInfoForAsset:image];
                          //  [FileManager beginUploadingFile:finfo];
                        });*/
                    }
                }];
            }else if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeURL]){
                
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeURL options:nil completionHandler:^(NSURL *url, NSError *error) {
                    //code
                    self.dataUrl = url;
                    self.dataString = [url absoluteString];
                    self.type = @"url";
                }];
            }else if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeText]){
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeText options:nil completionHandler:^(NSString *text, NSError *error) {
                    //code
                    self.dataString = [text kv_decodeHTMLCharacterEntities];
                    self.type = @"text";
                }];
            }else if ([itemProvider hasItemConformingToTypeIdentifier:@"com.apple.property-list"]){
                [itemProvider loadItemForTypeIdentifier:@"com.apple.property-list" options:nil completionHandler:^( NSDictionary *item, NSError *error) {
                    
                    NSDictionary *nsext = [item objectForKey:@"NSExtensionJavaScriptPreprocessingResultsKey"];
                    
                    if (nsext) {
                        self.dataString = [nsext  objectForKey:@"currentUrl"];
                        self.type = @"url";
                        self.dataUrl = [NSURL URLWithString:self.dataString];
                    }
                }];
            }
        }
    }

    
    
    
    
    [self loadServerConfig];
    
    [self connectServer: [self.server meteorWebsocketURL]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.knotable.knotedev.share"];
    
    self.knotes = [[userDefaults objectForKey:@"Knotes"] mutableCopy] ?: [NSMutableArray arrayWithCapacity:10];
    self.userInfo = [[userDefaults objectForKey:@"userInfo"] mutableCopy];
    
    self.sessionToken = [self.userInfo objectForKey:@"sessionToken"];
    
   // self. knotes = [[NSMutableArray alloc] initWithArray:@[@"Create Login",@"Add new member", @"Manage Push notifications"]];
    
    self.view.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height);
    [UIView animateWithDuration:0.25 animations:^{
        self.view.transform = CGAffineTransformIdentity;
    }];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear: animated];
    if (self.sessionToken == nil) {
        //        [self.extensionContext openURL:[NSURL URLWithString:@"knotable://"] completionHandler:nil];
        [self.notiView setHidden:NO];
    }
}

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    //NSLog(self.textView.text);
    
    
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
    
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

- (IBAction)createNewPad:(id)sender {
    //create new pad code
    [self createTopic];
    
    
}

- (IBAction)cancelAction:(id)sender {
    
    //[self loginMeteor:@"nicolas" password:@"knotable"];
    [UIView animateWithDuration:0.20 animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        [self.extensionContext completeRequestReturningItems:nil completionHandler:nil];
    }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.knotes.count;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *simpleTableIdentifier = @"basicID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    [cell.textLabel setText:[[self.knotes objectAtIndex:indexPath.row] objectForKey:@"topic_name"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //add note to existing pad code

    NSString *knote_id = [[self.knotes objectAtIndex:indexPath.row] objectForKey:@"topic_id"];
    self.topic_id = knote_id;
    
   // [self createKnote];
    if ([self.type isEqualToString:@"image"]) {
        NSData *dataImage = UIImageJPEGRepresentation(self.dataImage, 0.5);
        [self uploadImage:dataImage isPNG:self.isPNG];
    }else{
        [self createKnote];
    }
    
    //[self.extensionContext completeRequestReturningItems:nil completionHandler:nil];
}

-(void)connectServer:(NSString *)server{
    if (!self.meteor) {
        self.meteor = [[MeteorClient alloc] initWithDDPVersion:@"pre2"];
        ObjectiveDDP *ddp = [[ObjectiveDDP alloc] initWithURLString:server delegate:self.meteor];
        self.meteor.ddp = ddp;
        [self.meteor.ddp connectWebSocket];
        [self.meteor addObserver:self
                      forKeyPath:@"connected" //websocketReady
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    } else if (![self.meteor.ddp.urlString isEqualToString:server]) {
        [self closePreMeteor];
        self.meteor = [[MeteorClient alloc] initWithDDPVersion:@"pre2"];
        ObjectiveDDP *ddp = [[ObjectiveDDP alloc] initWithURLString:server delegate:self.meteor];
        self.meteor.ddp = ddp;
        [self.meteor.ddp connectWebSocket];
        [self.meteor addObserver:self
                      forKeyPath:@"connected"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    } else if (!self.meteor.connected) {
        [self.meteor reconnect];
    }
    
   // [self loginWhenMeteorConect];
}

-(void)closePreMeteor{
    // App would crash due to pending responses if meteor reference is not kept around. Any other way to prevent this?
    self.meteorOld = self.meteor;
    [self.meteor removeObserver:self forKeyPath:@"connected"];
    //self.meteor.ddp.delegate = nil;
    //self.meteor.ddp.webSocket.delegate = nil;
    //self.meteor.ddp = nil;
    [self.meteor disconnect];
    self.meteor = nil;
}

- (void)loginMeteor:(NSString *)username password:(NSString *)password{
    
    [self.meteor logonWithUsernameOrEmail:username
                                 password:password
                         responseCallback:^(NSDictionary *response, NSError *error)
     {
         
         NSLog(@"login error: %@ response: %@", error, response);
         
         if (error)
         {
             NSString *reason = nil;
             
             NSDictionary *dic = error.userInfo[NSLocalizedDescriptionKey];
             
             if ([dic isKindOfClass:[NSDictionary class]])
             {
                 reason = dic[@"reason"];
             }
             else if ([dic isKindOfClass:[NSString class ]])
             {
                 reason = (NSString *)dic;
             }
             
             NSLog(@"error reason: %@", reason);
             
         }
         else
         {
             NSLog(@"Login with success!!");
             //self.meteor.sessionToken = [[response objectForKey:@"result"] objectForKey:@"token"];
             self.userId = [[response objectForKey:@"result"] objectForKey:@"id"];
         }
     }];

}

- (void)meteorLoginWithSessionToken:(NSString *)token{
    [self.meteor logonWithSessionToken:token responseCallback:^(NSDictionary *response, NSError *error) {
        
        
        //DLog(@"login took: %f login error: %@ response: %@", timeTook,error, response);
        if (error)
        {
            NSString *reason = nil;
            
            NSDictionary *dic = error.userInfo[NSLocalizedDescriptionKey];
            
            if ([dic isKindOfClass:[NSDictionary class]])
            {
                reason = dic[@"reason"];
            }
            else if ([dic isKindOfClass:[NSString class ]])
            {
                reason = (NSString *)dic;
            }
            NSLog(@"Login error!");
        }
        else
        {
            NSDictionary *result = response[@"result"];
            NSString *user_id = result[@"id"];
            NSString *token = result[@"token"];
            self.userId = user_id;
            self.sessionToken = token;
            NSLog(@"Login Success!");
        }
    }];
}

#pragma mark <NSKeyValueObserving>

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"websocketReady"] && self.meteor.websocketReady)
    {
        NSLog(@"Can send message to Meteor");
        // [self loginMeteor:@"nicolas" password:@"knotable"];
      //  [self loginWhenMeteorConect];
    }else if ([keyPath isEqualToString:@"connected"] && self.meteor.connected && self.sessionToken != nil)
    {
        [self meteorLoginWithSessionToken:self.sessionToken];
    }
    else
    {
        NSLog(@"Info : %@", keyPath);
    }
}

#pragma mark server methods

- (void)loadServerConfig{
    
    //try to load downloaded configuration first, if that fails load packaged config
    NSArray *serverDicts = nil;
    
    NSString *downloadedPath = [self serverConfigPlistPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadedPath])
    {
        serverDicts = [NSArray arrayWithContentsOfFile:downloadedPath];
        
       // DLog(@"loaded server configs from downloaded file");
    }
    
    if (!serverDicts)
    {
#if K_SERVER_DEV
        NSString *bundledConfigPath = [[NSBundle mainBundle] pathForResource:@"servers_dev" ofType:@"plist"];
#elif K_SERVER_BETA
        NSString *bundledConfigPath = [[NSBundle mainBundle] pathForResource:@"servers_beta" ofType:@"plist"];
#elif K_SERVER_STAGING
        NSString *bundledConfigPath = [[NSBundle mainBundle] pathForResource:@"servers_staging" ofType:@"plist"];
#endif
        
        serverDicts = [NSArray arrayWithContentsOfFile:bundledConfigPath];
        
        //DLog(@"loaded server configs from packaged file");
    }
    [self setServerByDic:serverDicts];
    
}

-(void)setServerByDic:(NSArray *)serverDicts{
    NSMutableArray *servers = [[NSMutableArray alloc] initWithCapacity:serverDicts.count];
    
    for (NSDictionary *d in serverDicts)
    {
        [servers addObject:[[ServerConfig alloc] initWithDictionary:d]];
    }
    
    NSString *current_server_id = [self currentSavedServerID];
    
    ServerConfig *current_server_data = nil;
    
    if (current_server_id)
    {
        for (ServerConfig *s in servers)
        {
            NSString *server_id = s.server_id;
            
            if (server_id && [server_id isEqualToString:current_server_id])
            {
                current_server_data = s;
                
                break;
            }
        }
    }
    
    if (!current_server_data)
    {
        current_server_data = [servers firstObject];
    }
    
    NSAssert(current_server_data != nil, @"NO SERVER CONFIG FOUND!!");
    
    _allServerConfigs = [servers copy];
    
    [self setServer:current_server_data];
}

- (NSString *)currentSavedServerID{
    //Locking it on Alpha
    //return @"alpha";
    
#if K_SERVER_DEV
    
    return @"Dev";
    
#elif K_SERVER_BETA
    
    return @"beta";
    
#elif K_SERVER_STAGING
    
    return @"staging";
    
#endif
    
}

-(void)setServer:(ServerConfig *)server{
    BOOL first_server = (_server == nil);
    BOOL server_changed = NO;
    if (![server.server_id isEqualToString:_serverID] )
    {
        _server = server;
        _serverID = server.server_id;
        server_changed = YES;
        [self saveCurrentServer];
    }
    
}

-(void)saveCurrentServer{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.serverID, @"id", nil];
    NSString *path = [self currentServerPlistPath];
    BOOL wrote = [dict writeToFile:path atomically:YES];
    if (!wrote) {
       
        //DLog(@"Problem writing current server dict: %@ to path: %@", dict, path);
    }
}

- (NSString *)currentServerPlistPath{
    NSString *current_server_plist_filename = @"current_server.plist";
    
    return [[ShareViewController applicationDocumentsDirectory] stringByAppendingPathComponent:current_server_plist_filename];
}

- (NSString *)serverConfigPlistPath{
#if K_SERVER_DEV
    NSString *server_config_plist_filename = @"servers_dev.plist";
#elif K_SERVER_BETA
    NSString *server_config_plist_filename = @"servers_beta.plist";
#elif K_SERVER_STAGING
    NSString *server_config_plist_filename = @"servers_staging.plist";
#endif
    
    return [[ShareViewController applicationDocumentsDirectory] stringByAppendingPathComponent:server_config_plist_filename];
}

+ (NSString *)applicationDocumentsDirectory{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark Core Data Methods

- (NSManagedObjectContext *) managedObjectContext{
    return [[MagicalRecordStack defaultStack] context];
}

- (NSArray *)createObject{
   
    NSArray *ret = @[];
    

    return ret;
}

- (void)createTopic{
    
    NSString *userId = self.userId; //zoj94shkb6JNYQSmi
    NSString *subject = [self createSubject];
    NSArray *participator_account_ids = @[userId];
    
    NSDictionary *requiredTopicParams = @{
                                          @"userId": userId,
                                          @"participator_account_ids": participator_account_ids,
                                          @"subject":subject,
                                          @"permissions":@[@"read", @"write", @"upload"],
                                          };
    
    NSDictionary *optionalTopicParams = @{/*
                                          @"file_ids":tInfo.filesIds ? tInfo.filesIds : @[],
                                          @"_id":[topic.topic_id noPrefix:kKnoteIdPrefix],
                                          @"order":@{[DataManager sharedInstance].currentAccount.user.user_id : topic.order_to_set != nil? topic.order_to_set : @(999)},
                                          @"to":participator_emails,*/
                                          };
    
    NSDictionary *additionalOptions = @{/*@"topicId":[topic.topic_id noPrefix:kKnoteIdPrefix]*/};
    
    
    NSArray *params = @[requiredTopicParams, optionalTopicParams, additionalOptions];
    
    if (self.meteor && self.meteor.connected) {
        
        NSLog(@"calling create_topic on meteor params: %@", params);
        
        [self.meteor callMethodName:@"create_topic"
                    parameters:params
              responseCallback:^(NSDictionary *response, NSError *error)
         {
             //                tInfo.entity.isSending = @(NO);
             
             if (error)
             {
                 NSLog(@"error calling create_topic on meteor: %@", error);
                 
             }
             else
             {
                 NSString *topic_id = response[@"result"];
                 NSLog(@"success calling create_topic on meteor topic_id: %@", topic_id);
                 self.topic_id = topic_id;
                 
                 if ([self.type isEqualToString:@"image"]) {
                     NSData *dataImage = UIImageJPEGRepresentation(self.dataImage, 0.5);
                     [self uploadImage:dataImage isPNG:self.isPNG];
                 }else{
                     [self createKnote];
                 }

             }
         }];
    }
    else
    {
        NSLog(@"cant call create_topic, meteor not connected");
    }

}

- (void)createKnote{
    
    NSString *body = @"";
    
    if ([self.type isEqualToString:@"image"]) {
        
        body = [NSString stringWithFormat:@"<p> <div class=\"thumbnail-wrapper thumbnail3 uploading-thumb\" id=\"thumb-box-44\"> <p id=\"thumb-box-status-44\"></p> <div class=\"thumb\"> <span class=\"img-wrapper\" contenteditable=\"false\"> <span class=\"btn-close\" contenteditable=\"false\"></span> <img src=\"/images/_close.png\" class=\"delete_file_ico\" style=\"max-width: 400px;\"> </span> <img class=\"thumb\" src=\"https://s3.amazonaws.com/knotable-assets-dev/uploads/%@_%@\" style=\"max-width: 400px;\"> </div></div></p>", self.imageId, self.imageName];
    }else if ([self.type isEqualToString:@"url"]){
        body = [NSString stringWithFormat:@"<p><a href=\"%@\"></a></p>",self.dataString];
    }
    
     [self createObject];
     
    NSString *subject = [self createSubject];
    // NSString *topic_id = @"LS5kmnhwpkc";
    NSString *from = [self.userInfo objectForKey:@"email"]; //@"nicolasbermudez@wecodegreen.com";
    NSString *userId = self.userId; //zoj94shkb6JNYQSmi
    NSString *name = [self.userInfo objectForKey:@"name"]; //@"nicolas";
     
     //NSString *messageId = @"lkhngpkwqirbncs";
    NSDate * date = [NSDate date];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:kDateFormat1];
     NSString *dateString = [format stringFromDate:date];
    
    // NSString *title = [NSString stringWithFormat:@"%@%@",self.dataString, [self.dataUrl absoluteString]];
     NSString *order = @"1";
     
     
     NSDictionary *requiredParams = @{
     @"subject":subject,
     @"body": body,
     @"topic_id": self.topic_id, //[topic_id noPrefix:kKnoteIdPrefix],
     @"userId":userId,
     @"name":name,
     @"from":from,
     @"isMailgun":@NO
     };
     
    NSDictionary *optionalParams = @{};
    
    if ([self.type isEqualToString:@"image"]) {
        optionalParams = @{
                           //@"_id":messageId,
                           @"date":dateString,
                           @"file_ids" : @[self.imageId],
                           @"title": self.dataString,
                           @"order":order
                           };
    }else if ([self.type isEqualToString:@"url"]){
        optionalParams = @{
                           //@"_id":messageId,
                           @"date":dateString,
                           @"title": @"",
                           @"order":order
                           };
    }else{
        optionalParams = @{
                           //@"_id":messageId,
                           @"date":dateString,
                           @"title": self.dataString,
                           @"order":order
                           };
    }
     NSArray *params = @[requiredParams, optionalParams];
     
     [self.meteor callMethodName:@"add_knote"
     parameters:params
     responseCallback:^(NSDictionary *response, NSError *error) {
     
     if (error) {
         NSLog(@"add_knote error: %@", error);
         
     
     } else {
         NSLog(@"add_knote response type: %@ : %@", [response class], response);
         [self.sharedView setHidden:NO];
     }
         [self closePreMeteor];
         [self performSelector:@selector(closeExtension) withObject:nil afterDelay:1.0];
     }];
    
    
   // [self closeExtension];
}

- (void)closeExtension{
    
    NSExtensionItem *extensionItem = [[NSExtensionItem alloc] init];
    
    NSDictionary *item = @{@"NSExtensionJavaScriptFinalizeArgumentKey": @{@"statusMessage":@"Shared!!!"}};
    
    NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithItem: item typeIdentifier: (NSString *) kUTTypePropertyList];
    extensionItem.attachments = @[itemProvider];
    
    [self.extensionContext completeRequestReturningItems: @[extensionItem] completionHandler: nil];
}

- (NSString *)createSubject{
    NSDate * date = [NSDate date];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date];
    NSDateComponents *componentsDate = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    
    NSString * minuteS = [NSString stringWithFormat:@"%ld", (long)[components minute]];
    if(minuteS.length <= 1){
        minuteS = [@"0" stringByAppendingString:minuteS];
    }
    
    NSString * amORpm = @"am";
    NSInteger hour = [components hour];
    if([components hour] >= 13){
        amORpm = @"pm";
        if(hour > 12){
            hour -= 12;
        }
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM"];
    NSString *monthStringFromDate = [formatter stringFromDate:date];
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE"];
    //NSString *dayStringFromDate = [formatter stringFromDate:date];
    
    NSInteger dayNumber = [componentsDate day];
    NSString *dayNumberString = [NSString stringWithFormat:@"%ld", (long)dayNumber];
    
    return [NSString stringWithFormat:@"%@ %@, %@ %@", monthStringFromDate, dayNumberString, [NSString stringWithFormat:@"%ld:%@",(long)hour,minuteS], amORpm];
}

- (void)uploadImage:(NSData *)data isPNG:(BOOL)isPNG{
    MCAWSS3Client* client = [[MCAWSS3Client alloc] init];
    client.accessKey = self.server.s3_access_key;
    client.secretKey = self.server.s3_secret_key;
    client.bucket = self.server.s3_bucket;
    
    NSString *mime = isPNG ? @"image/png" : @"image/jpg";
    
    self.imageId = [Functionalities mongo_id_generator];
    
    NSString *awsFilename = [NSString stringWithFormat:S3_FILENAME_FORMAT, [NSString stringWithFormat:@"%@_%@", self.imageId ,self.imageName]]; //@"info.imageId",@"info.imageName"
    
    //NSData *imageData = [info getFullResolutionData];
    
        [client putObjectWithData:data
                              key:awsFilename
                         mimeType:mime
                       permission:MCAWSS3ObjectPermissionPublicRead
         //match with embedly.m
#if !AFNetworking_2_And_Above_Installed
                         progress:^ (NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite){
#else
                         progress:^(NSUInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {
#endif
                             
                             float progress = ((float)totalBytesWritten)/((float)totalBytesExpectedToWrite);
                             //                             progress = 0.2 + progress*0.7;
                             
                             NSLog(@"Progress: %f%%",progress);
                            
                         } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                             NSLog(@"Upload with Success!!!");
                             [self createKnote];
                         }
                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                             NSLog(@"Upload Failed!!!");
                         }];
}
         
@end
