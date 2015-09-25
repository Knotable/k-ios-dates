//
//  ProfileInfo.m
//  ContactSync
//
//  Created by Apple on 13-4-17.
//  Copyright (c) 2013年 Apple. All rights reserved.
//

#import "UserInfo.h"
#import "GameUnit.h"

@implementation UserInfo

@synthesize m_strEmail, m_strPassword, m_strPhone, m_strProfile, m_strName, m_strImageFileName, m_strRegisterId;
@synthesize m_nGender;

- (void) initialize {
    m_strRegisterId = nil;
    m_strProfile = nil;
    m_strEmail = nil;
    m_strPassword = nil;
    m_strName = nil;
    m_strPhone = nil;
    m_strImageFileName = nil;
    m_nGender = 0;
}
- (void) setUserInfo:(NSString*)registerId profile:(NSString*)profile email:(NSString*)email password:(NSString*)password name:(NSString*)name phone:(NSString*)phone gender:(int)gender {
    if (registerId)
        m_strRegisterId = [[NSString alloc] initWithString:registerId];
    if (profile)
        m_strProfile = [[NSString alloc] initWithString:profile];
    if (email)
        m_strEmail = [[NSString alloc] initWithString:email];
    if (password)
        m_strPassword = [[NSString alloc] initWithString:password];
    if (name)
        m_strName = [[NSString alloc] initWithString:name];
    if (phone)
        m_strPhone = [[NSString alloc] initWithString:phone];
    m_nGender = gender;
}

- (void) setImageFileName:(NSString*)strFile {
    if (strFile)
        m_strImageFileName = [[NSString alloc] initWithString:strFile];
}
- (NSString*) getGenderString {
    if (m_nGender == GENDER_FEMALE)
        return @"Female";
    else
        return @"Male";
}

- (BOOL) isGetImage
{
    if (m_strImageFileName == nil)
        return NO;
    
    NSString* strPath = [g_GameUnit getDataFileFullPath:m_strImageFileName];
    
    return [g_GameUnit isExistFile:strPath];
}

@end


