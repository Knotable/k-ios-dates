//
//  MessageEntity.m
//  RevealControllerProject
//
//  Created by backup on 13-11-15.
//
//

#import "MessageEntity.h"

#import "CItem.h"
#import "BSONTypes.h"
#import "FileManager.h"
#import "FileEntity.h"
#import "ContactsEntity.h"
#import "NSString+Knotes.h"
#import "RegexKitLite.h"
#import "HybridDocument.h"
#import <SDWebImage/SDWebImageManager.h>
#import "Embedly.h"
#import "ST_JSONKit.h"
#import "CachedUrlsEntity.h"

//#define kEmbedlyAppKey @"2c89ab43a3a2439687dda25cbb8b520c"
#define kEmbedlyAppKey @"daa2ece3ae3443b9ae786534f1b0d468"

@implementation MessageEntity

@dynamic archived;
@dynamic name;
@dynamic account_id;
@dynamic mid;
@dynamic message_id;
@dynamic topic_id;
@dynamic content;
@dynamic editors;
@dynamic replys;
@dynamic title;
@dynamic body;
@dynamic email;
@dynamic containerName;
@dynamic type;
@dynamic order;
@dynamic time;
@dynamic created_time;
@dynamic topic_type;
@dynamic liked_account_ids;
@dynamic likes_count;
@dynamic file_ids;
@dynamic file_url;
@dynamic contact;
@dynamic hot;
@dynamic removedHot;
@dynamic on_cloud;
@dynamic need_send;
@dynamic pinned;
@dynamic expanded;
@dynamic has_viewed;
@dynamic highlights;
@dynamic last_viewed;
@dynamic view_count;
@dynamic embeddedImages;
//@dynamic document;
@dynamic documentHTML;
@dynamic documentHash;
@dynamic usertags;
@dynamic muted;

@dynamic isReplyExpanded;
@dynamic isAllExpanded;
@dynamic isImageDataAvailable;
@dynamic currently_contact_edit;

static NSString* imageThumbnailTemplate = @" \
<div class=\"thumbnail-wrapper thumbnail3 uploading-thumb\" id=\"thumb-box-%d\"> \
<p id=\"thumb-box-status-%d\"></p> \
<div class=\"thumb\"> \
<span class=\"img-wrapper\" contenteditable=\"false\"> \
<span class=\"btn-close\" contenteditable=\"false\"></span> \
<img src=\"/images/_close.png\" class=\"delete_file_ico\" style=\"max-width: 400px;\"> \
</span> \
<img class=\"thumb\" src=\"%@\" style=\"max-width: 400px;\"> \
</div></div>";

//<img class=\"thumb\" src=\"http://i.embed.ly/1/display/resize?width=167&amp;height=125&amp;grow=true&amp;key=daa2ece3ae3443b9ae786534f1b0d468&amp;url=%@\" file_id=\"%@\" style=\"max-width: 400px;\"> \

+ (void)addThumbnailsHTMLto:(NSMutableString *)output forFileIDS:(NSArray *)fileIDs
{
    for (NSString *fileID in fileIDs) {
        NSString *fid = [fileID noPrefix:kKnoteIdPrefix];
        FileEntity *file = [FileEntity MR_findFirstByAttribute:@"file_id" withValue:fid];
        if (!file) {
            continue;
        }
        int r = arc4random() % 10000;
        NSString *imgUrl = @"";
        if (file.thumbnail_url && [file.thumbnail_url length]>0) {
            imgUrl = file.thumbnail_url;
        } else {
            imgUrl = file.full_url;
        }
        NSString *escapedURL = [imgUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *formattedThumbnail = [NSString stringWithFormat:imageThumbnailTemplate,
                                        r, r,
                                        escapedURL];
        
        NSLog(@"finished thumbnail HTML: %@", formattedThumbnail);
        
        [output appendString:formattedThumbnail];
    }

}

+ (NSString *)wrapTextInHTML:(NSString *)text
{   
    NSArray *lines = [text componentsSeparatedByString:@"\n"];
    NSMutableString *output = [[NSMutableString alloc] init];
    
    // Lin - Marked to check Knote issue
    // To implement https://trello.com/c/oiwpzB3l/748-use-of-space-in-knotes-ui
//    [output appendString:@"<p>"];
    
    // Lin - Ended

    if ([lines count] == 1
        && [[lines objectAtIndex:0] isEqualToString:@""])
    {
//        [output appendFormat:@"<div>%@</div>", [lines objectAtIndex:0] ];
        
        return @"";
    }
    else
    {
        for (NSString *line in lines)
        {
            NSString *content;
            
            if ([line trimmed].length == 0)
            {
                content = @"<br>";
            }
            else
            {
                content = line;
            }
            
            [output appendFormat:@"<div>%@</div>", content];
        }
    }
    
    
    /*
    if (self.file_ids && self.file_ids.length > 0) {
        NSArray *fileIDs = [self.file_ids componentsSeparatedByString:@","];
        [self addThumbnailsHTMLto:output forFileIDS:fileIDs];
    }
     */
    
    // Lin - Marked to check Knote issue
    // To implement https://trello.com/c/oiwpzB3l/748-use-of-space-in-knotes-ui
    
//    [output appendString:@"</p>"];
    
    // Lin - Ended
    
    return [output copy];

}

- (NSString *)convertedHTMLBody
{
    if (self.documentHTML) {
        return self.documentHTML;
    }
    
    NSArray *lines = [self.body componentsSeparatedByString:@"\n"];
    NSMutableString *output = [[NSMutableString alloc] init];
    
    [output appendString:@"<p>"];
    for (NSString *line in lines) {
        NSString *content;
        if ([line trimmed].length == 0) {
            content = @"<br>";
        } else {
            content = line;
        }
        [output appendFormat:@"<div>%@</div>", content];
    }
    if (self.file_ids && self.file_ids.length > 0) {
        NSArray *fileIDs = [self.file_ids componentsSeparatedByString:@","];
        [MessageEntity addThumbnailsHTMLto:output forFileIDS:fileIDs];
    }
    
    
    [output appendString:@"</p>"];
    
    return [output copy];
}


- (void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues withTopicId:(NSString *)topic_id
{
    if (self.need_send)
    {
        return;
    }
    
    NSString *type = keyedValues[@"type"];
 
    NSNumber *topic_type = keyedValues[@"topic_type"];

    id from = keyedValues[@"from"];
    
    id fromCapital = keyedValues[@"From"];

    NSString *note = keyedValues[@"note"];
 
    NSString *htmlBody = keyedValues[@"htmlBody"];
    
    NSString *file_url = @"";
    NSRange range = [htmlBody rangeOfString:@"href=\"http://"];
    if((range.location + @"href=\"".length)  < htmlBody.length){
        file_url = [htmlBody substringFromIndex:range.location + @"href=\"".length];
        range = [file_url rangeOfString:@"\""];
        file_url = [file_url substringToIndex:range.location];
    }
    
    NSString *title = keyedValues[@"title"];
    
    if (![title isKindOfClass:[NSString class]])
    {
        title = nil;
    }
    
    NSString * containerName = keyedValues[@"containerName"];

    NSString *deadline_subject = keyedValues[@"deadline_subject"];
    
    self.account_id = keyedValues[@"account_id"];
    
    if (!self.account_id)
    {
        self.account_id = @"";
    }
    
    // Name
    
    NSString *name = keyedValues[@"name"];

    // Sub message
    
    NSString *changed_text = keyedValues[@"changed_text"];
    
    // File_url
    
    self.file_url = file_url;

    if ([type isEqualToString:@"knote"]
        ||[type isEqualToString:@"messages_to_knote"]
        ||[type isEqualToString:@"deadline"]
        ||[type isEqualToString:@"poll"]
        ||[type isEqualToString:@"checklist"]
        ||[type isEqualToString:@"lock"]
        ||[type isEqualToString:@"key_knote"])
    {
        if (![name isKindOfClass:[NSNull class]])
        {
        self.name = name;
        }
    }
    else if ([type isEqualToString:@"messages"])
    {
        id fromVal = nil;
        
        if (topic_type.intValue == 1)
        {
            //gmail
            fromVal = from;
        }
        else
        {
            fromVal = fromCapital;
        }
        
        if ([fromVal isKindOfClass:[NSArray class]])
        {
            self.name = [[(NSArray *)fromVal valueForKey:@"name"] componentsJoinedByString:@","];
        }
        else if (fromVal && fromVal != [NSNull null])
        {
            self.name = fromVal;
        }
    }
    else
    {
        if ([from isKindOfClass:[NSArray class]])
        {
            self.name = [[(NSArray *)from valueForKey:@"name"] componentsJoinedByString:@","];
        }
        else if (from && from != [NSNull null] && ![from isKindOfClass:[NSNull class]])
        {
            self.name = from;
        }
    }
    
    if (!self.name)
    {
        self.name = @"";
    }
    
    self.containerName = (containerName) ? containerName : CONTAINER_NAME_MAIN;

    //email
    if ([from isKindOfClass:[NSArray class]])
    {
        self.email = [[(NSArray *)from valueForKey:@"address"] componentsJoinedByString:@","];
    }
    else if(from && from != [NSNull null])
    {
        self.email = from;
    }
    
    if (!self.email)
    {
        self.email = @"";
    }
    
    if(self.name && self.name != (id)[NSNull null] && [self.name isKindOfClass:[NSString class]])
    {
        self.name = [[self.name stringByReplacingOccurrencesOfRegex:@"<[^>]*>|\n" withString:@""] trimmed];
    }
    
    if(self.email && self.email != (id)[NSNull null])
    {
        NSString *realEmail = [self.email stringByMatching:@"<([^@]+@[^@]+)>" capture:1];
        
        if (realEmail)
        {
            self.email = [realEmail trimmed];
        }
    }
    
    //message ID
    
    id messageID = keyedValues[@"_id"];
    
    if (messageID)
    {
        if ([messageID isKindOfClass:[BSONObjectID class]])
        {
            self.message_id = [messageID stringValue];
        }
        else
        {
            self.message_id = messageID;
        }
    }
    
    //title

    NSString *sourceHTML = nil;
    NSString *sourceText = nil;

    if ([type isEqualToString:@"key_knote"])
    {
        //self.title = [self stringByStrippingHTML:note];
        self.title = title;
        sourceHTML = note;
    }
    else if ([type isEqualToString:@"knote"] || [type isEqualToString:@"messages_to_knote"])
    {
        //self.title = [self stringByStrippingHTML:body];
        //self.title = [self stringByStrippingHTML:htmlBody];
        self.title = title;
        sourceHTML = htmlBody;
    }
    else if ([type isEqualToString:@"deadline"])
    {
        self.title = deadline_subject;
        sourceText = deadline_subject;
    }
    else if ([type isEqualToString:@"poll"]||[type isEqualToString:@"checklist"])
    {
        self.title = title;
        sourceText = title;
    }
    else if ([type isEqualToString:@"lock"])
    {
        //self.title = htmlBody;
        sourceHTML = htmlBody;
        self.title = title;
    }
    else if ([type isEqualToString:@"messages"])
    {
        if (changed_text)
        {
            //self.title = [self stringByStrippingHTML:changed_text];
            sourceHTML = changed_text;
        }
        else if (topic_type.intValue == 1)
        {
            //gmail
            //self.title = keyedValues[@"text"];
            sourceText = keyedValues[@"text"];
        }
        else
        {
            //self.title = keyedValues[@"body-plain"];
            sourceText = keyedValues[@"text"];
        }
        
        if (!sourceText)
        {
            sourceText = keyedValues[@"body-plain"];
        }
        
        self.title = title;
    }
    else
    {
        //self.title = keyedValues[@"text"];
        sourceText = keyedValues[@"text"];
    }

    if(sourceText != nil && sourceText != (id)[NSNull null])
    {
        self.body = sourceText;
    }
    else if (sourceHTML != nil
             && sourceHTML != (id)[NSNull null])
    {
        //self.title = [self stringByStrippingHTML:sourceHTML];
        NSString *strHTML=sourceHTML;
        
        if(([strHTML rangeOfString:@"src=\"data:image"].location != NSNotFound) && ([strHTML rangeOfString:@"base64"].location != NSNotFound) ){
            NSString *strOfData=[[[[[[strHTML componentsSeparatedByString:@"base64"] objectAtIndex:1] componentsSeparatedByString:@","]objectAtIndex:1] componentsSeparatedByString:@"style"] firstObject];
            strOfData=[NSString stringWithFormat:@"\"%@",strOfData];
            NSData *data = [[NSData alloc]initWithBase64EncodedString:strOfData
                                                              options:NSDataBase64DecodingIgnoreUnknownCharacters];
            UIImage *img= [UIImage imageWithData:data];
            if (img !=nil)
            {
                self.isImageDataAvailable=YES;
                //self.imageFromHTML=img;
            }
        }
        NSString *hash = [sourceHTML md5];
        
        BOOL shouldUpdateHTML = !(self.documentHTML && self.documentHash && [hash isEqualToString:self.documentHash]);
        
        if (shouldUpdateHTML)
        {
            HybridDocument *document = [[HybridDocument alloc] initWithHTML:sourceHTML];
            self.body = document.text;
            self.documentHash = hash;
            self.documentHTML = sourceHTML;
            
        }
    }
    
    //NSLog(@"Stripped HTML:\n%@\nEND TEXT", self.title);

    //content
    if ([type isEqualToString:@"poll"]||[type isEqualToString:@"checklist"])
    {
        self.content = [NSKeyedArchiver archivedDataWithRootObject:keyedValues[@"options"]];
    }
    else if ([type isEqualToString:@"deadline"])
    {
        NSDate *date = keyedValues[@"deadline"];
        
        if ([date isKindOfClass:[NSDate class]])
        {
            self.content = [NSKeyedArchiver archivedDataWithRootObject:date];
        }
        else
        {
            if ([date isKindOfClass:[NSDictionary class]])
            {
                NSTimeInterval t = [[[(NSDictionary *)date allValues] firstObject] longLongValue];
                
                if (t > kKnoteTimeIntervalMaxValue)
                {
                    t = t/1000;
                }
                
                NSDate *deadLine = [NSDate dateWithTimeIntervalSince1970:t];
                
                self.content = [NSKeyedArchiver archivedDataWithRootObject:deadLine];
            }
        }
    }

#if 1
    self.editors = nil;
    
    if (keyedValues[@"editors"])
    {
        NSArray *array =  keyedValues[@"editors"];
        
        if ([array isKindOfClass:[NSArray class]])
        {
            if ([array count]>1)
            {
                array = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    
                    NSDate *date1 = [obj1 objectForKey:@"date"];
                    NSDate *date2 = [obj2 objectForKey:@"date"];
                    
                    NSComparisonResult result = NSOrderedDescending;
                    
                    if ([date1 isKindOfClass:[NSDate class]]
                        && [date2 isKindOfClass:[NSDate class]])
                    {
                        result = [date1 compare:date2];
                    }
                    
                    return result == NSOrderedDescending; // 升序
                    return result == NSOrderedAscending;  // 降序
                }];
            }
        }
        
        if ([array count]>0)
        {
            self.editors = [NSKeyedArchiver archivedDataWithRootObject:array];
        }
    }
    
    /********************************************************
     
     Lin : I think "currently_contact_edit" has NSArray data type in DB
     
     How can you try to cast from array to NSString?
     
     Who is the writer wrote this code? OMG
     
     This is the main crash issue when user try to edit any Knote
     
     ********************************************************/
    
    if (keyedValues[@"currently_contact_edit"])
    {
        id dictVal  = keyedValues[@"currently_contact_edit"];
        
        if ([dictVal isKindOfClass:[NSArray class]])
        {
            NSArray*    contactArray = (NSArray*)dictVal;
            
            self.currently_contact_edit = [contactArray firstObject];
        }
        else if ([dictVal isKindOfClass:[NSString class]])
        {
            self.currently_contact_edit = keyedValues[@"currently_contact_edit"];
        }
    }
    else
    {
        self.currently_contact_edit = @"";
    }

    self.replys = nil;
    
    if (keyedValues[@"replys"])
    {
        NSArray *array =  keyedValues[@"replys"];
        
        if ([array isKindOfClass:[NSArray class]])
        {
            if ([array count]>1)
            {
                array = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    
                    NSDate *date1 = [obj1 objectForKey:@"date"];
                    NSDate *date2 = [obj2 objectForKey:@"date"];
                    NSComparisonResult result = NSOrderedDescending;
                    
                    if ([date1 isKindOfClass:[NSDate class]] && [date2 isKindOfClass:[NSDate class]])
                    {
                        result = [date1 compare:date2];
                    }
                    
                    return result == NSOrderedDescending; // 升序
                    return result == NSOrderedAscending;  // 降序
                }];
            }
            
            if ([array count]>0)
            {
                self.replys = [NSKeyedArchiver archivedDataWithRootObject:array];
            }
        }
    }
#else
    if (keyedValues[@"editors"]) {
        NSArray *array =  keyedValues[@"editors"];
        array = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            
            NSDate *date1 = [obj1 objectForKey:@"date"];
            NSDate *date2 = [obj2 objectForKey:@"date"];
            
            NSComparisonResult result = [date1 compare:date2];
            
            return result == NSOrderedDescending; // 升序
            return result == NSOrderedAscending;  // 降序
        }];
        self.editors = [NSKeyedArchiver archivedDataWithRootObject:array];
    } else {
        self.editors = nil;
    }
    if (keyedValues[@"replys"]) {
        NSArray *array =  keyedValues[@"replys"];
        array = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            
            NSDate *date1 = [obj1 objectForKey:@"date"];
            NSDate *date2 = [obj2 objectForKey:@"date"];
            
            NSComparisonResult result = [date1 compare:date2];
            
            return result == NSOrderedDescending; // 升序
            return result == NSOrderedAscending;  // 降序
        }];
        if ([array count]>0) {
            self.replys = [NSKeyedArchiver archivedDataWithRootObject:array];
        } else {
            self.replys = nil;
        }
    } else {
        self.replys = nil;
    }
#endif
    //time
    
    NSNumber *timestamp = keyedValues[@"timestamp"];
    
    if (timestamp && timestamp != (id)[NSNull null])
    {
        double time_double = timestamp.doubleValue;
        
        if (time_double > kKnoteTimeIntervalMaxValue)
        {
            self.time = (int64_t)time_double/1000.0;
        }
        else
        {
            self.time = (int64_t)time_double;
        }
        
        self.created_time = [NSDate dateWithTimeIntervalSince1970:self.time];
    }
    
    if (!self.created_time)
    {
        self.created_time = [NSDate date];
        
//         self.time = (int64_t)[self.created_time timeIntervalSince1970];
        
        NSLog(@"Missing timestamp for message: %@, setting current time: %lld", self.message_id, self.time);
    }
    
    //order
    NSNumber *order = keyedValues[@"order"];
    
    if (order != nil && [order isKindOfClass:[NSNumber class]])
    {
        self.order = order.intValue;
    }
    else
    {
        self.order = -1;
    }
    
    //topic_type
    
    self.topic_type = [[NSString stringWithFormat:@"%d",[keyedValues[@"topic_type"] intValue]] intValue];
    
    //type
    
    NSNumber *typeValue;
    
    if ([type isEqualToString:@"messages"])
    {
        typeValue = [NSNumber numberWithInteger:C_MESSAGE];
    }
    else if ([type isEqualToString:@"knote"]) {
        typeValue = [NSNumber numberWithInteger:C_KNOTE];
    }
    else if ([type isEqualToString:@"key_knote"]) {
        typeValue = [NSNumber numberWithInteger:C_KEYKNOTE];
    }
    else if ([type isEqualToString:@"deadline"]) {
        typeValue = [NSNumber numberWithInteger:C_DATE];
    }
    else if ([type isEqualToString:@"poll"]) {
        typeValue = [NSNumber numberWithInteger:C_VOTE];
    }
    else if ([type isEqualToString:@"checklist"]) {
        typeValue = [NSNumber numberWithInteger:C_LIST];
    }
    else if ([type isEqualToString:@"lock"]) {
        typeValue = [NSNumber numberWithInteger:C_LOCK];
    }
    else if ([type isEqualToString:@"todo"]) {//todo
        typeValue = [NSNumber numberWithInteger:-1];
    }
    else if ([type isEqualToString:@"messages_to_knote"]) {
        typeValue = [NSNumber numberWithInteger:C_MESSAGE_TO_KNOTE];
    }
    
    if (typeValue) {
        self.type = typeValue.intValue;
    }
    
    NSArray *tArray = keyedValues[@"liked_account_ids"];
    
    //liked account IDs
    if (tArray)
    {
        if (![type isEqualToString:@"deadline"])
        {
            if ([tArray isKindOfClass:[NSArray class]])
            {
                if (tArray.count > 0)
                {
                    NSMutableArray *tArray1 = [NSMutableArray new];
                    
                    for (NSString *str in tArray)
                    {
                        if (str
                            && [str isKindOfClass:[NSString class]]
                            && str.length>0)
                        {
                            [tArray1 addObject:str];
                        }
                    }
                    
                    self.liked_account_ids = [tArray1 componentsJoinedByString:@","];
                }
                
                self.likes_count = [tArray count];
                
            }
            else if ([tArray isKindOfClass:[NSString class]])
            {
                self.liked_account_ids = (NSString *)tArray;
                self.likes_count = 1;
            }
        }
        else
        {
            self.likes_count = 0;
        }
    }
    else
    {
        self.likes_count = 0;
    }

    if(topic_id)
    {
        self.topic_id = topic_id;
    }
    else if(keyedValues[@"topic_id"])
    {
        self.topic_id = keyedValues[@"topic_id"];
    }

    //NSLog(@"set topic ID to: %@", self.topic_id);
    //file IDS
    
    NSArray *file_ids = keyedValues[@"file_ids"];
    
    if (file_ids && file_ids.count > 0)
    {
        self.file_ids = [file_ids componentsJoinedByString:@","];
    }
    
    NSNumber *archived = keyedValues[@"archived"];
    
    if (archived != nil && ![archived isEqual:[NSNull null]])
    {
        self.archived = [archived boolValue];
    }
    else
    {
        self.archived = NO;
    }
    
    NSNumber *pinned = keyedValues[@"pinned"];
    
    if (pinned != nil && ![pinned isEqual:[NSNull null]])
    {
        self.pinned = [pinned boolValue];
    }
    else
    {
        self.pinned = NO;
    }

    //NSLog(@"looking for contact for user email: %@", self.email);

    self.on_cloud = YES;
    self.need_send = NO;

    [self loadFiles];
    
    [self checkForEmbeddedImages];
    
    NSArray *usertags_array = keyedValues[@"usertags"];
    if (usertags_array && [usertags_array isKindOfClass:[NSArray class]]) {
        self.usertags = [usertags_array componentsJoinedByString:@","];
    }
}

- (void)wasJustDisplayedSave:(BOOL)shouldSave
{
    AppDelegate *app = [AppDelegate sharedDelegate];
    
    NSDate *sessionDate = app.sessionStart;
    
    BOOL dirty = NO;

    if(!self.last_viewed){
        self.last_viewed = sessionDate;
        self.view_count = 1;
        dirty = YES;
    }
    else if(![self.last_viewed isEqualToDate:sessionDate]){
        self.last_viewed = sessionDate;
        self.view_count += 1;
        dirty = YES;
    }
    
    if (shouldSave && dirty) {
        [AppDelegate saveContext];
    }
    
}

- (BOOL)hasPhotoAvailable
{
    if(self.file_ids
       && self.file_ids.length > 0)
    {
        NSArray *fileIds = [self.file_ids componentsSeparatedByString:@","];
        
        for(NSString *fileId in fileIds)
        {
            FileEntity *file = [FileEntity MR_findFirstByAttribute:@"file_id"
                                                         withValue:[fileId noPrefix:kKnoteIdPrefix]];
            
            if (file && file.isImage.boolValue)
            {
                return [[NSFileManager defaultManager] fileExistsAtPath:[file filePath]];
            }
        }
    }
    else if (self.documentHTML)
        return NO;
    return NO;
}

- (NSArray *)availableFileIDs
{
    NSMutableArray *available = [NSMutableArray new];
    
    NSArray *fileIds = [self.file_ids componentsSeparatedByString:@","];
    
    for(NSString *fileId in fileIds)
    {
        FileEntity *file = [FileEntity MR_findFirstByAttribute:@"file_id" withValue:[fileId noPrefix:kKnoteIdPrefix]];
        
        if (file && file.isImage.boolValue)
        {
            BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[file filePath]];
            
            NSLog(@"file id: %@ exists locally? %d", fileId, exists);

            if(exists)
            {
                [available addObject:fileId];
            }
        }
    }
    
    return [available copy];
}

- (void)loadFiles
{
    if(!self.file_ids || self.file_ids.length == 0) return;
    
    NSArray *file_ids = [self.file_ids componentsSeparatedByString:@","];
    
    for(NSString *file_id in file_ids)
    {
        [FileEntity ensureFileID:[file_id noPrefix:kKnoteIdPrefix] message:self];
    }
}

- (NSArray *)storedEmbeddedImages
{
    if (self.embeddedImages)
    {
        return [self.embeddedImages componentsSeparatedByString:@"☂"];
    }
    return @[];
}

- (NSArray *)loadedEmbeddedImages
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    NSMutableArray *loaded = [[NSMutableArray alloc] init];
    
    NSArray * embeddedImagesArray = [self storedEmbeddedImages];
    
    for (NSString *urlAbsoluteString in embeddedImagesArray)
    {
        
        [manager downloadImageWithURL:[NSURL URLWithString:urlAbsoluteString] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize){} completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL * url){
            if(cacheType != SDImageCacheTypeNone){
                [loaded addObject:urlAbsoluteString];
            }
        }];
    }
//    NSLog(@"loaded images: %@", loaded);
    return [loaded copy];
}

- (void)checkForEmbeddedImages
{
    NSString *text = self.body;
    
    if (!text)
    {
        return;
    }

    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    NSArray *matches = [detector matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
//    NSManagedObjectID *selfID = self.objectID;

    NSMutableArray *imageURLs = [[NSMutableArray alloc] init];
    
    for (NSTextCheckingResult *match in matches)
    {
        NSURL *url = [match URL];
        
        NSString *absoluteString = [url absoluteString];
        
        NSLog(@"Found URL in message: %@", absoluteString);

        if ([[absoluteString lowercaseString] rangeOfRegex:@"(png|gif|jpe?g)"].location != NSNotFound)
        {
            NSLog(@"Is image");
            
            [imageURLs addObject:absoluteString];

            if (![manager diskImageExistsForURL:url])
            {
                NSLog(@"Downloading Embedding Images : %@", url);
                [manager downloadImageWithURL:url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize){} completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL * url){
                    if(cacheType != SDImageCacheTypeNone){
                        if(url){
                            [manager downloadImageWithURL:url
                                                  options:0
                                                 progress:Nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                     
                                                     NSLog(@"Download completed, error: %@", error);
                                                     
                                                        if (image)
                                                     {
                                                         NSLog(@"Downloaded embedded image from URL: %@ cachetype: %d", url, (int)cacheType);
                                                         
                                                         if (cacheType == SDImageCacheTypeNone)
                                                         {
                                                             [[NSNotificationCenter defaultCenter] postNotificationName:FILE_DOWNLOADED_NOTIFICATION
                                                                                                                 object:nil
                                                                                                               userInfo:nil];
                                                             
                                                         }
                                                     }
                                                 }];
                        }
                    }
                }];
            }
            else
            {
                NSLog(@"already exists on disk");
            }
        }
        else
        {
            CachedUrlsEntity *entity =  [CachedUrlsEntity MR_findFirstByAttribute:@"url" withValue:absoluteString];
            
            if (!entity)
            {
                Embedly *e = [[Embedly alloc] initWithKey:kEmbedlyAppKey delegate:self];
                [e callEmbedlyApi:@"/1/oembed" withUrl:absoluteString params:nil];
            }
            else
            {
                [imageURLs addObject:entity.embedlyUrl];
            }
        }
    }
    
    if (imageURLs.count > 0)
    {
        self.embeddedImages = [imageURLs componentsJoinedByString:@"☂"];
    }
    
}

- (void)embedlyFailure:(NSString *)callUrl
             withError:(NSError *)error
              endpoint:(NSString *)endpoint
             operation:(AFHTTPRequestOperation *)operation
{
    NSLog(@"embedly failure %@", callUrl);
}

- (void)embedlySuccess:(NSString *)callUrl
          withResponse:(id)response
              endpoint:(NSString *)endpoint
             operation:(AFHTTPRequestOperation *)operation
{
    NSDictionary *dic = nil;
    if([response isKindOfClass:[NSData class]])
    {
        dic = [(NSData *)response objectFromJSONData_biex];
    }
    else if ([response isKindOfClass:[NSDictionary class]])
    {
        dic = (NSDictionary *)response;
    }
    
    NSRange range = [callUrl rangeOfString:@"&url="];
    NSUInteger loc = range.location+range.length;
    NSUInteger len = callUrl.length-loc;
    NSString *absoluteString = [callUrl substringWithRange:NSMakeRange(loc,len) ];
    
    NSString *urlstr = dic[@"thumbnail_url"];
    
    if (urlstr)
    {
        NSURL *url = [NSURL URLWithString:urlstr];
        
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        
        if(url){
            [manager downloadImageWithURL:url
                                  options:0
                                 progress:Nil
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                    
                                    if (self.isFault)
                                    {
                                        return;
                                    }
                                    NSLog(@"Download completed, error: %@", error);
                                    
                                    if (image)
                                    {
                                        NSLog(@"Downloaded embedded image from URL: %@ cachetype: %d", url, (int)cacheType);
                                        
                                        NSMutableArray *imageURLs = [[NSMutableArray alloc] init];
                                        
                                        if (!self.embeddedImages || self.embeddedImages<=0)
                                        {
                                            
                                            [imageURLs addObject:urlstr];
                                        }
                                        else
                                        {
                                            imageURLs = [[self.embeddedImages componentsSeparatedByString:@"☂"] mutableCopy] ;
                                            [imageURLs addObject:urlstr];
                                        }
                                        
                                        self.embeddedImages = [imageURLs componentsJoinedByString:@"☂"];
                                        
                                        CachedUrlsEntity *entity =  [CachedUrlsEntity MR_findFirstByAttribute:@"url" withValue:absoluteString];
                                        
                                        if (!entity)
                                        {
                                            entity = [CachedUrlsEntity MR_createEntity];
                                            entity.url = absoluteString;
                                            entity.embedlyUrl = urlstr;
                                            [AppDelegate saveContext];
                                        }
                                        
                                        //                if (cacheType == SDImageCacheTypeNone)
                                        {
                                            [[NSNotificationCenter defaultCenter] postNotificationName:FILE_DOWNLOADED_NOTIFICATION object:nil userInfo:nil];
                                            
                                        }
                                    }
                                }];
        }
    }
}
/*
- (void)awakeFromFetch {

    [super awakeFromFetch];
    NSString *documentHTML = [self documentHTML];
    if (documentHTML != nil) {
        HybridDocument *document = [[HybridDocument alloc] initWithHTML:documentHTML];
        [self setDocument:document];
    }
}

- (HybridDocument *)document {
    [self willAccessValueForKey:@"document"];
    HybridDocument *document = [self document];
    [self didAccessValueForKey:@"document"];

    [self setPr]
    return document;
}
*/


@end
