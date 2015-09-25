//
//  ContactsEntity.m
//  RevealControllerProject
//
//  Created by backup on 13-11-15.
//
//

#import "ContactsEntity.h"

#import "CUtil.h"
#import "SDWebImageManager.h"

@implementation ContactsEntity

@dynamic name;
@dynamic email;
@dynamic contact_id;
@dynamic me_id;
@dynamic bgcolor;
@dynamic cid;
@dynamic order;
@dynamic gravatar_exist;
@dynamic avatar;
@dynamic user;
@dynamic phone;
@dynamic website;
@dynamic twitter_link;
@dynamic facebook_link;
@dynamic account_id;
@dynamic archived;
@dynamic username;
@dynamic total_topics;
@dynamic position;
@dynamic messages;
@dynamic topics;
@dynamic mainEmail;
@dynamic isMe;

@dynamic fullURL;
@dynamic miniURL;

+ (ContactsEntity *)contactWithDict:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context
{
    ContactsEntity *contact = nil;
    
    NSString *contact_id = dict[@"_id"];
    
    if (contact_id && contact_id.length > 0)
    {
        contact = [ContactsEntity MR_findFirstByAttribute:@"contact_id" withValue:contact_id inContext:context];
    }
    
    if (!contact)
    {
        contact = [ContactsEntity MR_createEntityInContext:context];
    }
    
    [contact setValuesForKeysWithDictionary:dict];
    return contact;
}

+ (ContactsEntity *)contactWithDict:(NSDictionary *)dict
{
    ContactsEntity *contact = nil;
    
    NSManagedObjectContext *backgroundMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
    [backgroundMOC setPersistentStoreCoordinator:[glbAppdel.managedObjectContext persistentStoreCoordinator]];
    
    NSString *contact_id = dict[@"_id"];
    
    if (contact_id && contact_id.length > 0)
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ContactsEntity"];
        
        [request setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", @"contact_id", contact_id]];
        
        [request setFetchLimit:1];
        
        NSUInteger count = [backgroundMOC countForFetchRequest:request error:nil];
        
        if (count>0)
        {
            contact = [[backgroundMOC executeFetchRequest:request error:nil] firstObject];
            
            contact = (ContactsEntity *)[glbAppdel.managedObjectContext existingObjectWithID:[contact objectID] error:nil];
        }
    }
    
    if (!contact)
    {
        contact = [ContactsEntity MR_createEntityInContext:glbAppdel.managedObjectContext];
    }
    
    [contact setValuesForKeysWithDictionary:dict];
    
    return contact;
}

- (NSString *)getFirstEmail
{
    if (!self.email || self.email.length == 0)
    {
        return @"";
    }
    
    return [[self.email componentsSeparatedByString:@","] firstObject];
}

-(void)addNewMail:(NSString *)mail
{
    NSMutableArray * auxArray = [[self.email componentsSeparatedByString:@","] mutableCopy];
    
    [auxArray addObject:mail];
    
    self.email = [auxArray componentsJoinedByString:@","];
}

- (void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues
{
    if ([self isFault])
    {
        return;
    }
    
    NSArray *emails = keyedValues[@"emails"];
    
    if (emails
        && [emails isKindOfClass:[NSArray class]]
        && emails.count > 0)
    {
        self.email = [emails componentsJoinedByString:@","];
        
        id mainEmailObj = emails.firstObject;
        
        NSString *mainEmail = nil;
        
        if([mainEmailObj isKindOfClass:[NSString class]])
        {
            mainEmail = mainEmailObj;
        }
        else if([mainEmailObj isKindOfClass:[NSArray class]])
        {
            NSArray *mainEmailArray = mainEmailObj;
            
            if(mainEmailArray.count > 0)
            {
                mainEmail = mainEmailArray.firstObject;
            }
        }
        
        self.mainEmail = mainEmail;
    }
    
    NSString *contact_id = keyedValues[@"_id"];
    
    if (contact_id)
    {
        self.contact_id = contact_id;
    }
    
    NSString *name = @"";
    
    NSString *nickname = keyedValues[@"nickname"];
    
    if (nickname !=NULL)
    {
        name = nickname;
    }
    else
    {
        name = keyedValues[@"fullname"];
    }
    
    if (name && [name isKindOfClass:[NSString class]] && name != (id)[NSNull null])
    {
        name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        name = [name stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        self.name = name;
    }

    NSString *bgcolor = keyedValues[@"bgcolor"];
    
    if (bgcolor)
    {
        self.bgcolor = bgcolor;
    }

    NSNumber *gravatar_exists = keyedValues[@"gravatar_exist"];
    
    if (gravatar_exists != nil)
    {
        self.gravatar_exist = [gravatar_exists integerValue];
    }

    NSString *phone = keyedValues[@"phone"];
    
    if (phone)
    {
        self.phone = phone;
    }

    NSString *website = keyedValues[@"website"];
    
    if (phone)
    {
        self.website = website;
    }

    NSString *twitter_link = keyedValues[@"twitter_link"];
    
    if (twitter_link)
    {
        self.twitter_link = twitter_link;
    }

    NSString *facebook_link = keyedValues[@"facebook_link"];
    
    if (facebook_link)
    {
        self.facebook_link = facebook_link;
    }

    NSString *username = keyedValues[@"username"];
    
    if (username
        && [username isKindOfClass:[NSString class]]
        && username != (id)[NSNull null])
    {
        self.username = username;
    }

    NSNumber *archived = keyedValues[@"archived"];
    
    if (archived)
    {
        self.archived = archived;
    }
    else
    {
        self.archived = @(NO);
    }
    
    NSString *deleted = keyedValues[@"deleted"];
    
    if (deleted
        && [deleted isKindOfClass:[NSString class]]
        && [deleted isEqualToString:@"deleted"])
    {
        self.archived = @(YES);
    }
    else
    {
        self.archived = @(NO);
    }
    
    NSNumber *position = keyedValues[@"position"];
    
    if (position)
    {
        self.position = position;
    }
    
    NSNumber *total_topics = keyedValues[@"total_topics"];
    
    if (total_topics)
    {
        self.total_topics = total_topics;
    }

    NSString *type = keyedValues[@"type"];
    
    BOOL isMe = type && [type isKindOfClass:[NSString class]] && [[type lowercaseString] isEqualToString:@"me"];
    
    self.isMe = @(isMe);

    NSString *account_id = keyedValues[@"account_id"];
    
    if (isMe && account_id)
    {
        self.account_id = account_id;
    }
    
    NSString *belongs = keyedValues[@"belongs_to_account_id"];
    
    if (belongs && belongs != (id)[NSNull null])
    {
        self.account_id = belongs;
    }
    
    if(keyedValues && [keyedValues objectForKey:@"avatar"])
    {
        NSString *mini;
        
        if ([[keyedValues objectForKey:@"avatar"] isKindOfClass:[NSDictionary class]])
        {
            if ([[[keyedValues objectForKey:@"avatar"] objectForKey:@"path"] isKindOfClass:[NSString class]])
            {
                mini =[[keyedValues objectForKey:@"avatar"] objectForKey:@"mini"];
                
                self.fullURL=[[keyedValues objectForKey:@"avatar"] objectForKey:@"path"];
                self.miniURL=[[keyedValues objectForKey:@"avatar"] objectForKey:@"mini"];
            }
        }
        else
        {
            mini =[keyedValues objectForKey:@"avatar"] ;
        }
        
        if ( mini
            && [mini isKindOfClass:[NSString class]]
            && self.account_id && self.account_id.length > 0)
        {
            
            DLog(@"GET_CACHE_KEY_FOR_MINIURL %@",GET_CACHE_KEY_FOR_MINIURL(self.account_id));
            
            UIImage* profileImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:GET_CACHE_KEY_FOR_MINIURL(self.account_id)];
            
            if ( profileImage == Nil
                && [self isValidURL:mini] )
            {
                NSURL *url =[NSURL URLWithString:mini];
                
                NSLog(@"Downloading Profile Image : %@", url);
                
                NSArray *array = [mini componentsSeparatedByString:@"?"];
                
                if (array.count>2)
                {
                    NSString *replaceStr = array.lastObject;
                    
                    if (replaceStr && replaceStr.length>1)
                    {
                        array = [replaceStr componentsSeparatedByString:@"="];
                        
                        if (array.count>=1)
                        {
                            NSString *sizeStr1 = [array lastObject];
                            
                            if (sizeStr1 && sizeStr1.integerValue<120)
                            {
                                sizeStr1 = [mini stringByReplacingOccurrencesOfString:replaceStr withString:@"s=120"];
                                
                                if (sizeStr1)
                                {
                                    url = [NSURL URLWithString:sizeStr1];
                                }
                            }
                        }
                        
                    }
                }
                
                if(url){
                    [[SDWebImageManager sharedManager] downloadImageWithURL:url
                                                                    options:SDWebImageRefreshCached
                                                                   progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                                       
                                                                   } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                                       
                                                                       if (finished)
                                                                       {
                                                                           if (image)
                                                                           {
                                                                               [[SDImageCache sharedImageCache] storeImage:image
                                                                                                                    forKey:GET_CACHE_KEY_FOR_MINIURL(self.account_id)
                                                                                                                    toDisk:YES];
                                                                           }
                                                                       }
                                                                   }];                    
                }
                
                
            }
        }
    }
}

- (NSString *)userImageName
{
    if (self.gravatar_exist)
    {
        NSString *path  = [kImageCachePath stringByAppendingPathComponent:[CUtil md5:self.email]];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            return [CUtil md5:self.email];
        }
        else
        {
            path  = [kImageCachePath stringByAppendingPathComponent:[CUtil md5:self.mainEmail]];
            
            if([[NSFileManager defaultManager] fileExistsAtPath:path])
            {
                return [CUtil md5:self.mainEmail];
            }
        }
    }
    
    return self.bgcolor;
}

- (UIImage *)getImageByUserName
{
    UIImage *img = nil;
    
    NSString *str = @"bgcolor0";
    
    NSString *name = @"X";
    
    if (self.bgcolor && [self.bgcolor length]>0)
    {
        str = self.bgcolor;
    }
    
    if (self.name && [self.name length]>0)
    {
        name = self.name;
    }
    else if (self.username && [self.username length]>0)
    {
        name = self.username;
    }
    else if (self.mainEmail && [self.mainEmail length]>0)
    {
        name = self.mainEmail;
    }
    else if (self.email && [self.email length]>0)
    {
        name = self.email;
    }
    
    img = [CUtil imageText:[[name substringWithRange:NSMakeRange(0,1)] uppercaseString]
            withBackground:str
                      size:CGSizeMake(kDefalutTitleIconH, kDefalutTitleIconH)
                      rate:0.6];
    return img;
}

// Lin - Added to
/*
 
 
 */

- (void)oldAsyncImageWithBlock:(AsyncGetImage)block
{
    UIImage *img = nil;
    
    NSString* profileImageUrl = Nil;
    
    if (self.fullURL)
    {
        profileImageUrl = self.fullURL;
    }
    
    if (profileImageUrl)
    {
        
        DLog(@"GET_CACHE_KEY_FOR_FULLURL %@",GET_CACHE_KEY_FOR_FULLURL(self.account_id));
        
        img = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:GET_CACHE_KEY_FOR_FULLURL(self.account_id)];
        
        if (img)
        {
            block(img, YES);
        }
        else
        {
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:profileImageUrl]
                                                            options:SDWebImageRefreshCached
                                                           progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                               
                                                           } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                               
                                                               if (finished)
                                                               {
                                                                   if (image)
                                                                   {
                                                                       [[SDImageCache sharedImageCache] storeImage:image forKey:GET_CACHE_KEY_FOR_FULLURL(self.account_id) toDisk:YES];
                                                                   }
                                                                   else
                                                                   {
                                                                       image = [self getImageByUserName];
                                                                   }
                                                                   
                                                                   block(image,finished);
                                                               }
                                                           }];
        }
    }
    else
    {
        if (self.gravatar_exist)
        {
            NSString *contactEmail = self.mainEmail;
            NSString *path  = @"";
            
            if (contactEmail && [contactEmail length]>0)
            {
                path = [CUtil pathForCachedImage:contactEmail];
            }
            else
            {
                if (self.email && [self.email length]>0)
                {
                    contactEmail = [[self.email componentsSeparatedByString:@","] firstObject];
                    
                    if ([contactEmail length]>0)
                    {
                        path = [CUtil pathForCachedImage:contactEmail];
                    }
                }
            }
            
            if ([path length]>0 && [[NSFileManager defaultManager] fileExistsAtPath:path])
            {
                img = [UIImage imageWithData:[NSData dataWithContentsOfFile:path]];
            }
            else
            {
                if ( ![CUtil imageInfileCache:contactEmail])
                {
                    img = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.account_id];
                    
                    if (img == Nil)
                    {
                        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?s=160",kAvatorBaseUrl,[CUtil hashForEmail:contactEmail]]]
                                                                        options:SDWebImageRefreshCached
                                                                       progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                                           
                                                                       } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                                           
                                                                           if (finished)
                                                                           {
                                                                               [[SDImageCache sharedImageCache] storeImage:image forKey:self.account_id toDisk:YES];
                                                                               
                                                                               block(image,finished);
                                                                           }
                                                                       }];
                    }
                    
                }
                else
                {
                    path = [CUtil pathForCachedImage:contactEmail];
                    
                    img = [UIImage imageWithContentsOfFile:path];
                }
            }
        }
        else
        {
            img = [self getImageByUserName];
        }
    }
    
    block (img, YES);
}

- (void)newAsyncFullImageWithBlock:(AsyncGetImage)block
{
    __block UIImage*    profileImage = Nil;
    __block NSString*   profileImageURL =Nil;
    
    // This is the full url for profile image
    if (self.fullURL)
    {
        profileImageURL = self.fullURL;
        
        DLog(@"GET_CACHE_KEY_FOR_MINIURL %@",GET_CACHE_KEY_FOR_FULLURL(self.account_id));
        
        profileImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:GET_CACHE_KEY_FOR_FULLURL(self.account_id)];
        
        if (profileImage == Nil)
        {
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:profileImageURL]
                                                            options:SDWebImageRefreshCached
                                                           progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                               
                                                           } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                               
                                                               if (finished)
                                                               {
                                                                   if (image)
                                                                   {
                                                                       [[SDImageCache sharedImageCache] storeImage:image forKey:GET_CACHE_KEY_FOR_FULLURL(self.account_id) toDisk:YES];
                                                                       
                                                                       block(image,finished);
                                                                   }
                                                                   else
                                                                   {
                                                                       [self newAsyncMiniImageWithBlock:block];
                                                                   }
                                                               }
                                                           }];
        }
        else
        {
            block (profileImage, YES);
        }
    }
    else if (self.miniURL)
    {
        [self newAsyncMiniImageWithBlock:block];
    }
    else if (self.gravatar_exist)
    {
        [self newAsyncAvatarImageWithBlock:block];
    }
    else
    {
        profileImage = [self getImageByUserName];
        block (profileImage, YES);
    }
    
}

- (void)newAsyncMiniImageWithBlock:(AsyncGetImage)block
{
    __block UIImage*    profileImage = Nil;
    __block NSString*   profileImageURL =Nil;
    
    // This is the full url for profile image
    if (self.miniURL)
    {
        profileImageURL = self.miniURL;
        
        DLog(@"GET_CACHE_KEY_FOR_MINIURL %@",GET_CACHE_KEY_FOR_MINIURL(self.account_id));
        
        profileImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:GET_CACHE_KEY_FOR_MINIURL(self.account_id)];
        
        if (profileImage == Nil)
        {
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:profileImageURL]
                                                            options:SDWebImageRefreshCached
                                                           progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                               
                                                           } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                               
                                                               if (finished)
                                                               {
                                                                   if (image)
                                                                   {
                                                                       [[SDImageCache sharedImageCache] storeImage:image forKey:GET_CACHE_KEY_FOR_MINIURL(self.account_id) toDisk:YES];
                                                                       
                                                                       block(image,finished);
                                                                   }
                                                                   else
                                                                   {
                                                                       [self newAsyncAvatarImageWithBlock:block];
                                                                   }
                                                               }
                                                           }];
        }
        else
        {
            block (profileImage, YES);
        }
    }
    else if (self.gravatar_exist)
    {
        [self newAsyncAvatarImageWithBlock:block];
    }
    else
    {
        profileImage = [self getImageByUserName];
        block (profileImage, YES);
    }
    
}

- (void)newAsyncAvatarImageWithBlock:(AsyncGetImage)block
{
    __block UIImage*    profileImage = Nil;
    
    if (self.gravatar_exist)
    {
        NSString *contactEmail = self.mainEmail;
        NSString *path  = @"";
        
        if (contactEmail && [contactEmail length]>0)
        {
            path = [CUtil pathForCachedImage:contactEmail];
        }
        else
        {
            if (self.email && [self.email length]>0)
            {
                contactEmail = [[self.email componentsSeparatedByString:@","] firstObject];
                
                if ([contactEmail length]>0)
                {
                    path = [CUtil pathForCachedImage:contactEmail];
                }
            }
        }
        
        if ([path length]>0 && [[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            profileImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:path]];
            block (profileImage, YES);
        }
        else
        {
            if ( ![CUtil imageInfileCache:contactEmail])
            {
                profileImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:self.account_id];
                
                if (profileImage == Nil)
                {
                    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?s=160",kAvatorBaseUrl,[CUtil hashForEmail:contactEmail]]]
                                                                    options:SDWebImageRefreshCached
                                                                   progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                                       
                                                                   } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                                       
                                                                       if (finished)
                                                                       {
                                                                           if (image)
                                                                           {
                                                                               [[SDImageCache sharedImageCache] storeImage:image forKey:self.account_id toDisk:YES];
                                                                               
                                                                               profileImage = image;
                                                                           }
                                                                           else
                                                                           {
                                                                               profileImage = [self getImageByUserName];
                                                                           }
                                                                           
                                                                           block(profileImage,finished);
                                                                       }
                                                                   }];
                }
                else
                {
                    block (profileImage, YES);
                }
            }
            else
            {
                path = [CUtil pathForCachedImage:contactEmail];
                
                profileImage = [UIImage imageWithContentsOfFile:path];
                block (profileImage, YES);
            }
        }
    }
    else
    {
        profileImage = [self getImageByUserName];
        block (profileImage, YES);
    }
    
}

- (void)newAsyncImageWithBlock:(AsyncGetImage)block
{
    [self newAsyncFullImageWithBlock:block];
}

+ (void)oldAsyncImage:(ContactsEntity *)entity WithBlock:(AsyncGetImage)block
{
    UIImage *img = nil;
    
    NSString* profileImageUrl = Nil;
    
    if (entity.fullURL)
    {
        profileImageUrl = entity.fullURL;
    }
    
    if (profileImageUrl)
    {
        DLog(@"GET_CACHE_KEY_FOR_FULLURL %@",GET_CACHE_KEY_FOR_FULLURL(entity.account_id));
        
        img = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:GET_CACHE_KEY_FOR_FULLURL(entity.account_id)];
        
        if (img)
        {
            block(img, YES);
        }
        else
        {
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:profileImageUrl]
                                                            options:SDWebImageRefreshCached
                                                           progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                               
                                                           } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                               
                                                               if (finished)
                                                               {
                                                                   [[SDImageCache sharedImageCache] storeImage:image forKey:GET_CACHE_KEY_FOR_FULLURL(entity.account_id) toDisk:YES];
                                                               }
                                                               
                                                               block(image,finished);
                                                           }];
        }
    }
    else
    {
        if (entity.gravatar_exist)
        {
            NSString *contactEmail = entity.mainEmail;
            NSString *path  = @"";
            
            if (contactEmail && [contactEmail length]>0)
            {
                path = [CUtil pathForCachedImage:contactEmail];
            }
            else
            {
                if (entity.email && [entity.email length]>0)
                {
                    contactEmail = [[entity.email componentsSeparatedByString:@","] firstObject];
                    
                    if ([contactEmail length]>0)
                    {
                        path = [CUtil pathForCachedImage:contactEmail];
                    }
                }
            }
            
            if ([path length]>0 && [[NSFileManager defaultManager] fileExistsAtPath:path])
            {
                img = [UIImage imageWithData:[NSData dataWithContentsOfFile:path]];
            }
            else
            {
                if ( ![CUtil imageInfileCache:contactEmail])
                {
                    img = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:entity.account_id];
                    
                    if (img == Nil)
                    {
                        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?s=160",kAvatorBaseUrl,[CUtil hashForEmail:contactEmail]]]
                                                                        options:SDWebImageRefreshCached
                                                                       progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                                           
                                                                       } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                                           
                                                                           if (finished)
                                                                           {
                                                                               [[SDImageCache sharedImageCache] storeImage:image forKey:entity.account_id toDisk:YES];
                                                                               
                                                                               block(image,finished);
                                                                           }
                                                                       }];
                    }
                }
                else
                {
                    path = [CUtil pathForCachedImage:contactEmail];
                    
                    img = [UIImage imageWithContentsOfFile:path];
                    
                    if (img == Nil)
                    {
                        img = [entity getImageByUserName];
                    }
                }
            }
        }
        else
        {
            img = [entity getImageByUserName];
        }
    }
    
    block (img, YES);
}

+ (void)newAsyncFullImage:(ContactsEntity *)entity WithBlock:(AsyncGetImage)block
{
    __block UIImage*    profileImage =  [entity getImageByUserName];;
    __block NSString*   profileImageURL =Nil;
    
    // This is the full url for profile image
    if (entity.fullURL)
    {
        profileImageURL = entity.fullURL;
        
        profileImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:GET_CACHE_KEY_FOR_FULLURL(entity.account_id)];
        if (profileImage != Nil)
        {
            block (profileImage, YES);
        }else{
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:profileImageURL]
                                                        options:SDWebImageRefreshCached
                                                       progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                           
                                                       } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                           
                                                           if (finished && error == Nil)
                                                           {
                                                               if (image)
                                                               {
                                                                   [[SDImageCache sharedImageCache] storeImage:image forKey:GET_CACHE_KEY_FOR_FULLURL(entity.account_id) toDisk:YES];
                                                                   
                                                                   block(image,finished);
                                                               }
                                                               else
                                                               {
                                                                   
                                                                   [self newAsyncMiniImage:entity WithBlock:block];
                                                               }
                                                           }
                                                           else
                                                           {
                                                               profileImage = [entity getImageByUserName];
                                                               
                                                               block (profileImage, YES);
                                                           }
                                                       }];
        
        }
    }
    else if (entity.miniURL)
    {
        [self newAsyncMiniImage:entity WithBlock:block];
    }
    else if (entity.gravatar_exist)
    {
        [self newAsyncAvatarImage:entity WithBlock:block];
    }
    else
    {
        profileImage = [entity getImageByUserName];
        block (profileImage, YES);
    }
    
}

+ (void)newAsyncMiniImage:(ContactsEntity *)entity WithBlock:(AsyncGetImage)block
{
    __block UIImage*    profileImage = Nil;
    __block NSString*   profileImageURL =Nil;
    
    // This is the full url for profile image
    if (entity.miniURL)
    {
        profileImageURL = entity.miniURL;
        
        profileImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:GET_CACHE_KEY_FOR_MINIURL(entity.account_id)];
        
        if (profileImage == Nil)
        {
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:profileImageURL]
                                                            options:SDWebImageRefreshCached
                                                           progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                               
                                                           } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                               
                                                               if (finished)
                                                               {
                                                                   if (image)
                                                                   {
                                                                       [[SDImageCache sharedImageCache] storeImage:image forKey:GET_CACHE_KEY_FOR_MINIURL(entity.account_id) toDisk:YES];
                                                                       
                                                                       block(image,finished);
                                                                   }
                                                                   else
                                                                   {
                                                                       [self newAsyncAvatarImage:entity WithBlock:block];
                                                                   }
                                                               }
                                                           }];
        }
        else
        {
            block (profileImage, YES);
        }
    }
    
    else if (entity.gravatar_exist)
    {
        [self newAsyncAvatarImage:entity WithBlock:block];
    }
    else
    {
        profileImage = [entity getImageByUserName];
        block (profileImage, YES);
    }
    
}

+ (void)newAsyncAvatarImage:(ContactsEntity *)entity WithBlock:(AsyncGetImage)block
{
    __block UIImage*    profileImage = [entity getImageByUserName];
    
    if (entity.gravatar_exist)
    {
        NSString *contactEmail = entity.mainEmail;
        NSString *path  = @"";
        
        if (contactEmail && [contactEmail length]>0)
        {
            path = [CUtil pathForCachedImage:contactEmail];
        }
        else
        {
            if (entity.email && [entity.email length]>0)
            {
                contactEmail = [[entity.email componentsSeparatedByString:@","] firstObject];
                
                if ([contactEmail length]>0)
                {
                    path = [CUtil pathForCachedImage:contactEmail];
                }
            }
        }
        
        if ([path length]>0 && [[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            profileImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:path]];
            block (profileImage, YES);
        }
        else
        {
            if ( ![CUtil imageInfileCache:contactEmail])
            {
                profileImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:entity.account_id];
                
                if (profileImage == Nil)
                {
                    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?s=160",kAvatorBaseUrl,[CUtil hashForEmail:contactEmail]]]
                                                                    options:SDWebImageRefreshCached
                                                                   progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                                       
                                                                   } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                                       
                                                                       if (finished)
                                                                       {
                                                                           if (image)
                                                                           {
                                                                               [[SDImageCache sharedImageCache] storeImage:image forKey:entity.account_id toDisk:YES];
                                                                               
                                                                               profileImage = image;
                                                                           }
                                                                           else
                                                                           {
                                                                               profileImage = [entity getImageByUserName];
                                                                           }
                                                                           
                                                                           block(profileImage,finished);
                                                                       }
                                                                   }];
                }
                else
                {
                    block (profileImage, YES);
                }
            }
            else
            {
                path = [CUtil pathForCachedImage:contactEmail];
                
                profileImage = [UIImage imageWithContentsOfFile:path];
                block (profileImage, YES);
            }
        }

    }
    else
    {
        block ([entity getImageByUserName], YES);
    }
}

+ (void)newAsyncImage:(ContactsEntity *)entity WithBlock:(AsyncGetImage)block
{
    [self newAsyncFullImage:entity WithBlock:block];
}

// Lin - Ended

// NOT WORKING
// USE [ContactsEntity getAsyncImage:self.padOwnerContact WithBlock:^(id img, BOOL flag) INSTEAD

- (void)getAsyncImageWithBlock:(AsyncGetImage)block
{
    [self newAsyncImageWithBlock:block];
}

+ (void)getAsyncImage:(ContactsEntity *)entity WithBlock:(AsyncGetImage)block
{
    [self newAsyncImage:entity WithBlock:block];
}

- (void)getPlaceholderImageWithBlock:(AsyncGetImage)block
{
    UIImage* placeHolderImg = Nil;
    
    if (self.gravatar_exist)
    {
        NSString *path  = [CUtil pathForCachedImage:self.email];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            placeHolderImg = [UIImage imageWithData:[NSData dataWithContentsOfFile:path] scale:[UIScreen mainScreen].scale];
        }
    }
    
    if(!placeHolderImg)
    {
        if (self.name && [self.name length]>0)
        {
            placeHolderImg = [CUtil imageText:[[self.name substringWithRange:NSMakeRange(0,1)] uppercaseString]
                               withBackground:self.bgcolor
                                         size:CGSizeMake(120, 120)
                                         rate:0.6];
        }
        else if (self.username && [self.username length]>0)
        {
            placeHolderImg = [CUtil imageText:[[self.username substringWithRange:NSMakeRange(0,1)] uppercaseString]
                               withBackground:self.bgcolor
                                         size:CGSizeMake(120, 120)
                                         rate:0.6];
        }
    }
    
    if (placeHolderImg)
    {
        block(placeHolderImg, YES);
    }
    
}

+ (void)getPlaceholderImage:(ContactsEntity *)entity WithBlock:(AsyncGetImage)block
{
    UIImage* placeHolderImg = Nil;
    
    if (entity.gravatar_exist)
    {
        NSString *path  = [CUtil pathForCachedImage:entity.email];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            placeHolderImg = [UIImage imageWithData:[NSData dataWithContentsOfFile:path]
                                              scale:[UIScreen mainScreen].scale];
        }
    }
    
    if(!placeHolderImg)
    {
        if (entity.name && [entity.name length]>0)
        {
            placeHolderImg = [CUtil imageText:[[entity.name substringWithRange:NSMakeRange(0,1)] uppercaseString]
                               withBackground:entity.bgcolor
                                         size:CGSizeMake(120, 120)
                                         rate:0.6];
        }
        else if (entity.username && [entity.username length]>0)
        {
            placeHolderImg = [CUtil imageText:[[entity.username substringWithRange:NSMakeRange(0,1)] uppercaseString]
                               withBackground:entity.bgcolor
                                         size:CGSizeMake(120, 120)
                                         rate:0.6];
        }
    }
    
    if (placeHolderImg)
    {
        block(placeHolderImg, YES);
    }
    
}

- (BOOL) isValidURL:(NSString *)checkURL
{
    NSUInteger length = [checkURL length];
    
    // Empty strings should return NO
    
    if (length > 0)
    {
        NSError *error = nil;
        
        NSDataDetector *dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
        
        if (dataDetector && !error)
        {
            NSRange range = NSMakeRange(0, length);
            NSRange notFoundRange = (NSRange){NSNotFound, 0};
            NSRange linkRange = [dataDetector rangeOfFirstMatchInString:checkURL options:0 range:range];
            
            if (!NSEqualRanges(notFoundRange, linkRange) && NSEqualRanges(range, linkRange))
            {
                return YES;
            }
        }
        else
        {
            NSLog(@"Could not create link data detector: %@ %@", [error localizedDescription], [error userInfo]);
        }
    }
    
    return NO;
}

@end
