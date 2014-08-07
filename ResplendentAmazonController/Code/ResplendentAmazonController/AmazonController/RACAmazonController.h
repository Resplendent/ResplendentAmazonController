//
//  AmazonController.h
//  Pineapple
//
//  Created by Benjamin Maer on 3/17/13.
//  Copyright (c) 2013 Pineapple. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RUNotifications.h"

#import "AWSCore.h"
#import "S3.h"





@interface RACAmazonController : NSObject

//Must be overloaded by a subclass
@property (nonatomic, readonly) NSString* accessKey;
@property (nonatomic, readonly) NSString* secretKey;
@property (nonatomic, readonly) NSString* bucketName;

//Can be overloaded, by default will be image/png
@property (nonatomic, readonly) NSString* imageRequestContentType;

//-(void)sendRequest:(AWSS3PutObjectRequest *)request withImage:(UIImage*)image;

-(AWSS3PutObjectRequest*)uploadImage:(UIImage*)image imagePath:(NSString*)imagePath;
-(AWSS3PutObjectRequest*)uploadImageWithData:(NSData*)imageData imagePath:(NSString*)imagePath;

//Thread safe
-(void)sendRequest:(AWSS3PutObjectRequest*)request;

//returns name of photo in amazon bucket
-(NSURL*)imageURLForImagePath:(NSString*)imagePath;

@end





@interface NSObject (RACAmazonControllerNotifications)

//Notification's object will be request, which is an instance of AWSS3PutObjectRequest.
kRUNotifications_Synthesize_NotificationReadonlySetWithSelectorClearProperty(r,R,egisteredForNotification_RACAmazonController_UploadImageRequest_DidFinish)
kRUNotifications_Synthesize_NotificationReadonlySetWithSelectorClearProperty(r,R,egisteredForNotification_RACAmazonController_UploadImageRequest_DidFail)

@end