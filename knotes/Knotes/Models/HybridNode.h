//
// Created by Martin Ceperley on 5/8/14.
//

#import <Foundation/Foundation.h>


@interface HybridNode : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *html;
@property (nonatomic, assign) BOOL isHTML;

@property (nonatomic, assign) NSUInteger htmlIndex;
@property (nonatomic, assign) NSUInteger textIndex;

-(id)initWithText:(NSString *)text;
-(id)initWithHTML:(NSString *)html atEdge:(BOOL)atEdge;
-(id)initWithEscapeSequence:(NSString *)sequence;

@end
