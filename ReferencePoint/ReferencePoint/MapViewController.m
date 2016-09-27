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

@import Firebase;

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate,UIGestureRecognizerDelegate>
@property (strong, nonatomic)  MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation* currentLocation;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (strong, nonatomic) UIView * bottomView;

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) UITextField *addAndEditTextField;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (nonatomic) BOOL keyboardIsUp;

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView = [[MKMapView alloc] initWithFrame: self.view.frame];
    [self.view addSubview:self.mapView];
    
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
    
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height,  self.view.frame.size.width, 100)];
    self.bottomView.backgroundColor = [UIColor clearColor];
    
    self.addAndEditTextField = [[UITextField alloc] initWithFrame:CGRectMake(25, 25, self.bottomView.frame.size.width - 50, 20)];
    self.addAndEditTextField.backgroundColor = [UIColor whiteColor];
    self.addAndEditTextField.text = @"pin";
    [self.bottomView addSubview:self.addAndEditTextField];

    UILabel * typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 60, 200, 20)];
    typeLabel.text = @"Company";
    [self.bottomView addSubview:typeLabel];


    [self.view addSubview:self.bottomView];
    
    [self.view bringSubviewToFront:self.topView];
    [self.view bringSubviewToFront:self.bottomView];
    

    self.searchTextField.delegate = self;
    self.searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.addAndEditTextField.delegate = self;
    self.addAndEditTextField.autocorrectionType = UITextAutocorrectionTypeNo;

    [self.deleteButton addTarget:self action:@selector(didTapDeleteButton) forControlEvents:UIControlEventTouchDown];
    
    UILongPressGestureRecognizer* longTapListener = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongTapMap:)];
    
    longTapListener.delaysTouchesBegan = YES;
    [self.mapView addGestureRecognizer:longTapListener];
    
    UITapGestureRecognizer * tapListener = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(didTapMap:)];
    
    [self.mapView addGestureRecognizer:tapListener];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.keyboardIsUp = NO;
    
    FIRDatabaseReference * userDatabaseRef = [self getPrivateUserRouteReference];
    
    [userDatabaseRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
       
        FirebaseUserDataModelResponse * firebaseResponse = [[FirebaseUserDataModelResponse alloc] initWithDictionary:snapshot.value error:nil];
        
        for (int i = 0; i < firebaseResponse.castedPins.count; i++){
            FirebaseDataPin * pin = [firebaseResponse.castedPins objectAtIndex:i];
            NSLog(@"id: %@ lon: %@ lat: %@",pin.firebaseId, pin.latitude, pin.longitude);
            
            MKPointAnnotation *mkpoint = nil;
            
            for (int p = 0; p < self.mapView.annotations.count; p++){
                MKPointAnnotation *mkpointAtIndex = (MKPointAnnotation *)[self.mapView.annotations objectAtIndex:p];
                
                if ([mkpointAtIndex.subtitle isEqualToString:pin.firebaseId]){
                    mkpoint = mkpointAtIndex;
                }
            }
            
            if (mkpoint == nil){
                mkpoint = [[MKPointAnnotation alloc] init];
            }
            
            mkpoint.coordinate = CLLocationCoordinate2DMake(pin.latitude.doubleValue, pin.longitude.doubleValue);
            mkpoint.title= @"pin";
            mkpoint.subtitle = pin.firebaseId;
            
            [self.mapView addAnnotation:mkpoint];

        }
        
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
    
    FIRDatabaseReference * publicDatabaseRef = [self getPublicRouteReference];
    
    [publicDatabaseRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        
        FirebasePublicDataModelResponse * firebaseResponse = [[FirebasePublicDataModelResponse alloc] initWithDictionary:snapshot.value error:nil];
        
        
    } withCancelBlock:^(NSError *error) {
        NSLog(@"%@", error.description);
    }];
    
    
}

- (void)didTapDeleteButton{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    FIRDatabaseReference * userPinsReference = [[self getPrivateUserRouteReference] child:@"pins"];
    [userPinsReference setValue:nil];

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
    if (recognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    [self.addAndEditTextField resignFirstResponder];
}

- (void)didLongTapMap:(UIGestureRecognizer *)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    BOOL otherPinsInArea = false;
    
    CGPoint point = [recognizer locationInView:self.mapView];
    CLLocationCoordinate2D tapPoint = [self.mapView convertPoint:point toCoordinateFromView:self.view];
    
    NSLog(@"%f %f",tapPoint.latitude, tapPoint.longitude );

    
    for (int i = 0; i < self.mapView.annotations.count; i++){
        //NSLog(@"annotation check");

        id<MKAnnotation> pin = [self.mapView.annotations objectAtIndex:i];
        CLLocationCoordinate2D point = pin.coordinate;

       // NSLog(@"%f %f",point.latitude, point.longitude );

        
        double latDiff = tapPoint.latitude -  point.latitude;
        double lonDiff = tapPoint.longitude - point.longitude;
        
        if (fabs(latDiff) < 0.00005 && fabs(lonDiff) < 0.00005){
            
           // NSLog(@"%f %f",fabs(latDiff), fabs(lonDiff));

            otherPinsInArea = true;
            NSLog(@"hit");
        }
    }
    
    if (otherPinsInArea == false){
        [self.addAndEditTextField becomeFirstResponder];
        self.addAndEditTextField.text = @"pin";
        
        MKPointAnnotation *mkpoint = [[MKPointAnnotation alloc] init];
        
        mkpoint.coordinate = tapPoint;
        mkpoint.title= @"pin";
        mkpoint.subtitle = @"";
        
        [self.mapView addAnnotation:mkpoint];
        
    
        MKMapRect zoomRect = MKMapRectNull;
        MKMapPoint annotationPoint = MKMapPointForCoordinate(mkpoint.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.4, 0.4);
        
        zoomRect = pointRect;
        
        FIRDatabaseReference *newFieldRef = [[self getPrivateUserRouteReference] child:@"pins"].childByAutoId;
    
        NSNumber * lat = [NSNumber numberWithDouble:mkpoint.coordinate.latitude];
        NSNumber * lon = [NSNumber numberWithDouble:mkpoint.coordinate.longitude];
        NSNumber * creationEpoch = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970] * 1000 ];
        
        [newFieldRef setValue:@{@"lat":lat,@"lon":lon, @"timeAtCreation": creationEpoch, @"typeId" : @(0)}];
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    
    if (!self.keyboardIsUp){
        [self.addAndEditTextField becomeFirstResponder];
 
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{

}

//- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
//{
//    if([annotation isKindOfClass: [MKUserLocation class]])
//        return nil;
//    
//    MKPinAnnotationView *annView=[[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"pin"];
//    
//    return annView;
//}


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
                         
                         CGSize viewSize = self.bottomView.frame.size;
                         CGRect newRect = CGRectMake(0, (self.view.frame.size.height - keyboardRect.size.height) - viewSize.height, viewSize.width, viewSize.height);
                         
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
                         
                         
                         CGSize viewSize = self.bottomView.frame.size;
                         CGRect newRect = CGRectMake(0, self.view.frame.size.height, viewSize.width, viewSize.height);
                         
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
