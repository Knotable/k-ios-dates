//
//  CEditVoteInfo.m
//  RevealControllerProject
//
//  Created by backup on 13-11-8.
//
//

#import "CEditVoteInfo.h"

@implementation CEditVoteInfo

- (id)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        [self setByDic:dic];
    }
    return self;
}

- (void)setByDic:(NSDictionary *)dic
{
    NSNumber *flag = dic[@"checked"];
    if (![flag isKindOfClass:[NSNull class]]) {
        self.checked = [flag boolValue];
    } else {
        self.checked = NO;
    }
    self.name = dic[@"name"];
    self.num = [dic[@"num"] integerValue];
    self.voters = dic[@"voters"];
}

- (NSDictionary *)dictionary
{
    if (!self.voters) {
        self.voters = [NSArray array];
    }
    if (self.type == C_LIST) {
        return [NSDictionary dictionaryWithObjectsAndKeys:
                [NSNumber numberWithBool:self.checked], @"checked",
                self.name, @"name",
                [NSNumber numberWithInt:(int)self.num], @"num",
                self.voters, @"voters",
                nil];
    } else {
        return [NSDictionary dictionaryWithObjectsAndKeys:
                self.name, @"name",
                [NSNumber numberWithInt:(int)self.num], @"num",
                self.voters, @"voters",
                nil];
    }

}

-(NSString *)description
{
    return [NSString stringWithFormat:@"checked:%d,name:%@,num:%d,\nvoters:%@",self.checked,self.name,(int)self.num,self.voters];
}

@end
