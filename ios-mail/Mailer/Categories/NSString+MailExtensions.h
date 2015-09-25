//
//  NSString+MailExtensions.h
//  Mailer
//
//  Created by Martin Ceperley on 10/17/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import <Foundation/Foundation.h>

struct TextCount {
    NSUInteger character;
    NSUInteger word;
};
typedef struct TextCount TextCount;

@interface NSString (MailExtensions)

- (NSString *) md5;

- (TextCount) characterAndWordCounts;

@end
