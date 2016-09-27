//
//  FirebaseUserDataModel.m
//  ReferencePoint
//
//  Created by Justin White on 26/09/16.
//  Copyright © 2016 binaryswitch. All rights reserved.
//

#import "FirebaseUserDataModelResponse.h"

@implementation FirebaseUserDataModelResponse

-(BOOL)validate:(NSError *__autoreleasing *)error{
    
    BOOL valid = [super validate:error];
    
    //fix bug with optional arrays of sub-models
    if (self.pins){
        
        self.castedPins = [[NSMutableArray<FirebaseDataPin *> alloc] init];
        
        NSArray <NSString*> * responseKeys = self.pins.allKeys;
        
        for (int j = 0; j < responseKeys.count; j++){
            
            NSDictionary * pinData = [self.pins objectForKey:[responseKeys objectAtIndex:j]];
            
            if (pinData != nil){
                
                FirebaseDataPin * pin = [[FirebaseDataPin alloc] init];
                
                double lat = ((NSString *)[pinData objectForKey:@"lat"]).doubleValue;
                double lon = ((NSString *)[pinData objectForKey:@"lon"]).doubleValue;
                NSString * description = ((NSString *)[pinData objectForKey:@"description"]);
                
                pin.firebaseId =[responseKeys objectAtIndex:j];
                pin.latitude = [NSNumber numberWithDouble:lat];
                pin.longitude = [NSNumber numberWithDouble:lon];
                pin.desc = description;
                
                [self.castedPins addObject:pin];
            }
        }
    }
    
    return valid;
}


@end
