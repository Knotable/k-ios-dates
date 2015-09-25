//
//  UserEntity.m
//  RevealControllerProject
//
//  Created by backup on 13-11-16.
//
//

#import "UserEntity.h"
#import "FXKeychain.h"


@implementation UserEntity

@dynamic uid;
@dynamic name;
@dynamic email;
@dynamic user_id;
@dynamic contact;
@dynamic logout;
- (NSString *)getFirstEmail
{
    if (!self.email || self.email.length == 0) {
        return @"";
    }
    return [[self.email componentsSeparatedByString:@","] firstObject];
}

- (void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues
{
    NSDictionary *attributes = [[self entity] attributesByName];
    for (NSString *attribute in attributes)
    {
        id value = nil;
        if([attribute isEqualToString:@"email"]) {
            value = [keyedValues objectForKey:@"emails"];
            NSMutableString *emails = [[NSMutableString alloc] initWithCapacity:2];
            for (int i = 0; i<[value count]; i++ ) {
                if( i > 0 ) {
                    [emails appendString:@","];
                }
                
                [emails appendString:[[value objectAtIndex:i] objectForKey:@"address"]];
            }
            value = emails;
        } else if ([attribute isEqualToString:@"user_id"]) {
            value = keyedValues[@"_id"];
        } else if ([attribute isEqualToString:@"name"]) {
            value = keyedValues[@"username"];
        }
        NSAttributeType attributeType = [[attributes objectForKey:attribute] attributeType];
        if ((attributeType == NSStringAttributeType) && ([value isKindOfClass:[NSNumber class]])) {
            value = [value stringValue];
        } else if (((attributeType == NSInteger16AttributeType) || (attributeType == NSInteger32AttributeType) || (attributeType == NSInteger64AttributeType) || (attributeType == NSBooleanAttributeType)) && ([value isKindOfClass:[NSString class]])) {
            value = [NSNumber numberWithInteger:[value integerValue]];
        } else if ((attributeType == NSFloatAttributeType) &&  ([value isKindOfClass:[NSString class]])) {
            value = [NSNumber numberWithDouble:[value doubleValue]];
        } else if ((attributeType == NSDateAttributeType) && ([value isKindOfClass:[NSString class]])) {
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm:ss"];
            value = [dateFormatter dateFromString:value];
        }
        [self setValue:value forKey:attribute];
    }
    self.logout = @(NO);
}


- (NSString *)password
{
    if (_password != nil) {
        return _password;
    }
    _password = [[[FXKeychain defaultKeychain] objectForKey:self.user_id] copy];
    return _password;
}


- (void)setPassword:(NSString *)password
{
    _password = [password copy];
    [[FXKeychain defaultKeychain] setObject:password forKey:self.user_id];
}


@end
