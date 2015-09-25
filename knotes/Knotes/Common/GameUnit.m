//
//  GameOptionInfo.m
//  Sudoku
//
//  Created by Kwang on 11/05/23.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameUnit.h"
#import "ChallengeInfo.h"

GameUnit* g_GameUnit;

#define _FILE_SAVEDATA_     @"SaveData.plist"

@implementation GameUnit

@synthesize m_bLogin, m_bAutoLogin, m_bChangeFavorites;
@synthesize m_bLoadedChallengeList;
@synthesize m_nSelChallengeIndex;
@synthesize m_arrayChallenges;
@synthesize m_arrayWallEntries, m_arrayProfileList;
@synthesize m_arrayPetLikeList, m_arrayCommentList;
@synthesize m_strWallEntryObjectId, m_arrayFollowList;
@synthesize m_strUserName;
@synthesize m_strUserPassword;
@synthesize m_strSelUserName;
@synthesize m_bShouldRedownloadData;
@synthesize m_strBreed, m_strCountry, m_nSelCategory;

-(id) init {
	if ((self = [super init])) {
        m_bLogin = NO;
        m_bAutoLogin = NO;
        m_bChangeFavorites = NO;
        m_arrayChallenges = [[NSMutableArray alloc] init];
        m_arrayWallEntries = [[NSMutableArray alloc] init];
        m_arrayPetLikeList = [[NSMutableArray alloc] init];
        m_arrayCommentList = [[NSMutableArray alloc] init];
        m_arrayProfileList = [[NSMutableArray alloc] init];
        m_arrayFollowList = [[NSMutableArray alloc] init];
        m_nSelChallengeIndex = 0;
        m_bLoadedChallengeList = NO;
        m_bShouldRedownloadData = NO;
		[self loadData];
	}
	return self;
}
-(void) loadData {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL bFirst = [defaults boolForKey:@"FirstStartApp"];
	if (!bFirst) {
	}
	else {
        m_strUserName = [[NSString alloc] initWithString:[defaults stringForKey:@"username"]];
        m_strUserPassword = [[NSString alloc] initWithString:[defaults stringForKey:@"userpassword"]];
        m_bAutoLogin = [defaults boolForKey:@"login"];
//        m_bEnableBgm = [defaults boolForKey:@"EnableBgm"];
//        m_bEnableSe = [defaults boolForKey:@"EnableSe"];
//        m_fBgmVolume = [defaults floatForKey:@"BgmVolume"];
//        m_fSeVolume = [defaults floatForKey:@"SeVolume"];
	}
//    [self loadChallenges];
//    [self loadWallEntries];
}
-(void) saveData {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:YES forKey:@"FirstStartApp"];
    [defaults setBool:m_bLogin forKey:@"login"];
    [defaults setObject:m_strUserName forKey:@"username"];
    [defaults setObject:m_strUserPassword forKey:@"userpassword"];
//    [defaults setBool:m_bEnableBgm forKey:@"EnableBgm"];
//    [defaults setBool:m_bEnableSe forKey:@"EnableSe"];
//    [defaults setFloat:m_fBgmVolume forKey:@"BgmVolume"];
//    [defaults setFloat:m_fSeVolume forKey:@"SeVolume"];
}

//-(void) dealloc {
//    [m_arrayChallenges release];
//    [m_arrayWallEntries release];
//    [m_arrayCommentList release];
//    [m_arrayPetLikeList release];
//    [m_arrayProfileList release];
//    [m_arrayFollowList release];
//    [m_strWallEntryObjectId release];
//    [m_strUserName release];
//    [m_strUserPassword release];
//    [m_strSelUserName release];
//	[super dealloc];
//}
//
-(void) loadWallEntries {
//    NSString* strPath = [[NSBundle mainBundle] pathForResource:@"WallList" ofType:@"plist"];
//    NSDictionary* dic = [NSDictionary dictionaryWithContentsOfFile:strPath];
//    NSArray* array = [dic objectForKey:@"WallList"];
//    for (NSDictionary* obj in array) {
//        WallEntryInfo* wall = [[WallEntryInfo alloc] initWithPlistDictionary:obj];
//        [m_arrayWallEntries addObject:wall];
//        [wall release];
//    }
}
- (void) setSelUserName:(NSString*)name {
    m_strSelUserName = [[NSString alloc] initWithString:name];
}
- (void) sortWallEntries {
    NSArray* array = [NSArray arrayWithArray:m_arrayWallEntries];
    [m_arrayWallEntries removeAllObjects];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"m_dateUpdated" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [array sortedArrayUsingDescriptors:sortDescriptors];
    [m_arrayWallEntries setArray:sortedArray];
}
- (NSString*) getCategoryName:(int)type {
    NSArray* array = [NSArray arrayWithObjects:@"Inteligence", @"Excercices", @"Friendship", @"Beauty", nil];
    return [array objectAtIndex:type];
}
- (NSString*) createImageFileName {
    NSDate* date = [NSDate date];
    NSTimeInterval tm = [date timeIntervalSince1970];
    int nId = (int)tm;
    NSString* str;
    NSString* strPath;
    do {
        int nRand = arc4random()%100;
        str = [NSString stringWithFormat:@"%d-%d.jpg", nId, nRand];
        strPath = [self getDataFileFullPath:str];
    } while ([self isExistFile:strPath] == YES);
    return str;
}
- (NSString*) createVideoFileName {
    NSDate* date = [NSDate date];
    NSTimeInterval tm = [date timeIntervalSince1970];
    int nId = (int)tm;
    NSString* str;
    NSString* strPath;
    do {
        int nRand = arc4random()%100;
        str = [NSString stringWithFormat:@"%d-%d.mov", nId, nRand];
        strPath = [self getDataFileFullPath:str];
    } while ([self isExistFile:strPath] == YES);
    return str;
}
- (NSString*) getRootDirPath {
    return NSTemporaryDirectory();
}
- (NSString*) getSaveDataFilePath {
    return [[self getRootDirPath] stringByAppendingPathComponent:_FILE_SAVEDATA_];
}

- (NSString*) getDataFileFullPath:(NSString*)filename {
    return [[self getRootDirPath] stringByAppendingPathComponent:filename];
}
- (BOOL) isExistFile:(NSString*)strFilePath {
    if(![[NSFileManager defaultManager] fileExistsAtPath:strFilePath])
        return NO;
    return YES;
}
- (void) removeFile:(NSString*)strFilePath {
    if ([self isExistFile:strFilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:strFilePath error:nil];
    }
}

@end
