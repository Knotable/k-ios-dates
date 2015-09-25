//
//  ParsingManager.h
//  Knotable
//
//  Created by Martin Ceperley on 5/9/14.
//
//

#import <Foundation/Foundation.h>

@interface ParsingManager : NSObject

@property (nonatomic, readonly) NSDictionary *htmlEscapeEntities;

+ (ParsingManager *)sharedInstance;



@end
