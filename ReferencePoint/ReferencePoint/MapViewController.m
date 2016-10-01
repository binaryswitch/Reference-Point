//
//  MapViewController.m
//  ReferencePoint
//
//  Created by Justin White on 24/09/16.
//  Copyright © 2016 binaryswitch. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "FirebaseUserDataModelResponse.h"
#import "FirebasePublicDataModelResponse.h"
#import "ReferenceAnnotationPointView.h"
#import "ReferencePointAnnotation.h"
#import "CalloutDeleteButton.h"
#import "SettingsViewController.h"
#import "ARViewController.h"
#import "CommonPlace.h"

@import Firebase;

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate,UIGestureRecognizerDelegate>
@property (strong, nonatomic)  MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation* currentLocation;
@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIView * bottomView;

@property (strong, nonatomic) UITextField *searchTextField;
@property (strong, nonatomic) UITextField *addAndEditTextField;

@property (strong, nonatomic) UIButton * settingsButton;

@property (strong, nonatomic) NSString * lastSelectedPoint;

@property (nonatomic) BOOL keyboardIsUp;
@property (nonatomic) FIRDatabaseHandle firebaseMainObserverRef;

@property (strong, nonatomic) ARViewController * arViewController;

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.arViewController = [[ARViewController alloc] init];
    
    self.mapView = [[MKMapView alloc] initWithFrame: self.view.frame inView:self.view];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    [self.locationManager startUpdatingLocation];
    
    self.mapView.delegate =  self;
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    self.mapView.frame = self.view.frame;
    
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 70) inView:self.view ];
    [self.topView setBackgroundColor:[UIColor lightGrayColor]];

    self.searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 20, 200, 30) inView:self.topView];
    self.searchTextField.accessibilityHint = @"hint";
    self.searchTextField.backgroundColor = [UIColor whiteColor];
    
    self.settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(self.searchTextField.right + 10, 20, 70, 30) inView:self.topView];
    [self.settingsButton setTitle:@"Settings" forState:UIControlStateNormal];
    [self.settingsButton addTarget:self action:@selector(didTapSettingsButton) forControlEvents:UIControlEventTouchDown];
    
    UIButton * arButton = [[UIButton alloc] initWithFrame:CGRectMake(self.settingsButton.right + 10, 20, 30, 30) inView:self.topView];
    [arButton setTitle:@"3D" forState:UIControlStateNormal];
    [arButton addTarget:self action:@selector(didTapARButton) forControlEvents:UIControlEventTouchDown];

    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height,  self.view.width, 100) inView:self.view];
    self.bottomView.backgroundColor = [UIColor clearColor];
    
    self.addAndEditTextField = [[UITextField alloc] initWithFrame:CGRectMake(25, 25, self.bottomView.width - 50, 20) inView:self.bottomView];
    self.addAndEditTextField.backgroundColor = [UIColor whiteColor];
    self.addAndEditTextField.text = @"pin";
    self.addAndEditTextField.delegate = self;
    self.addAndEditTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    self.searchTextField.delegate = self;
    self.searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    UIButton * typeSwitchButton = [[UIButton alloc] initWithFrame:CGRectMake(25, 60, 200, 20) inView:self.bottomView];
    [typeSwitchButton setTitle:@"No Type" forState:UIControlStateNormal];
    [typeSwitchButton setTitleColor: [UIColor blackColor] forState:UIControlStateNormal];
    typeSwitchButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    [self.view bringSubviewToFront:self.topView];
    [self.view bringSubviewToFront:self.bottomView];
    
    UILongPressGestureRecognizer* longTapListener = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongTapMap:)];
    
    longTapListener.delaysTouchesBegan = YES;
    [self.mapView addGestureRecognizer:longTapListener];
    
    UITapGestureRecognizer * tapListener = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(didTapMap:)];
    tapListener.delegate = self;
    [self.mapView addGestureRecognizer:tapListener];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.keyboardIsUp = NO;
    
    FIRDatabaseReference * userDatabaseRef = [self getPrivateUserRouteReference];

    self.firebaseMainObserverRef = [userDatabaseRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
         NSLog(@"OBSERVE CHANGE");
        
        [userDatabaseRef removeObserverWithHandle:self.firebaseMainObserverRef];

        FirebaseUserDataModelResponse * firebaseResponse = [[FirebaseUserDataModelResponse alloc] initWithDictionary:snapshot.value error:nil];
        
        for (int i = 0; i < firebaseResponse.castedPins.count; i++){
            FirebaseDataPin * pin = [firebaseResponse.castedPins objectAtIndex:i];
            [self handleNewPin:pin];
        }
    }
    withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
    
    //Listen for changes (adds) and removals
    FIRDatabaseReference * userPinDatabaseRef = [[self getPrivateUserRouteReference] child:@"pins"];
    
    [userPinDatabaseRef observeEventType:FIRDataEventTypeChildChanged withBlock:^(FIRDataSnapshot *snapshot) {
        NSLog(@"Child changed %@", snapshot.value);
        NSError * err;
        FirebaseDataPin * pin = [[FirebaseDataPin alloc] initWithDictionary:snapshot.value error:&err];
        pin.firebaseId = snapshot.key;
        [self handleNewPin:pin];

    }
     withCancelBlock:^(NSError *error) {
         NSLog(@"%@", error.description);
     }];
    
    [userPinDatabaseRef observeEventType:FIRDataEventTypeChildRemoved withBlock:^(FIRDataSnapshot *snapshot) {
        NSLog(@"Child removed %@", snapshot.value);
        FirebaseDataPin * pin = [[FirebaseDataPin alloc] initWithDictionary:snapshot.value error:nil];
        pin.firebaseId = snapshot.key;
        [self deletePinIfExists: pin];
        
    }
     withCancelBlock:^(NSError *error) {
         NSLog(@"%@", error.description);
     }];

    
    [self.addAndEditTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
}

- (void) handleNewPin: (FirebaseDataPin *) pin {

    MKPointAnnotation *mkpoint = nil;
    
    //check if pin already exists on map
    for (int p = 0; p < self.mapView.annotations.count; p++){
        MKPointAnnotation *mkpointAtIndex = (MKPointAnnotation *)[self.mapView.annotations objectAtIndex:p];
        
        if ([mkpointAtIndex.subtitle isEqualToString:pin.firebaseId]){
            mkpoint = mkpointAtIndex;
            
        }
    }
    
    if (mkpoint == nil){
        mkpoint = [[ReferencePointAnnotation alloc] initWithFirebasePinData:pin];
    }
    
    mkpoint.coordinate = CLLocationCoordinate2DMake(pin.latitude.doubleValue, pin.longitude.doubleValue);
    mkpoint.title= pin.desc;
    
    UIView * mkpointView = [self.mapView viewForAnnotation:mkpoint];
    
    if (mkpointView != nil && [mkpointView isKindOfClass:[MKPinAnnotationView class]]){
        
        MKPinAnnotationView * pinView = (MKPinAnnotationView *) mkpointView;
        
        if ([mkpoint.title.lowercaseString containsString:@"rubbish bin"]){
            pinView.pinColor = MKPinAnnotationColorPurple;
            
        }
        else{
            pinView.pinColor = MKPinAnnotationColorRed;
        }
    }
    
    mkpoint.subtitle = pin.firebaseId;
    
    [self.mapView addAnnotation:mkpoint];
}

- (void) deletePinIfExists: (FirebaseDataPin *) pin {
    
    for (int p = 0; p < self.mapView.annotations.count; p++){
        MKPointAnnotation *mkpointAtIndex = (MKPointAnnotation *)[self.mapView.annotations objectAtIndex:p];
        
        if ([mkpointAtIndex.subtitle isEqualToString:pin.firebaseId]){
            [self.mapView removeAnnotation:mkpointAtIndex];
        }
    }
}

- (FIRDatabaseReference *) getPublicRouteReference {
    FIRDatabaseReference *rootRef= [[FIRDatabase database] reference];
    return [rootRef child:@"public"];
}

- (FIRDatabaseReference *) getPrivateUserRouteReference {
    FIRDatabaseReference *rootRef= [[FIRDatabase database] reference];
    FIRDatabaseReference *userRef= [rootRef child:@"private/users"];
    
    return [userRef child:[FIRAuth auth].currentUser.uid];
}

- (void)didTapMap:(UIGestureRecognizer *)recognizer{
    
    if (recognizer.state != UIGestureRecognizerStateEnded){
        return;
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (void)didLongTapMap:(UIGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    CGPoint point = [recognizer locationInView:self.mapView];
    CLLocationCoordinate2D tapPoint = [self.mapView convertPoint:point toCoordinateFromView:self.view];
    
    NSLog(@"%f %f",tapPoint.latitude, tapPoint.longitude );

    [self.addAndEditTextField becomeFirstResponder];
    
    NSNumber * lat = [NSNumber numberWithDouble:tapPoint.latitude];
    NSNumber * lon = [NSNumber numberWithDouble:tapPoint.longitude];
    NSNumber * creationEpoch = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] * 1000];
    NSString * newKey = [FirebaseDataPin randomKeyWithLength:14];

    FirebaseDataPin * dataPin = [[FirebaseDataPin alloc] init];
    dataPin.latitude = lat;
    dataPin.longitude = lon;
    dataPin.firebaseId = newKey;
    
    ReferencePointAnnotation *mkpoint = [[ReferencePointAnnotation alloc] initWithFirebasePinData:dataPin];
    
    mkpoint.coordinate = tapPoint;
    mkpoint.title= self.addAndEditTextField.text;

    [self.mapView addAnnotation:mkpoint];
    
    MKMapRect zoomRect = MKMapRectNull;
    MKMapPoint annotationPoint = MKMapPointForCoordinate(mkpoint.coordinate);
    MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.4, 0.4);
    
    zoomRect = pointRect;
    
    FIRDatabaseReference *newFieldRef = [[[self getPrivateUserRouteReference] child:@"pins"] child:newKey];
    mkpoint.subtitle = newKey;
    
    [newFieldRef setValue:@{@"lat":lat,@"lon":lon, @"timeAtCreation": creationEpoch, @"lastEdited": creationEpoch, @"description": self.addAndEditTextField.text, @"typeId" : @(0)}];
}

#pragma mark MKMapView delegates

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    
    MKPointAnnotation * annotation = view.annotation;
    
    if([annotation isKindOfClass: [MKUserLocation class]]){
        return;
    }
    
    self.lastSelectedPoint = view.annotation.subtitle;
    self.addAndEditTextField.text = annotation.title;


    if (!self.keyboardIsUp){
        [self.addAndEditTextField becomeFirstResponder];
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
    NSLog(@"select");

}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
    if([annotation isKindOfClass: [MKUserLocation class]]){

        return nil;
    }

    MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinView"];
    
    pinView.pinColor = MKPinAnnotationColorRed;
    pinView.canShowCallout = YES;
    
    if ([annotation isKindOfClass:[ReferencePointAnnotation class]]){
        
        ReferencePointAnnotation * castedReference = (ReferencePointAnnotation *)annotation;
    
        if ([castedReference.title.lowercaseString containsString:@"rubbish bin"]){
            pinView.pinColor = MKPinAnnotationColorPurple;

        }
        else{
            pinView.pinColor = MKPinAnnotationColorRed;
        }
        
        CalloutDeleteButton *rightButton = [[CalloutDeleteButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        rightButton.firebaseIdReferenced = [castedReference getReferencedFirebaseId];
        rightButton.pointAnnotationReferenced = castedReference;
        
        [rightButton setTitle:@"DEL" forState:UIControlStateNormal];
        [rightButton setBackgroundColor:[UIColor grayColor]];
        [rightButton addTarget:self action:@selector(calloutDeleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        pinView.rightCalloutAccessoryView = rightButton;
    }
    
    return pinView;
}

- (void) calloutDeleteButtonClicked: (CalloutDeleteButton *) sender {
    [self.mapView removeAnnotation:sender.pointAnnotationReferenced];
    FIRDatabaseReference * userPinsReference = [[[self getPrivateUserRouteReference] child:@"pins"] child:sender.firebaseIdReferenced];
    [userPinsReference setValue:nil];
}

- (void)keyboardWillShow:(id)keyboardDidShow
{
    self.keyboardIsUp = true;
    NSLog(@"show keyboard");
    
    
    NSDictionary *userInfo = [keyboardDidShow userInfo];
    [UIView animateWithDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:0.f
                        options:[[keyboardDidShow userInfo][UIKeyboardAnimationCurveUserInfoKey] intValue] << 16
                     animations:^{
                         
                         CGRect keyboardRect = [[keyboardDidShow userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];
                         keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
                         
                         CGRect newRect = CGRectMake(0, (self.view.height - keyboardRect.size.height) - self.bottomView.height, self.bottomView.width, self.bottomView.height);
                         
                         self.bottomView.frame = newRect;
                         
//                         CGSize topRect = self.topView.frame.size;
//                         CGRect newTopRectFrame = CGRectMake(0, -200, topRect.width, topRect.height);
//                         
//                         self.topView.frame = newTopRectFrame;
//                         
                        // NSLog(NSStringFromCGRect(newTopRectFrame));
                         
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)keyboardWillHide:(id)keyboardDidHide
{
    NSLog(@"hide keyboard");

    NSDictionary *userInfo = [keyboardDidHide userInfo];
    [UIView animateWithDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:0.f
                        options:[[keyboardDidHide userInfo][UIKeyboardAnimationCurveUserInfoKey] intValue] << 16
                     animations:^{
                         
                         
                         CGRect newRect = CGRectMake(0, self.view.height, self.bottomView.width, self.bottomView.height);
                         
                         self.bottomView.frame = newRect;
                         
//                         CGSize topRect = self.topView.frame.size;
//                         CGRect newTopRectFrame = CGRectMake(0, 0, topRect.width, topRect.height);
//                         
//                         self.topView.frame = newTopRectFrame;
                         
                     } completion:^(BOOL finished) {
                         self.keyboardIsUp = false;
                     }];
}


#pragma mark - locationmanager delegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = [locations lastObject];
    //NSLog(@"Got location");
    // here we get the current location
}


#pragma mark - textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void) textFieldDidChange: (UITextField *) textfield{
    if (textfield == self.addAndEditTextField){
        
        NSString * newDescription = self.addAndEditTextField.text;
        
        if (newDescription == nil){
            newDescription = @"";
        }
        
        FIRDatabaseReference * itemRef = [[[self getPrivateUserRouteReference] child:@"pins"] child:self.lastSelectedPoint];
        
        FIRDatabaseReference *descriptionRef = [itemRef child: @"description"];
        [descriptionRef setValue:newDescription];
        
        NSNumber * currentEpoch = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] * 1000 ];

        FIRDatabaseReference *lastUpdatedRef = [itemRef child: @"lastUpdated"];
        [lastUpdatedRef setValue:currentEpoch];

    }
}


- (void) didTapSettingsButton {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SettingsViewController * nextScreen = [storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    [self presentViewController:nextScreen animated:YES completion:nil];
}

- (void) didTapARButton {
    [self presentViewController:self.arViewController animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
