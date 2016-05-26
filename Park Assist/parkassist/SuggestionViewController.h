//
//  SuggestionViewController.h
//  parkassist
//
//  Created by     on 11/3/13.
//  Copyright (c) 2013 RUHE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSWebManager.h"
#import "JSWaiter.h"

@interface SuggestionViewController : UIViewController<UITextViewDelegate, UITextFieldDelegate>
{
    IBOutlet UITextView* txt_content;
    IBOutlet UITextField* txt_email;
    NSString* str_feedback;
}
@end
