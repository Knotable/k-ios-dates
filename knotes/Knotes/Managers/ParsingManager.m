//
//  ParsingManager.m
//  Knotable
//
//  Created by Martin Ceperley on 5/9/14.
//
//

#import "ParsingManager.h"

@implementation ParsingManager

+ (ParsingManager *)sharedInstance
{
    static ParsingManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[ParsingManager alloc] init];
    });
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if(self){
        
        _htmlEscapeEntities = @{
                                    @"nbsp" : @" ",
                                    @"lt" : @"<",
                                    @"gt" : @">",
                                    @"amp" : @"&",
                                    @"quot" : @"\"",
                                    @"#34" : @"\"",
                                    @"#39" : @"'",
                                    };


    }
    return self;
}

@end
