//
//  ChallengeInfo.h
//  MyPet
//
//  Created by Apple on 13-5-10.
//  Copyright (c) 2013年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

enum USER_TYPE {
    USER_DOGOWNER,
    USER_DOGLOVER,
    USER_DOGTRAINER,
};

@interface ProfileInfo : NSObject {
    NSString*   m_strObjectId;
    NSString*   m_strUserName;
    int         m_nUserType;
    NSString*   m_strDogName;
    NSString*   m_strDogPhoto;
    NSString*   m_strBreed;
    NSString*   m_strNationality;
    NSString*   m_strCountry;
    NSString*   m_strOwnerPhoto;
    NSString*   m_strMyName;
    NSDate*     m_dateBirth;
    int     m_nFollowers;
    BOOL    m_bFollowed;
}

@property (nonatomic) int   m_nUserType;
@property (nonatomic, assign) NSString*   m_strObjectId;
@property (nonatomic, assign) NSString*   m_strDogName;
@property (nonatomic, assign) NSString*   m_strDogPhoto;
@property (nonatomic, assign) NSString*   m_strBreed;
@property (nonatomic, assign) NSString*   m_strCountry;
@property (nonatomic, assign) NSString*   m_strNationality;
@property (nonatomic, assign) NSString*   m_strOwnerPhoto;
@property (nonatomic, assign) NSString*   m_strUserName;
@property (nonatomic, assign) NSString*   m_strMyName;
@property (nonatomic, assign) NSDate*   m_dateBirth;
@property (nonatomic) int   m_nFollowers;
@property (nonatomic) BOOL   m_bFollowed;

- (id) initWithUserName:(NSString*)username;
- (id) initWithObjectId:(NSString*)objid username:(NSString*)username usertype:(int)usertype dogname:(NSString*)dogname dogphoto:(NSString*)dogphoto ownerphoto:(NSString*)ownerphoto breed:(NSString*)breed country:(NSString*)country followers:(int)followers birthdate:(NSDate*)birthdate myname:(NSString*)myname;
- (void) setDogName:(NSString*)dogname;
- (void) setDogPhopo:(NSString*)str;
- (void) setOwnerPhoto:(NSString*)str;
- (void) setBreed:(NSString*)str;
- (void) setNationality:(NSString*)str;
- (void) setCountry:(NSString*)str;
- (void) setBirthDate:(NSDate*)date;
- (void) setMyName:(NSString*)str;
- (NSString*) getBirthDateString;

@end

@interface ChallengeInfo : NSObject {
    NSString*   m_strObjectId;
    NSString*   m_strCategory;
    NSString*   m_strChallengeName;
    NSString*   m_strDate;
    NSDate*     m_date;
    NSDate*     m_dateCountDown;
    int         m_nCountdown;
    NSString*   m_strCoundown;
    NSString*   m_strReward;
    NSString*   m_strBrief;
    NSString*   m_strSponsor;
    NSString*   m_strPhoto;
    NSDate*     m_dateUpdated;
    BOOL        m_bEnable;
}

@property (nonatomic, assign) NSString*   m_strObjectId;
@property (nonatomic, assign) NSString*   m_strCategory;
@property (nonatomic, assign) NSString*   m_strChallengeName;
@property (nonatomic, assign) NSString*   m_strDate;
@property (nonatomic, assign) NSString*   m_strCoundown;
@property (nonatomic, assign) NSString*   m_strReward;
@property (nonatomic, assign) NSString*   m_strBrief;
@property (nonatomic, assign) NSString*   m_strSponsor;
@property (nonatomic, assign) NSString*   m_strPhoto;
@property (nonatomic) BOOL        m_bEnable;

- (id) initWithPlistDictionary:(NSDictionary*)dic;
//- (id) initWithCategory:(NSString*)category name:(NSString*)name date:(NSDate*)date countdown:(int)countdown reward:(NSString*)reward brief:(NSString*)brief sponsor:(NSString*)sponsor photo:(NSString*)photo;
- (id) initWithCategory:(NSString*)category name:(NSString*)name date:(NSDate*)date countdown:(NSDate*)countdown reward:(NSString*)reward brief:(NSString*)brief sponsor:(NSString*)sponsor photo:(NSString*)photo;
- (void) setObjectId:(NSString*)objid;
- (NSString*) getDateCountdown;

@end

enum MEDIA_TYPE {
    MEDIA_PHOTO = 0,
    MEDIA_VIDEO,
};

@interface WallEntryInfo : NSObject {
    NSString*   m_strObjectId;
    NSString*   m_strUserName;
    NSString*   m_strChallengeName;
    int         m_nMediaType;
    NSString*   m_strMedia;
    NSString*   m_strVideoThumbImage;
    int         m_nVotes;
    NSDate*     m_dateUpdated;
}

@property (nonatomic, assign) NSString*   m_strObjectId;
@property (nonatomic, assign) NSString*   m_strChallengeName;
@property (nonatomic, assign) NSString*   m_strUserName;
@property (nonatomic, assign) NSString*   m_strMedia;
@property (nonatomic, assign) NSString*   m_strVideoThumbImage;
@property (nonatomic, assign) NSDate*     m_dateUpdated;
@property (nonatomic) int   m_nMediaType;
@property (nonatomic) int   m_nVotes;

//- (id) initWithPlistDictionary:(NSDictionary*)dic;
//- (id) initWithDogName:(NSString*)dogname dogphoto:(NSString*)dogphoto ownerphoto:(NSString*)ownerphoto breed:(NSString*)breed nationality:(NSString*)nationality country:(NSString*)country mediatype:(int)mediatype media:(NSString*)media vote:(int)vote update:(NSDate*)update;
- (id) initWithObjectId:(NSString*)objid username:(NSString*)username mediatype:(int)mediatype media:(NSString*)media vote:(int)vote update:(NSDate*)update;
- (NSString*) getImageFileName;

@end

@interface PetLikeInfo : NSObject {
    NSString*   m_strObjectId;
    NSString*   m_strWallentryObjectId;
}
@property (nonatomic, assign) NSString*   m_strObjectId;
@property (nonatomic, assign) NSString*   m_strWallentryObjectId;

- (id) initWithObjectId:(NSString*)objid wallentryObjectID:(NSString*)wallentryObjectID;

@end

@interface CommentInfo : NSObject {
    NSString*   m_strObjectId;
    NSString*   m_strUserName;
    NSString*   m_strWallentryObjectId;
    NSString*   m_strComment;
    NSDate*     m_dateUpdated;
}

@property (nonatomic, assign) NSString*   m_strObjectId;
@property (nonatomic, assign) NSString*   m_strUserName;
@property (nonatomic, assign) NSString*   m_strWallentryObjectId;
@property (nonatomic, assign) NSString*   m_strComment;
@property (nonatomic, assign) NSDate*   m_dateUpdated;

- (id) initWithObjectId:(NSString*)objid username:(NSString*)username wallentryObjectID:(NSString*)wallentryObjectID comment:(NSString*)comment date:(NSDate*)updated;

@end

@interface FollowInfo : NSObject {
    NSString*   m_strObjectId;
    NSString*   m_strFollowedUserName;
    BOOL        m_bFollowed;
    NSDate*     m_dateUpdated;
}

@property (nonatomic, assign) NSString*   m_strObjectId;
@property (nonatomic, assign) NSString*   m_strFollowedUserName;
@property (nonatomic) BOOL   m_bFollowed;
@property (nonatomic, assign) NSDate*   m_dateUpdated;

- (id) initWithObjectId:(NSString*)objid followedusername:(NSString*)followedusername followed:(BOOL)followed date:(NSDate*)updated;

@end