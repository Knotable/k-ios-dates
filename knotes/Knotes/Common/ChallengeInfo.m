//
//  ChallengeInfo.m
//  MyPet
//
//  Created by Apple on 13-5-10.
//  Copyright (c) 2013年 Apple. All rights reserved.
//

#import "ChallengeInfo.h"


@implementation ProfileInfo

@synthesize m_strObjectId;
@synthesize m_strUserName, m_strMyName;
@synthesize m_nUserType;
@synthesize m_strDogName, m_strDogPhoto, m_strBreed, m_strCountry, m_strOwnerPhoto, m_strNationality;
@synthesize m_nFollowers, m_dateBirth, m_bFollowed;

- (id) init {
    if ((self = [super init])) {
        m_nUserType = USER_DOGLOVER;
    }
    return self;
}

- (id) initWithUserName:(NSString*)username {
    [self init];
    if (username)
        m_strUserName = [[NSString alloc] initWithString:username];
    return self;
}
- (id) initWithObjectId:(NSString*)objid username:(NSString*)username usertype:(int)usertype dogname:(NSString*)dogname dogphoto:(NSString*)dogphoto ownerphoto:(NSString*)ownerphoto breed:(NSString*)breed country:(NSString*)country followers:(int)followers birthdate:(NSDate*)birthdate myname:(NSString*)myname {
    [self init];
    if (objid != nil)
        m_strObjectId = [[NSString alloc] initWithString:objid];
    if (username != nil)
        m_strUserName = [[NSString alloc] initWithString:username];
    m_nUserType = usertype;
    if (dogname != nil)
        m_strDogName = [[NSString alloc] initWithString:dogname];
    if (dogphoto != nil)
        m_strDogPhoto = [[NSString alloc] initWithString:dogphoto];
    if (ownerphoto != nil)
        m_strOwnerPhoto = [[NSString alloc] initWithString:ownerphoto];
    if (breed != nil)
        m_strBreed = [[NSString alloc] initWithString:breed];
    if (country != nil)
        m_strCountry = [[NSString alloc] initWithString:country];
    if (myname != nil)
        m_strMyName = [[NSString alloc] initWithString:myname];
    [self setBirthDate:birthdate];
    m_nFollowers = followers;
    return self;
}
- (void) dealloc {
    [m_strUserName release];
    [m_strDogName release];
    [m_strObjectId release];
    [m_strDogPhoto release];
    [m_strBreed release];
    [m_strCountry release];
    [m_strOwnerPhoto release];
    [m_strNationality release];
    [m_dateBirth release];
    [super dealloc];
}
- (void) setDogName:(NSString*)dogname {
    if (dogname == nil)
        return;
    if (m_strDogName)
        [m_strDogName release];
    m_strDogName = [[NSString alloc] initWithString:dogname];
}
- (void) setDogPhopo:(NSString*)str {
    if (str == nil)
        return;
    if (m_strDogPhoto)
        [m_strDogPhoto release];
    m_strDogPhoto = [[NSString alloc] initWithString:str];
}
- (void) setOwnerPhoto:(NSString*)str {
    if (str == nil)
        return;
    if (m_strOwnerPhoto)
        [m_strOwnerPhoto release];
    m_strOwnerPhoto = [[NSString alloc] initWithString:str];
}
- (void) setBreed:(NSString*)str {
    if (str == nil)
        return;
    if (m_strBreed)
        [m_strBreed release];
    m_strBreed = [[NSString alloc] initWithString:str];
}
- (void) setNationality:(NSString*)str {
    if (str == nil)
        return;
    if (m_strNationality)
        [m_strNationality release];
    m_strNationality = [[NSString alloc] initWithString:str];
}
- (void) setCountry:(NSString*)str {
    if (str == nil)
        return;
    if (m_strCountry)
        [m_strCountry release];
    m_strCountry = [[NSString alloc] initWithString:str];
}
- (void) setBirthDate:(NSDate*)date {
    if (m_dateBirth)
        [m_dateBirth release];
    m_dateBirth = nil;
    if (date == nil)
        return;
    m_dateBirth = [date retain];
}
- (NSString*) getBirthDateString {
    if (m_dateBirth == nil)
        return @"";
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    NSString *theDate = [dateFormat stringFromDate:m_dateBirth];
    return theDate;
}
- (void) setMyName:(NSString*)str {
    if (str == nil)
        return;
    if (m_strMyName)
        [m_strMyName release];
    m_strMyName = [[NSString alloc] initWithString:str];
}
@end

@implementation ChallengeInfo

@synthesize m_strObjectId;
@synthesize m_strCategory, m_strChallengeName, m_strDate, m_strCoundown, m_strReward;
@synthesize m_strBrief, m_strSponsor, m_strPhoto, m_bEnable;

- (id) initWithPlistDictionary:(NSDictionary*)dic {
    [self init];
    NSString* str = [dic objectForKey:@"category"];
    if (str != nil)
        m_strCategory = [[NSString alloc] initWithString:str];
    str = [dic objectForKey:@"name"];
    if (str != nil)
        m_strChallengeName = [[NSString alloc] initWithString:str];
    str = [dic objectForKey:@"date"];
    if (str != nil)
        m_strDate = [[NSString alloc] initWithString:str];
    str = [dic objectForKey:@"countdown"];
    if (str != nil)
        m_strCoundown = [[NSString alloc] initWithString:str];
    str = [dic objectForKey:@"reward"];
    if (str != nil)
        m_strReward = [[NSString alloc] initWithString:str];
    str = [dic objectForKey:@"brief"];
    if (str != nil)
        m_strBrief = [[NSString alloc] initWithString:str];
    str = [dic objectForKey:@"sponsor"];
    if (str != nil)
        m_strSponsor = [[NSString alloc] initWithString:str];
    str = [dic objectForKey:@"photo"];
    if (str != nil)
        m_strPhoto = [[NSString alloc] initWithString:str];
    m_bEnable = YES;
    return self;
}

- (id) initWithCategory:(NSString*)category name:(NSString*)name date:(NSDate*)date countdown:(NSDate*)countdown reward:(NSString*)reward brief:(NSString*)brief sponsor:(NSString*)sponsor photo:(NSString*)photo {
    [self init];
    if (category != nil)
        m_strCategory = [[NSString alloc] initWithString:category];
    if (name != nil)
        m_strChallengeName = [[NSString alloc] initWithString:name];
    m_date = [date retain];
//    m_nCountdown = countdown;
    m_dateCountDown = [countdown retain];
    if (reward != nil)
        m_strReward = [[NSString alloc] initWithString:reward];
    if (brief != nil)
        m_strBrief = [[NSString alloc] initWithString:brief];
    if (sponsor != nil)
        m_strSponsor = [[NSString alloc] initWithString:sponsor];
    if (photo != nil)
        m_strPhoto = [[NSString alloc] initWithString:photo];
    if ([[NSDate date] compare:countdown] != NSOrderedAscending)
        m_bEnable = NO;
    else
        m_bEnable = YES;
    return self;
}
- (void) setObjectId:(NSString*)objid {
    if (objid)
        m_strObjectId = [[NSString alloc] initWithString:objid];
}
- (void) dealloc {
    [m_strObjectId release];
    [m_strCategory release];
    [m_strChallengeName release];
    [m_strDate release];
    [m_dateCountDown release];
    [m_strCoundown release];
    [m_strReward release];
    [m_strBrief release];
    [m_strSponsor release];
    [m_strPhoto release];
    [super dealloc];
}

- (NSString*) getDateCountdown {
    if (m_bEnable == NO)
        return @"";
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
        
//    NSString *theDate = [dateFormat stringFromDate:m_date];
    NSString *theDateCountDown = @"";//[dateFormat stringFromDate:m_dateCountDown];
    
    unsigned int unitFlags = NSHourCalendarUnit | NSDayCalendarUnit;
    
    NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    NSDateComponents *components = [calendar components:unitFlags
                                               fromDate:[NSDate date]
                                                 toDate:m_dateCountDown
                                                options:0];
    int days = [components day];
    int hours = [components hour];
    if (days || hours) {
        if (days == 0) {
            theDateCountDown = [NSString stringWithFormat:@"%d hours left", hours];
        }
        else if (hours == 0) {
            theDateCountDown = [NSString stringWithFormat:@"%d days left", days];
        }
        else {
            theDateCountDown = [NSString stringWithFormat:@"%d days %d hours left", days, hours];
        }
    }
    
//    return [NSString stringWithFormat:@"%@%@", theDate, theDateCountDown];
    return theDateCountDown;
}

@end

@implementation WallEntryInfo

@synthesize m_strObjectId;
@synthesize m_strChallengeName;
@synthesize m_strUserName;
@synthesize m_dateUpdated;
@synthesize m_strMedia, m_strVideoThumbImage;
@synthesize m_nVotes, m_nMediaType;

//- (id) initWithPlistDictionary:(NSDictionary*)dic {
//    [self init];
//    NSString* str = [dic objectForKey:@"dogname"];
//    if (str != nil)
//        m_strDogName = [[NSString alloc] initWithString:str];
//    str = [dic objectForKey:@"dogphoto"];
//    if (str != nil)
//        m_strDogPhoto = [[NSString alloc] initWithString:str];
//    str = [dic objectForKey:@"ownerphoto"];
//    if (str != nil)
//        m_strOwnerPhoto = [[NSString alloc] initWithString:str];
//    str = [dic objectForKey:@"breed"];
//    if (str != nil)
//        m_strBreed = [[NSString alloc] initWithString:str];
//    str = [dic objectForKey:@"nationality"];
//    if (str != nil)
//        m_strNationality = [[NSString alloc] initWithString:str];
//    str = [dic objectForKey:@"country"];
//    if (str != nil)
//        m_strCountry = [[NSString alloc] initWithString:str];
//    str = [dic objectForKey:@"media"];
//    if (str != nil)
//        m_strMedia = [[NSString alloc] initWithString:str];
//    m_nMediaType = [[dic objectForKey:@"mediatype"] intValue];
//    m_nVotes = [[dic objectForKey:@"vote"] intValue];
//    return self;
//}

- (id) initWithObjectId:(NSString*)objid username:(NSString*)username mediatype:(int)mediatype media:(NSString*)media vote:(int)vote update:(NSDate*)update {
    [self init];
    if (objid)
        m_strObjectId = [[NSString alloc] initWithString:objid];
    if (username != nil)
        m_strUserName = [[NSString alloc] initWithString:username];
    m_nMediaType = mediatype;
    if (media != nil)
        m_strMedia = [[NSString alloc] initWithString:media];
    m_dateUpdated = [update retain];
    m_nVotes = vote;
    return self;
}
//- (id) initWithDogName:(NSString*)dogname dogphoto:(NSString*)dogphoto ownerphoto:(NSString*)ownerphoto breed:(NSString*)breed nationality:(NSString*)nationality country:(NSString*)country mediatype:(int)mediatype media:(NSString*)media vote:(int)vote update:(NSDate*)update {
//    [self init];
//    if (dogname != nil)
//        m_strDogName = [[NSString alloc] initWithString:dogname];
//    if (dogphoto != nil)
//        m_strDogPhoto = [[NSString alloc] initWithString:dogphoto];
//    if (ownerphoto != nil)
//        m_strOwnerPhoto = [[NSString alloc] initWithString:ownerphoto];
//    if (breed != nil)
//        m_strBreed = [[NSString alloc] initWithString:breed];
//    if (nationality != nil)
//        m_strNationality = [[NSString alloc] initWithString:nationality];
//    if (country != nil)
//        m_strCountry = [[NSString alloc] initWithString:country];
//    m_nMediaType = mediatype;
//    if (media != nil)
//        m_strMedia = [[NSString alloc] initWithString:media];
//    m_dateUpdated = [update retain];
//    m_nVotes = vote;
//    return self;
//}
//
//- (void) setObjectId:(NSString*)objid {
//    if (objid)
//        m_strObjectId = [[NSString alloc] initWithString:objid];
//}
- (NSString*) getImageFileName {
    if (m_nMediaType == 0)
        return m_strMedia;
    else
        return m_strVideoThumbImage;
}
- (void) dealloc {
    [m_strUserName release];
    [m_strMedia release];
    [m_dateUpdated release];
    [super dealloc];
}

@end

@implementation PetLikeInfo

@synthesize m_strObjectId, m_strWallentryObjectId;

- (id) initWithObjectId:(NSString*)objid wallentryObjectID:(NSString*)wallentryObjectID {
    [self init];
    if (objid)
        m_strObjectId = [[NSString alloc] initWithString:objid];
    if (wallentryObjectID)
        m_strWallentryObjectId = [[NSString alloc] initWithString:wallentryObjectID];
    return self;
}

- (void) dealloc {
    [m_strObjectId release];
    [m_strWallentryObjectId release];
    [super dealloc];
}

@end

@implementation CommentInfo

@synthesize m_strObjectId, m_strWallentryObjectId, m_strComment, m_strUserName;
@synthesize m_dateUpdated;

- (id) initWithObjectId:(NSString*)objid username:(NSString*)username wallentryObjectID:(NSString*)wallentryObjectID comment:(NSString*)comment date:(NSDate*)updated {
    [self init];
    if (objid)
        m_strObjectId = [[NSString alloc] initWithString:objid];
    if (username)
        m_strUserName = [[NSString alloc] initWithString:username];
    if (wallentryObjectID)
        m_strWallentryObjectId = [[NSString alloc] initWithString:wallentryObjectID];
    if (comment)
        m_strComment = [[NSString alloc] initWithString:comment];
    if (updated)
        m_dateUpdated = [updated retain];
    return self;
}

- (void) dealloc {
    [m_strObjectId release];
    [m_strUserName release];
    [m_strWallentryObjectId release];
    [m_strComment release];
    [m_dateUpdated release];
    [super dealloc];
}

@end

@implementation FollowInfo

@synthesize m_strObjectId, m_strFollowedUserName, m_bFollowed;
@synthesize m_dateUpdated;

- (id) initWithObjectId:(NSString*)objid followedusername:(NSString*)followedusername followed:(BOOL)followed date:(NSDate*)updated {
    [self init];
    if (objid)
        m_strObjectId = [[NSString alloc] initWithString:objid];
    if (followedusername)
        m_strFollowedUserName = [[NSString alloc] initWithString:followedusername];
    if (updated)
        m_dateUpdated = [updated retain];
    return self;
}

- (void) dealloc {
    [m_strObjectId release];
    [m_strFollowedUserName release];
    [m_dateUpdated release];
    [super dealloc];
}

@end

