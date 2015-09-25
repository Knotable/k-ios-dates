//
//  CUserInfoView.m
//  Knotable
//
//  Created by Agustin Guerra on 8/27/14.
//
//

#import "CUserInfoView.h"

#import "ContactManager.h"
#import "DesignManager.h"
#import "ThreadItemManager.h"
#import "ContactsEntity.h"

@interface CUserInfoView()

@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) NSMutableArray *editors;

@end

@implementation CUserInfoView

- (id)init {
    self = [super init];
    
    if (self) {
        self.didSetupConstraints = NO;
        
        self.nameTextView = [[UILabel alloc] init];
        self.nameTextView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
        self.nameTextView.userInteractionEnabled = NO;
        self.nameTextView.minimumScaleFactor = 0.5f;
        self.nameTextView.adjustsFontSizeToFitWidth = YES;
        self.nameTextView.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.nameTextView];
        
        self.dateTextView = [[UILabel alloc] init];
        self.dateTextView.textColor = [DesignManager knoteUsernameColor];;
        self.dateTextView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
        self.dateTextView.userInteractionEnabled = NO;
        self.dateTextView.adjustsFontSizeToFitWidth = YES;
        self.dateTextView.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.dateTextView];
    }
    
    return self;
}

- (void)updateConstraints {
    
    if (!self.didSetupConstraints) {
        [self.nameTextView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(10);
            make.width.equalTo(@130);
            make.left.equalTo(self);
        }];
        
        [self.dateTextView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameTextView);
            make.width.equalTo(@95);
            make.right.equalTo(@-20);
        }];
        
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.nameTextView);
        }];
        
        self.didSetupConstraints = YES;
    }
    
    [super updateConstraints];
}

- (void)setMessage:(MessageEntity *)message {
    _message = message;
    ContactsEntity *contact = message.contact;
    
    NSString *realName = @"bgcolor0";
    NSString *userName = @"";
    
    NSArray *editors = nil;
    if (!contact) {//find in local
        if (message.account_id) {
            NSManagedObjectContext *backgroundMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            [backgroundMOC setPersistentStoreCoordinator:[glbAppdel.managedObjectContext persistentStoreCoordinator]];
            contact = [ContactsEntity MR_findFirstByAttribute:@"account_id" withValue:message.account_id inContext:backgroundMOC];
            if (contact) {
                contact= (ContactsEntity *)[glbAppdel.managedObjectContext existingObjectWithID:[contact objectID] error:nil];
            }
        }
    }
    if (!contact)
    {
        //find in server
        __weak __typeof(&*self)weakSelf = self;
        
        [ContactManager findContactFromServerByAccountId:message.account_id
                                          withNofication:nil withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData) {
            if (weakSelf != nil)
            {
                [weakSelf setMessage:message];
            }
        }];
    }
    
    if (message.editors) {
        editors = [NSKeyedUnarchiver unarchiveObjectWithData:message.editors];
    }
    
    if (editors && [editors count] > 1) {
        self.editors = [NSMutableArray new];
        NSMutableArray *contacts = [NSMutableArray new];
        for (NSDictionary *dic in editors) {
            ContactsEntity *editors_contact = [ContactsEntity MR_findFirstByAttribute:@"mainEmail" withValue:dic[@"email"]];
            if (!editors_contact) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email like[cd] %@",[NSString stringWithFormat:@"*%@*",dic[@"email"]]];//查询条件
                editors_contact = [ContactsEntity MR_findFirstWithPredicate:predicate];
            }
            
            if (editors_contact) {
                if ([editors_contact isFault]) {
                    [editors_contact MR_refresh];
                }
                [contacts addObject:editors_contact.name];
                [self.editors addObject:editors_contact];
            } else {
                if ([dic objectForKey:@"email"]) {
                    [ContactManager findContactFromServerByEmail:dic[@"email"]];
                    [contacts addObject:[[dic[@"email"] componentsSeparatedByString:@"@"] firstObject]];
                }
            }
        }
        
        realName = [contacts componentsJoinedByString:@", "];
    } else {
        if (contact) {
            if ([contact isFault]) {
                [contact MR_refresh];
            }
            realName = [NSString stringWithFormat:@"%@",contact.name];
            userName = contact.username;
        } else {
            NSString *subStr = message.name;
            if (!subStr || [subStr length]<=1) {
                subStr = message.email;
            }
            if (subStr || [subStr length]<1) {
                subStr = @"X";//check....
            }
            
            realName = [NSString stringWithFormat:@"%@",message.name];
            userName = message.name;
        }
        
    }
    
    self.nameTextView.text = realName;
    
    self.dateTextView.text = [[ThreadItemManager sharedInstance] getDateTimeIndicate:message.time];
    
    [self setNeedsUpdateConstraints];
}

@end
