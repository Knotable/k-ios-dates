//
//  EmailEditorView.h
//  Knotable
//
//  Created by Martin Ceperley on 1/10/14.
//
//



@class ContactsEntity;

@interface EmailEditorView : UIView <UITextFieldDelegate>

@property (nonatomic, strong) ContactsEntity *contact;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, weak) id<UITextFieldDelegate> textFieldDelegate;
@property (nonatomic, readonly) NSArray *deletedEmails;
@property (nonatomic, readonly) NSArray *addedEmails;

@end
