//
//  TwitterSingUp.m
//  TestSocialNetwork
//
//  Created by Roman on 6/4/15.
//  Copyright (c) 2015 Roman. All rights reserved.
//

#import "TwitterSingUp.h"

@implementation TwitterSingUp

+ (instancetype) manager
{
    static TwitterSingUp *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [TwitterSingUp new];
    });
    
    return  manager;
}

- (void) initTwitterSingUp
{
    HUDSHOW
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        UIErrReturn (@"You cancelled the Twitter login")
        HUDHIDE
        if(!user){
            return;
        }
        else if (user.isNew) {
            UIMsg(@"You signed up and logged in through Twitter!");
            [[NSNotificationCenter defaultCenter]postNotificationName:notificationLogin object:nil];
            
            NSDictionary *dictionaryFromTwitterApi = [self getDictionaryFromTwitterApi:[[PFTwitterUtils twitter] userId]];
            [PFUser currentUser][@"image"] = [self wrapImageToPFfile:[dictionaryFromTwitterApi objectForKey:@"profile_image_url"]];
            
            NSArray *userName = [[dictionaryFromTwitterApi objectForKey:@"name"] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            [[PFUser currentUser] setObject:userName[0]forKey:@"firstname"];
            if(userName.count > 1)
                [[PFUser currentUser] setObject:userName[1]forKey:@"secondname"];
            [[PFUser currentUser] saveInBackground];
        } else {
            [[NSNotificationCenter defaultCenter]postNotificationName:notificationLogin object:nil];
        }
    }];
}

- (NSDictionary*) getDictionaryFromTwitterApi:(NSString*) userId
{
    NSString * requestString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/show.json?user_id=%@",
                                userId];
    NSURL *verify = [NSURL URLWithString:requestString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
    [[PFTwitterUtils twitter] signRequest:request];
    NSURLResponse *response = nil;
    NSError* error;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    return  result;
}

- (PFFile *) wrapImageToPFfile :(NSString*) userImageURL
{
    NSURL *url = [NSURL URLWithString:userImageURL];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *img = [[UIImage alloc] initWithData:data];
    NSData *imageData = UIImagePNGRepresentation(img);
    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
    return imageFile;
}

@end
