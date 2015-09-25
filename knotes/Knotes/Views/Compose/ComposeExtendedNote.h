//
//  ComposeExtendedNote.h
//  Knotable
//
//  Created by Donald Pae on 1/26/14.
//
//

#import "ComposeNewNote.h"

@interface ComposeExtendedNote : ComposeNewNote {
    BOOL keynoteSelected;
}

@property (nonatomic) BOOL keynoteSelected;
@property (nonatomic, assign) BOOL showKeynote;

@end
