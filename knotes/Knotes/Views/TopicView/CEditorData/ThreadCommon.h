//
//  ThreadCommon.h
//  Knotable
//
//  Created by backup on 14-2-25.
//
//

#import <Foundation/Foundation.h>
typedef enum tagCItemType
{
    C_KNOTE,
    C_KEYKNOTE,
    C_DATE,
    C_VOTE,
    C_LIST,
    C_LOCK,
    C_MESSAGE,
    C_REPlYS,
    C_HEADER,
    C_NEW_COMMENT,
    C_MESSAGE_TO_KNOTE//local use
} CItemType;
typedef enum tagCItemOpType
{
    C_OP_NONE,
    C_OP_LIKE,
    C_OP_DELETE,
    C_OP_PINNED
} CItemOpType;

typedef enum _btnOperatorTag
{
    btnOperDelete,
    btnOperCopy,
    btnOperProfile,
}btnOperatorTag;


typedef enum  // For Analytics
{
    newVote,
    changeVote,
    check
} VoteModificationType;
