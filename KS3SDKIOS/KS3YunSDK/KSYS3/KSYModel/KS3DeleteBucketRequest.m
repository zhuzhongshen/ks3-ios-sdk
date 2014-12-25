//
//  KSS3DeleteBucketRequest.m
//  KS3SDK
//
//  Created by JackWong on 12/12/14.
//  Copyright (c) 2014 kingsoft. All rights reserved.
//

#import "KS3DeleteBucketRequest.h"
#import "KS3Constants.h"
#import "KS3ClientException.h"
@implementation KS3DeleteBucketRequest

- (instancetype)initWithName:(NSString *)bucketName
{
    self = [super init];
    if (self) {
        self.bucket = bucketName;
        self.httpMethod = kHttpMethodDelete;
        self.contentMd5 = @"";
        self.contentType = @"";
        self.kSYHeader = @"";
        self.kSYResource = [NSString stringWithFormat:@"/%@/", bucketName];
        self.host = [NSString stringWithFormat:@"http://%@.kss.ksyun.com", bucketName];
    }
    return self;
}
- (KS3ClientException *)validate
{
    KS3ClientException *clientException = [super validate];
    if(clientException == nil)
    {
        if (nil == self.bucket) {
            clientException = [KS3ClientException exceptionWithMessage : @"Bucket Name should not be nil."];
        }
    }
    return clientException;
}
@end