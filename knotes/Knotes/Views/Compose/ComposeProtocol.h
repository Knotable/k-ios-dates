//
//  ComposeProtocol.h
//  Knotable
//
//  Created by backup on 14-1-3.
//
//

#import <Foundation/Foundation.h>

@protocol ComposeProtocol
@required
- (void)setTitlePlaceHold:(NSString *)str;
- (void)setTitleContent:(NSString *)str;
- (void)setCotent:(id)content;
- (id)getCotent;
- (id)getTitle;
@end

