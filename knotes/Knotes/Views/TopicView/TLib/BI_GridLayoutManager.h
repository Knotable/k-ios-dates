//
//  BI_GridLayoutManager.h
//  BaiduIMLib
//
//  Created by backup on 11-10-10.
//  Copyright 2011年 backup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BI_GridLayout.h"

typedef enum {
    kGridLayoutStyleDefault,
    kGridLayoutStyleFilter,
    kGridLayoutStyleFloating,
    kGridLayoutStyleMoreCand,
    kGridLayoutStyleMoreCandSmart,
    kGridLayoutStyleImageLibrary,
    kGridLayoutStyleToolBar,
}GridLayoutStyle;

@interface BI_GridLayoutManager : NSObject {
    
}

+ (BI_GridLayout *)layoutWithStyle:(GridLayoutStyle)style;

@end

@interface BI_FilterViewLayout : BI_GridLayout {

}
@end

@interface BI_CandidateBarLayout : BI_GridLayout {

}
@end

@interface BI_MoreCandViewLayout : BI_GridLayout {
    
}
@end

@interface BI_MoreCandViewSmartLayout : BI_GridLayout {
    
}
@end


@interface BI_ImageLibraryViewLayout : BI_GridLayout {
    
}
@end

@interface BI_CandidateToolBarLayout : BI_GridLayout {
    
}
@end
