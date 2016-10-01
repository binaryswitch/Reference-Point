//
//  ARViewController.m
//  ReferencePoint
//
//  Created by Justin White on 1/10/16.
//  Copyright © 2016 binaryswitch. All rights reserved.
//

#import "ARViewController.h"
#import "CommonPlace.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>

@interface ARViewController ()

@property (nonatomic, strong) UIButton * backButton;
@property (nonatomic, strong) UIView * cameraView;
@property (nonatomic, strong) AVCaptureSession * session;
@property (nonatomic, strong) CMMotionManager * motionManager;

@property (nonatomic, strong) UILabel * gyroDebugLabel;

@end

@implementation ARViewController

-(void)viewDidLoad{
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.cameraView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height) inView:self.view];
    
    self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 50, 30) inView:self.cameraView];
    [self.backButton setTitle:@"Back" forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(didTapBackButton) forControlEvents:UIControlEventTouchDown];
    [self.backButton setBackgroundColor:[UIColor lightGrayColor]];
    
    self.gyroDebugLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.backButton.right + 10, 20, self.view.width - self.backButton.right + 10, 30) inView:self.cameraView];
    self.gyroDebugLabel.text = @"--Gyro data--";
    [self.gyroDebugLabel setTextColor:[UIColor whiteColor]];
    self.gyroDebugLabel.numberOfLines = 3;
    
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetMedium;
    
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    
    captureVideoPreviewLayer.frame = self.cameraView.bounds;
    [self.cameraView.layer addSublayer:captureVideoPreviewLayer];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (!input) {
        
        NSLog(@"ERROR: trying to open camera: %@", error);
    }
    
    [self.session addInput:input];
    
    self.motionManager.deviceMotionUpdateInterval = 0.03;

}

-(void) didTapBackButton{
    [self dismissViewControllerAnimated:self completion:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.session startRunning];

    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
        self.gyroDebugLabel.text = [NSString stringWithFormat:@"r: %f p: %f y: %f]", motion.attitude.roll, motion.attitude.pitch, motion.attitude.yaw];
    }];

}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.session stopRunning];
    [self.motionManager stopDeviceMotionUpdates];
}

@end
