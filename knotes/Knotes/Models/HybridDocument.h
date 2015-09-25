//
//  HybridDocument.h
//  Knotable
//
//  Created by Martin Ceperley on 5/8/14.
//
//
@class HybridNode;

@interface HybridDocument : NSObject <NSCoding>


@property (nonatomic, readonly) NSString *text;
@property (nonatomic, strong) NSString *documentHTML;
@property (nonatomic, readonly) NSString *documentHash;

- (id)initWithHTML:(NSString *)documentHTML;

- (HybridNode *)nodeForTextIndex:(NSUInteger)textIndex;

- (void)changeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)changeTextInRange:(NSRange)range replacementText:(NSString *)text deleteEmptyTags:(BOOL)deleteEmptyTags;

@end
