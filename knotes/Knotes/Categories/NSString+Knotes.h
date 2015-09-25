//
//  NSString+Knotable.h
//  Knotable
//
//  Created by Martin Ceperley on 12/10/13.
//
//

#import <Foundation/Foundation.h>

@interface NSString (Knotable)

- (NSString *) md5;

- (NSString *) trimmed;

- (BOOL)startsWith:(NSString *)string;

- (BOOL) isValidEmail;

- (BOOL) isPhoneNumber;

- (BOOL) isValidURL;

- (NSString *)noPrefix:(NSString *)prefix;


///---------------
/// @name Trimming
///---------------

/**
 Returns a new string by trimming leading and trailing characters in a given `NSCharacterSet`.
 
 @param characterSet Character set to trim characters
 
 @return A new string by trimming leading and trailing characters in `characterSet`
 */
- (NSString *)stringByTrimmingLeadingAndTrailingCharactersInSet:(NSCharacterSet *)characterSet;

/**
 Returns a new string by trimming leading and trailing whitespace and newline characters.
 
 @return A new string by trimming leading and trailing whitespace and newline characters
 */
- (NSString *)stringByTrimmingLeadingAndTrailingWhitespaceAndNewlineCharacters;

/**
 Returns a new string by trimming leading characters in a given `NSCharacterSet`.
 
 @param characterSet Character set to trim characters
 
 @return A new string by trimming leading characters in `characterSet`
 */
- (NSString *)stringByTrimmingLeadingCharactersInSet:(NSCharacterSet *)characterSet;

/**
 Returns a new string by trimming leading whitespace and newline characters.
 
 @return A new string by trimming leading whitespace and newline characters
 */
- (NSString *)stringByTrimmingLeadingWhitespaceAndNewlineCharacters;

/**
 Returns a new string by trimming trailing characters in a given `NSCharacterSet`.
 
 @param characterSet Character set to trim characters
 
 @return A new string by trimming trailing characters in `characterSet`
 */
- (NSString *)stringByTrimmingTrailingCharactersInSet:(NSCharacterSet *)characterSet;

/**
 Returns a new string by trimming trailing whitespace and newline characters.
 
 @return A new string by trimming trailing whitespace and newline characters
 */
- (NSString *)stringByTrimmingTrailingWhitespaceAndNewlineCharacters;



#pragma mark - Knotable
- (NSArray*) knotableTitleAndContent;
- (NSString*) planTitle;
@end
