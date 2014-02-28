//
//  RUAmazonControllerProtocols.h
//  Pineapple
//
//  Created by Benjamin Maer on 11/12/13.
//  Copyright (c) 2013 Pineapple. All rights reserved.
//

#import <Foundation/Foundation.h>





@class RACAmazonController;
@class AmazonServiceResponse;





@protocol RACAmazonControllerDelegate <NSObject>

-(void)amazonController:(RACAmazonController*)amazonController didFinishWithResponse:(AmazonServiceResponse *)response;
-(void)amazonController:(RACAmazonController*)amazonController didFailWithError:(NSError*)error;

@end
