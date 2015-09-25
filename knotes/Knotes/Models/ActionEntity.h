//
//  ActionEntity.h
//  Knotable
//
//  Created by Martin Ceperley on 7/9/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AccountEntity;

@interface ActionEntity : NSManagedObject

@property (nonatomic, retain) NSString * methodName;
@property (nonatomic, retain) NSData * parameters;
@property (nonatomic, retain) NSDate *dateCreated;
@property (nonatomic, retain) NSDate *dateSent;
@property (nonatomic, retain) NSDate *dateConfirmed;
@property (nonatomic) BOOL completed;
@property (nonatomic) BOOL sent;
@property (nonatomic, retain) NSData * result;
@property (nonatomic, retain) NSString * error;
@property (nonatomic) int32_t error_code;
@property (nonatomic) int32_t retriesLeft;
@property (nonatomic, retain) NSString *account_id;

@end
