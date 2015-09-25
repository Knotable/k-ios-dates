//
//  CEditCandContactItem.h
//  Knotable
//
//  Created by wuli on 11/12/14.
//
//

#import <Foundation/Foundation.h>


#import "BI_GridViewCell.h"
#import "GBPathImageView.h"
#import "ContactsEntity.h"
@interface CEditCandContactItem : BI_GridViewCell
@property (nonatomic, strong)ContactsEntity *entity;
@end