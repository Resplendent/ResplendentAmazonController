//
//  AmazonController.m
//  Pineapple
//
//  Created by Benjamin Maer on 3/17/13.
//  Copyright (c) 2013 Pineapple. All rights reserved.
//

#import "RACAmazonController.h"

#import "RUConstants.h"
#import "RUDLog.h"
#import "RUClassOrNilUtil.h"

#import "AWSS3Model.h"





NSString* const kRACAmazonController_NotificationName_UploadImageRequest_DidFinish = @"kRACAmazonController_NotificationName_UploadImageRequest_DidFinish";
NSString* const kRACAmazonController_NotificationName_UploadImageRequest_DidFail = @"kRACAmazonController_NotificationName_UploadImageRequest_DidFail";





@interface RACAmazonController ()

@property (nonatomic, readonly) NSOperationQueue* imageToDataOperationQueue;

@property (nonatomic, readonly) AWSS3* s3Manager;
@property (nonatomic, readonly) NSString* _imageRequestContentType;

-(AWSS3PutObjectRequest*)newImagePutRequestWithImagePath:(NSString*)imagePath;
-(void)convertImageToData:(UIImage*)image sendWithRequest:(AWSS3PutObjectRequest *)request;
-(void)applyImageData:(NSData*)imageData toRequestAndSend:(AWSS3PutObjectRequest *)request;

@end





@implementation RACAmazonController

//+(void)initialize
//{
//    if (self == [RACAmazonController class])
//    {
//        __imageToDataQueue = dispatch_queue_create("RUAmazonController.ImageToDataQueue", 0);
//    }
//}

-(id)init
{
    if (self = [super init])
    {
		_imageToDataOperationQueue = [NSOperationQueue new];

		AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:self.accessKey secretKey:self.secretKey];
		AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
		[AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;

		_s3Manager = [[AWSS3 alloc] initWithConfiguration:configuration];


//        _amazonS3Client = [[AmazonS3Client alloc] initWithAccessKey:self.accessKey withSecretKey:self.secretKey];

        //If you want to create the bucket
//        [_amazonS3Client createBucket:[[S3CreateBucketRequest alloc] initWithName:self.bucketName]];
    }

    return self;
}

-(AWSS3PutObjectRequest*)newImagePutRequestWithImagePath:(NSString*)imagePath
{
	AWSS3PutObjectRequest* uploadRequest = [AWSS3PutObjectRequest new];
	[uploadRequest setKey:imagePath];
	[uploadRequest setContentType:self._imageRequestContentType];
	[uploadRequest setBucket:self.bucketName];
	return uploadRequest;
}

-(AWSS3PutObjectRequest*)uploadImage:(UIImage*)image imagePath:(NSString *)imagePath
{
    AWSS3PutObjectRequest* request = [self newImagePutRequestWithImagePath:imagePath];

	[self convertImageToData:image sendWithRequest:request];

    return request;
}

-(void)convertImageToData:(UIImage*)image sendWithRequest:(AWSS3PutObjectRequest *)request
{
	if (image == nil)
	{
		NSAssert(FALSE, @"Must pass an image");
		return;
	}

	NSBlockOperation* operation = [NSBlockOperation blockOperationWithBlock:^{
		@autoreleasepool {

			if (operation.isCancelled)
			{
				return;
			}
			
			NSData* imageData = UIImagePNGRepresentation(image);
			
			if (operation.isCancelled)
			{
				return;
			}

			[self applyImageData:imageData toRequestAndSend:request];

		}
	}];

	[self.imageToDataOperationQueue addOperation:operation];
}

-(void)applyImageData:(NSData *)imageData toRequestAndSend:(AWSS3PutObjectRequest *)request
{
	[request setBody:imageData];
	[self sendRequest:request];
}

-(AWSS3PutObjectRequest*)uploadImageWithData:(NSData *)imageData imagePath:(NSString *)imagePath
{
    AWSS3PutObjectRequest* request = [self newImagePutRequestWithImagePath:imagePath];

	[self applyImageData:imageData toRequestAndSend:request];

    return request;
}

-(void)sendRequest:(AWSS3PutObjectRequest *)request
{
	if (request.body == nil)
	{
		NSAssert(FALSE, @"Must have a body");
		return;
	}
	
	if (!kRUClassOrNil(request.body, NSData))
	{
		NSAssert(FALSE, @"Body must be data");
		return;
	}
	
    dispatch_async(dispatch_get_main_queue(), ^{

		[[self.s3Manager putObject:request] continueWithBlock:^id(BFTask *task) {

			if (task.isCancelled)
			{
				return nil;
			}

			if (task.isCompleted == false)
			{
				NSAssert(false, @"task should have completed");
				return nil;
			}

			if (task.error)
			{
				[[NSNotificationCenter defaultCenter]postNotificationName:kRACAmazonController_NotificationName_UploadImageRequest_DidFail object:request userInfo:@{NSUnderlyingErrorKey: task.error}];
			}
			else
			{
				[[NSNotificationCenter defaultCenter]postNotificationName:kRACAmazonController_NotificationName_UploadImageRequest_DidFinish object:request];
			}

			return nil;

		}];

    });
}

-(NSURL*)imageURLForImagePath:(NSString*)imagePath
{
	AWSS3GetObjectRequest* request = [AWSS3GetObjectRequest new];
	[request setBucket:self.bucketName];
	[request setKey:imagePath];

	return request.downloadingFileURL;
}

#pragma mark - Getter method
-(NSString *)accessKey
{
    RU_METHOD_OVERLOADED_IMPLEMENTATION_NEEDED_EXCEPTION;
}

-(NSString *)secretKey
{
    RU_METHOD_OVERLOADED_IMPLEMENTATION_NEEDED_EXCEPTION;
}

-(NSString *)bucketName
{
    RU_METHOD_OVERLOADED_IMPLEMENTATION_NEEDED_EXCEPTION;
}

#pragma mark - imageRequestContentType
-(NSString *)_imageRequestContentType
{
    NSString* imageRequestContentType = self.imageRequestContentType;
	return (imageRequestContentType.length ? imageRequestContentType : @"image/png");
}

@end





@implementation NSObject (RACAmazonControllerNotifications)

kRUNotifications_Synthesize_NotificationGetterSetterNumberFromPrimative_Implementation_AssociatedKey(r,R,egisteredForNotification_RACAmazonController_UploadImageRequest_DidFinish, kRACAmazonController_NotificationName_UploadImageRequest_DidFinish, nil);
kRUNotifications_Synthesize_NotificationGetterSetterNumberFromPrimative_Implementation_AssociatedKey(r,R,egisteredForNotification_RACAmazonController_UploadImageRequest_DidFail, kRACAmazonController_NotificationName_UploadImageRequest_DidFail, nil);

@end
