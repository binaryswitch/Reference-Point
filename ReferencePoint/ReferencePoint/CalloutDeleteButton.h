//
//  CalloutDeleteButton.h
//  ReferencePoint
//
//  Created by Justin White on 29/09/16.
//  Copyright © 2016 binaryswitch. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface CalloutDeleteButton : UIButton

@property (nonatomic) NSString * firebaseIdReferenced;
@property (nonatomic, weak) MKPointAnnotation * pointAnnotationReferenced;

@end
