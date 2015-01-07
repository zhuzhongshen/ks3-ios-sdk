//
//  GetBucketACLViewController.m
//  KS3iOSSDKDemo
//
//  Created by Blues on 12/16/14.
//  Copyright (c) 2014 Blues. All rights reserved.
//

#warning Please set correct bucket name
#define kBucketName @"acc"
//#define kBucketName @"alert1"

#import "GetAllObjectsViewController.h"
#import <KS3YunSDK/KS3YunSDK.h>

@interface GetAllObjectsViewController () <UIActionSheetDelegate>

@property (nonatomic, strong) IBOutlet UITableView *objectTable;
@property (nonatomic, strong) NSArray *arrObjects;
@property (nonatomic, strong) NSIndexPath *selectIndexPath;
@property (nonatomic, strong) KS3ListObjectsResult *result;

@end

@implementation GetAllObjectsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = [NSString stringWithFormat:@"\"%@\"中所有的Objects", kBucketName];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(clickActionBtn:)];
    self.navigationItem.rightBarButtonItem = rightBtn;
    KS3ListObjectsRequest *listObjectRequest = [[KS3ListObjectsRequest alloc] initWithName:kBucketName];
//    listObjectRequest.prefix = @"r32/tew3";
//    listObjectRequest.delimiter = @"c";
//    listObjectRequest.maxKeys = 5;
    KS3ListObjectsResponse *response = [[KS3Client initialize] listObjects:listObjectRequest];
    _result = response.listBucketsResult;
    _arrObjects = response.listBucketsResult.objectSummaries;
    
    for (KS3ObjectSummary *objectSummary in _arrObjects) {
        NSLog(@"%@",objectSummary.Key);
        NSLog(@"%@",objectSummary.owner.ID);
    }
    NSLog(@"%@",_result.bucketName);
    NSLog(@"%ld",_result.objectSummaries.count);
    NSLog(@"%ld",_result.commonPrefixes.count);
    
    NSLog(@"KSS3ListObjectsResponse %d",response.httpStatusCode);
}

#pragma mark - UITableView datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *strIdentifier = @"bucket identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strIdentifier];
    }
    KS3ObjectSummary *object = _arrObjects[indexPath.row];
    cell.textLabel.text = object.Key;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectIndexPath = indexPath;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete"
                                                    otherButtonTitles:@"Edit Canned ACL", nil];
    actionSheet.tag = 100;
    [actionSheet showInView:self.view];
}

- (NSString *)tableView:(NSString *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"More";
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    KS3ObjectSummary *object = _arrObjects[_selectIndexPath.row];
    if (actionSheet.tag == 100) {
        switch (buttonIndex) {
            case 0:
            {
                KS3DeleteObjectRequest *deleteObjRequest = [[KS3DeleteObjectRequest alloc] initWithName:kBucketName];
                deleteObjRequest.key = object.Key;
                KS3DeleteObjectResponse *response = [[KS3Client initialize] deleteObject:deleteObjRequest];
                if (response.httpStatusCode == 204) {
                    NSLog(@"Delete object success!");
                    KS3ListObjectsRequest *listObjectRequest = [[KS3ListObjectsRequest alloc] initWithName:kBucketName];
                    KS3ListObjectsResponse *response = [[KS3Client initialize] listObjects:listObjectRequest];
                    _result = response.listBucketsResult;
                    _arrObjects = response.listBucketsResult.objectSummaries;
                    [_objectTable reloadData];
                }
                else {
                    NSLog(@"Delete object error: %@", response.error.description);
                }
            }
                break;
            case 1:
            {
                UIActionSheet *aclActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                            delegate:self
                                                                   cancelButtonTitle:@"Cancel"
                                                              destructiveButtonTitle:nil
                                                                   otherButtonTitles:@"Private", @"Public-Read", @"Public-Read-Write", @"Authenticated-Read", nil];
                aclActionSheet.tag = 101;
                [aclActionSheet showInView:self.view];
            }
                break;
            case 2:
                NSLog(@"Cancel object");
                break;
            default:
                break;
        }
    }
    else if (actionSheet.tag == 101) {
        KingSoftYun_PermissionACLType cannedACLType = KingSoftYun_Permission_Private;
        switch (buttonIndex) {
            case 0:
                cannedACLType = KingSoftYun_Permission_Private;
                break;
            case 1:
                cannedACLType = KingSoftYun_Permission_Public_Read;
                break;
            case 2:
                cannedACLType = KingSoftYun_Permission_Public_Read_Write;
                break;
            case 3:
                cannedACLType = KingSoftYun_Permission_Authenticated_Read;
                break;
            case 4:
                NSLog(@"Cancel ACL Setting");
                break;
            default:
                break;
        }
        KS3SetObjectACLRequest *setObjectACLRequest = [[KS3SetObjectACLRequest alloc] initWithName:kBucketName];
        setObjectACLRequest.key = object.Key;
        KS3AccessControlList *acl = [[KS3AccessControlList alloc] init];
        [acl setContronAccess:cannedACLType];
        setObjectACLRequest.acl = acl;
        KS3SetObjectACLResponse *response = [[KS3Client initialize] setObjectACL:setObjectACLRequest];
        if (response.httpStatusCode == 200) {
            NSLog(@"Set object acl success!");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"Set object acl success!"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        else {
            NSLog(@"Set object acl error: %@", response.error.description);
        }
    }
    else if (actionSheet.tag == 102) {
        switch (buttonIndex) {
            case 0:
                NSLog(@"Upload");
                break;
            case 1:
                NSLog(@"Download");
                break;
            case 2:
                NSLog(@"Cancel object action");
                break;
            default:
                break;
        }
    }
}

#pragma mark - Actions

- (void)clickActionBtn:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Upload", @"Download", nil];
    actionSheet.tag = 102;
    [actionSheet showInView:self.view];
}

@end
