//
//  FacebookSingUp.m
//  TestSocialNetwork
//
//  Created by Roman on 6/5/15.
//  Copyright (c) 2015 Roman. All rights reserved.
//

#import "FacebookSingUp.h"

@implementation FacebookSingUp

+ (instancetype) manager
{
    static FacebookSingUp *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [FacebookSingUp new];
    });    
    return  manager;
}

- (void) initFacebookSingUp
{
    NSArray *permissionsArray = @[ @"public_profile", @"user_birthday", @"user_about_me", @"email"];
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error)
     {
         if(!user)
         {
             return;
         }
         UIErrReturn (@"You cancelled the Facebook login")
         if (user.isNew) {
             HUDSHOW
             UIMsg(@"You signed up and logged in through Facebook!");
             [[NSNotificationCenter defaultCenter]postNotificationName:notificationLogin object:nil];
             [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *FBuser, NSError *error) {
                 UIErrReturn (@"Something wrong")
                 
                 [PFUser currentUser][@"image"] = [self wrapImageToPFfile:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [FBuser objectID]]];
                 [[PFUser currentUser] setObject:[FBuser objectForKey:@"email"]forKey:@"email"];
                 [[PFUser currentUser] setObject:[FBuser objectForKey:@"first_name"]forKey:@"firstname"];
                 [[PFUser currentUser] setObject:[FBuser objectForKey:@"last_name"]forKey:@"secondname"];
                 [[PFUser currentUser] setObject:[FBuser objectForKey:@"birthday"]forKey:@"birthday"];
                 [[PFUser currentUser] saveInBackground];
                 HUDHIDE
             }];
         }
         else
         {
             [[NSNotificationCenter defaultCenter]postNotificationName:notificationLogin object:nil];
         }
     }];
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
