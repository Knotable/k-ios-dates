//
//  CachedUrlsEntity.h
//  Knotable
//
//  Created by wuli on 9/1/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CachedUrlsEntity : NSManagedObject

@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * embedlyUrl;

@end
