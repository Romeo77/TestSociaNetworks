//
//  UIMessagesHelper.h
//  TestSocialNetwork
//
//  Created by Roman on 6/2/15.
//  Copyright (c) 2015 Roman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIMessagesHelper : NSObject
+(void) showError:(NSError *)error withMessage:(NSString *)message;
+ (void) showMessage :(NSString *)message;
@end

#define UIErrReturn(x) { if (error) {\
[UIMessagesHelper showError:error withMessage:(x)];\
return;\
}}

#define UIMsg(x){[UIMessagesHelper showMessage:(x)];}
