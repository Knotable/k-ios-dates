//
//  TextUtil.h
//  Knotable
//
//  Created by wuli on 14-4-3.
//
//

#import <Foundation/Foundation.h>
#import "Singleton.h"

@interface TextUtil : NSObject

SYNTHESIZE_SINGLETON_FOR_HEADER(TextUtil);

- (CGSize)getTextViewSize:(NSAttributedString *)text withWidth:(CGFloat)width;
- (CGSize)getTextViewSize:(NSAttributedString *)text withWidth:(CGFloat)width andMaximumNumberOfLines:(int)maximumNumberOfLines;

@end
