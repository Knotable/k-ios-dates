//
//  GameOptionInfo.h
//  Sudoku
//
//  Created by Kwang on 11/05/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_IPHONE ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone" ] )
#define IS_IPOD   ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPod touch" ] )

enum CATEGORY_TYPE {
    CATEGORY_INTELLIGENCY = 0,
    CATEGORY_EXERCICIES,
    CATEGORY_FRIENDSHIP,
    CATEGORY_BEAUTY,
};
@interface GameUnit : NSObject {
    BOOL    m_bAutoLogin;
    BOOL    m_bLogin;
    BOOL    m_bShouldRedownloadData;
    BOOL    m_bLoadedChallengeList;
    int     m_nSelChallengeIndex;
    BOOL    m_bChangeFavorites;
    int     m_nSelCategory;
    
    NSMutableArray* m_arrayChallenges;
    NSMutableArray* m_arrayWallEntries;
    NSMutableArray* m_arrayPetLikeList;
    NSMutableArray* m_arrayCommentList;
    NSMutableArray* m_arrayProfileList;
    NSMutableArray* m_arrayFollowList;
    
    NSString*   m_strWallEntryObjectId;
    NSString*   m_strUserName;
    NSString*   m_strUserPassword;
    NSString*   m_strSelUserName;
    
    NSString*   m_strCountry;
    NSString*   m_strBreed;
}

@property (nonatomic) BOOL m_bAutoLogin;
@property (nonatomic) BOOL m_bLogin;
@property (nonatomic) BOOL m_bLoadedChallengeList;
@property (nonatomic) BOOL m_bChangeFavorites;
@property (nonatomic) BOOL m_bShouldRedownloadData;
@property (nonatomic, strong) NSMutableArray* m_arrayChallenges;
@property (nonatomic, strong) NSMutableArray* m_arrayWallEntries;
@property (nonatomic, strong) NSMutableArray* m_arrayPetLikeList;
@property (nonatomic, strong) NSMutableArray* m_arrayCommentList;
@property (nonatomic, strong) NSMutableArray* m_arrayProfileList;
@property (nonatomic, strong) NSMutableArray* m_arrayFollowList;
@property (nonatomic, strong) NSString* m_strWallEntryObjectId;
@property (nonatomic, strong) NSString* m_strUserName;
@property (nonatomic, strong) NSString* m_strUserPassword;
@property (nonatomic, strong) NSString* m_strCountry;
@property (nonatomic, strong) NSString* m_strBreed;
@property (nonatomic, readonly) NSString* m_strSelUserName;
@property (nonatomic) int m_nSelChallengeIndex;
@property (nonatomic) int m_nSelCategory;

-(void) loadData;
-(void) saveData;
-(void) loadWallEntries;

- (void) setSelUserName:(NSString*)name;
- (NSString*) getCategoryName:(int)type;

- (void) sortWallEntries;

- (NSString*) getRootDirPath;
- (NSString*) getSaveDataFilePath;
- (NSString*) getDataFileFullPath:(NSString*)filename;
- (BOOL) isExistFile:(NSString*)strFilePath;
- (void) removeFile:(NSString*)strFilePath;
- (NSString*) createImageFileName;
- (NSString*) createVideoFileName;
@end

extern GameUnit* g_GameUnit;
