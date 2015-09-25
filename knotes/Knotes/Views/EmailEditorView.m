//
//  EmailEditorView.m
//  Knotable
//
//  Created by Martin Ceperley on 1/10/14.
//
//

#import "EmailEditorView.h"
#import "ContactsEntity.h"
#import "NSString+Knotes.h"
#import <Masonry/View+MASAdditions.h>

@interface EmailEditorView()

@property (nonatomic, strong) NSMutableArray    *emails;
@property (nonatomic, strong) NSMutableArray    *emailLabels;
@property (nonatomic, strong) UITextField       *addEmailField;
@property (nonatomic, strong) NSMutableArray    *deleteEmailButtons;

@end

@implementation EmailEditorView

- (void)commonInit {
    _deletedEmails = [[NSMutableArray alloc] init];
    _addedEmails = [[NSMutableArray alloc] init];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"EmailEditorView initWithFrame");
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib {
    NSLog(@"EmailEditorView awake from nib");
    [self commonInit];
}

- (void)setContact:(ContactsEntity *)contact
{
    _contact = contact;
    _emails = [[_contact.email componentsSeparatedByString:@","] mutableCopy];

    [self constructViews];
}

- (void)constructViews {
    for(UIView *view in self.subviews){
        [view removeFromSuperview];
    }

    _emailLabels = [[NSMutableArray alloc] init];
    _deleteEmailButtons = [[NSMutableArray alloc] init];


    UIView *aboveView = nil;

    for(NSString *email in _emails){
        if(email.length == 0) continue;

        UILabel *emailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        emailLabel.text = email;
        emailLabel.backgroundColor = [UIColor clearColor];
        emailLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];

        [self addSubview:emailLabel];
        [emailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            if(!aboveView){
                make.top.equalTo(@0.0);
            } else {
                make.top.equalTo(aboveView.mas_bottom).with.offset(12.0);
            }

            make.left.equalTo(@0.0);
            //make.right.lessThanOrEqualTo(@0.0);
            make.right.equalTo(@0.0);

        }];

        [_emailLabels addObject:emailLabel];

        if(_editable && _emails.count > 1){
            UIButton *deleteEmailButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [deleteEmailButton setTitle:@"x" forState:UIControlStateNormal];
            [deleteEmailButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [deleteEmailButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
            deleteEmailButton.backgroundColor = [UIColor clearColor];
            [deleteEmailButton addTarget:self action:@selector(deleteEmail:) forControlEvents:UIControlEventTouchUpInside];

            [self addSubview:deleteEmailButton];

            [deleteEmailButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(emailLabel).with.offset(-4.0);
                make.centerY.equalTo(emailLabel).with.offset(0.0);
                make.size.equalTo(@25.0);
            }];

            [_deleteEmailButtons addObject:deleteEmailButton];
        }

        aboveView = emailLabel;
    }

    if(_editable){
        _addEmailField = [[UITextField alloc] initWithFrame:CGRectZero];
        _addEmailField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
        _addEmailField.placeholder = _emails.count > 0 ? @"Add another email" : @"Add an email";
        _addEmailField.borderStyle = UITextBorderStyleRoundedRect;
        _addEmailField.delegate = self;
        _addEmailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _addEmailField.autocorrectionType = UITextAutocorrectionTypeNo;
        _addEmailField.keyboardType = UIKeyboardTypeEmailAddress;
        _addEmailField.spellCheckingType = UITextSpellCheckingTypeNo;

        [self addSubview:_addEmailField];

        [_addEmailField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0.0);
            make.right.equalTo(@0.0);
            if(aboveView){
                make.top.equalTo(aboveView.mas_bottom).with.offset(8.0);
            } else {
                make.top.equalTo(@0.0);
            }

        }];

        aboveView = _addEmailField;
    }

    if(aboveView){
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(aboveView);
        }];
    }

}

- (void)saveNewEmail
{
    NSString *newEmail = _addEmailField.text;

    if(!newEmail || newEmail.length == 0){
        return;
    }

    NSLog(@"new email: \"%@\"", newEmail);

    if(![newEmail isValidEmail]){
        _addEmailField.text = @"";
        //[_addEmailField resignFirstResponder];

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Email"
                                                            message:@"Please enter a valid email"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    if([_emails containsObject:newEmail]){
        _addEmailField.text = @"";
        //[_addEmailField resignFirstResponder];

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Already present"
                                                            message:@"Please enter a new email"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;

    }

    _addEmailField.text = @"";

    [_emails addObject:newEmail];

    [(NSMutableArray *)_addedEmails addObject:newEmail];

    [self constructViews];

}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if(self.textFieldDelegate && [self.textFieldDelegate respondsToSelector:@selector(textFieldDidBeginEditing:)]){
        [self.textFieldDelegate textFieldDidBeginEditing:textField];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"textFieldDidEndEditing");
    [self saveNewEmail];

    if(self.textFieldDelegate && [self.textFieldDelegate respondsToSelector:@selector(textFieldDidEndEditing:)]){
        [self.textFieldDelegate textFieldDidEndEditing:textField];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textFieldShouldReturn");
    [self saveNewEmail];
    return YES;
}

- (void)deleteEmail:(UIButton *)deleteButton
{
    NSAssert(_emails.count > 1, @"Cant delete the last email!");

    int emailIndex = (int)[_deleteEmailButtons indexOfObject:deleteButton];

    UILabel *emailLabel = _emailLabels[emailIndex];
    NSString *email = _emails[emailIndex];

    NSLog(@"Deleting email %@ at index %d label: %@ button: %@", email, emailIndex, emailLabel, deleteButton);

    [_emails removeObjectAtIndex:emailIndex];

    [(NSMutableArray *)_deletedEmails addObject:email];

    [self constructViews];
}


@end
