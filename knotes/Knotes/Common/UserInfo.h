//
//  ProfileInfo.h
//  ContactSync
//
//  Created by Apple on 13-4-17.
//  Copyright (c) 2013年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>

enum GENDER_TYPE {
    GENDER_FEMALE = 0,
    GENDER_MALE
};
@interface UserInfo : NSObject {
    NSString*   m_strRegisterId;
    NSString*   m_strProfile;
    NSString*   m_strEmail;
    NSString*   m_strPassword;
    NSString*   m_strName;
    NSString*   m_strPhone;
    int     m_nGender;
    NSString*   m_strImageFileName;
}

@property (nonatomic, strong)NSString*   m_strRegisterId;
@property (nonatomic, strong)NSString*   m_strProfile;
@property (nonatomic, strong)NSString*   m_strEmail;
@property (nonatomic, strong)NSString*   m_strPassword;
@property (nonatomic, strong)NSString*   m_strName;
@property (nonatomic, strong)NSString*   m_strPhone;
@property (nonatomic, strong)NSString*   m_strImageFileName;
@property (nonatomic)int m_nGender;

- (void) initialize;
- (void) setUserInfo:(NSString*)registerId profile:(NSString*)profile email:(NSString*)email password:(NSString*)password name:(NSString*)name phone:(NSString*)phone gender:(int)gender;
- (void) setImageFileName:(NSString*)strFile;

- (NSString*) getGenderString;
- (BOOL) isGetImage;

@end

