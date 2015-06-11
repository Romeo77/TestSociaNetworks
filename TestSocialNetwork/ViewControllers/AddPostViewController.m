//
//  AddPostViewController.m
//  TestSocialNetwork
//
//  Created by Roman on 6/8/15.
//  Copyright (c) 2015 Roman. All rights reserved.
//

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#import "AddPostViewController.h"

@interface AddPostViewController ()<UITextFieldDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnSave;

@property (strong, nonatomic) NSString *located;
@property (nonatomic) CLLocationManager *locationManager;

@end

@implementation AddPostViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLocation];
    _imageView.image = _imagePost;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (IBAction)btnSaveTapped:(id)sender
{
    HUDSHOW
    NSData *imageData = UIImagePNGRepresentation(_imagePost);
    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
    PFObject *userPhoto = [PFObject objectWithClassName:@"PicsVideos"];
    userPhoto[@"name"] = _tfName.text;
    userPhoto[@"pictures"] = imageFile;
    userPhoto[@"location"] = _located;
    if(_urlVideo)
        userPhoto[@"url"] = _urlVideo;
    userPhoto[@"owner"] = [PFUser currentUser];
    [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        SHOW_ERROR_RETURN
        HUDHIDE
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
}

- (void) initLocation
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    _locationManager.distanceFilter = 500;
#ifdef __IPHONE_8_0
    if(IS_OS_8_OR_LATER) {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
    }
#endif
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    [ceo reverseGeocodeLocation: loc completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         _located = [placemark.addressDictionary valueForKey:@"City"];
     }];
}
@end
