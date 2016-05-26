//
//  CreateTopicViewController.m
//  JoinUs
//
//  Created by Liang Qian on 15/5/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "CreateTopicViewController.h"
#import "SelectedImageCollectionViewCell.h"
#import "PHImageManager+CTAssetsPickerController.h"
#import "Utils.h"
#import "NetworkManager.h"
#import "ForumModels.h"

@interface CreateTopicViewController ()

@property (weak, nonatomic) IBOutlet UITextField *titleTextFiled;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UICollectionView *imagesCollectionView;

@end

@implementation CreateTopicViewController {
    NSMutableArray *_selectedAssets;
    int _uploadedImageCount;
    NSMutableArray* _uploadedImageIds;
    PHImageRequestOptions *_submitRequestOptions;
    PHImageRequestOptions *_thumbnailRequestOptions;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _selectedAssets = [NSMutableArray array];
    _uploadedImageCount = 0;
    _uploadedImageIds = [NSMutableArray array];
    
    //To make the border look very close to a UITextField
    [self.contentTextView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.contentTextView.layer setBorderWidth:1.0];
    
    //The rounded corner part, where you specify your view's corner radius:
    self.contentTextView.layer.cornerRadius = 5;
    self.contentTextView.clipsToBounds = YES;
    
    [self.imagesCollectionView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.imagesCollectionView.layer setBorderWidth:1.0];
    self.imagesCollectionView.layer.cornerRadius = 5;
    self.imagesCollectionView.clipsToBounds = YES;
    
    _submitRequestOptions = [[PHImageRequestOptions alloc] init];
    _submitRequestOptions.synchronous = YES;
    _submitRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    _submitRequestOptions.networkAccessAllowed = NO;
    
    _thumbnailRequestOptions = [[PHImageRequestOptions alloc] init];
    _thumbnailRequestOptions.synchronous = YES;
    _thumbnailRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    _thumbnailRequestOptions.networkAccessAllowed = NO;
    _thumbnailRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    
}

- (IBAction)submitButtonPressed:(id)sender {
    [self.view makeToastActivity:CSToastPositionCenter];
    _uploadedImageCount = 0;
    [_uploadedImageIds removeAllObjects];
    [self submitTopic];
}

- (void)submitTopic {
    _uploadedImageCount++;
    if (_uploadedImageCount <= _selectedAssets.count) {
        PHAsset *asset = [_selectedAssets objectAtIndex:_uploadedImageCount - 1];
        
        PHImageManager *manager = [PHImageManager defaultManager];
        [manager requestImageDataForAsset:asset options:_submitRequestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            
            NSLog(@"%@", [info objectForKey:@"PHImageFileURLKey"]);
            [[NetworkManager sharedManager] uploadImageWithUrl:@"upload/image" data:imageData completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
                if (statusCode == 200) {
                    NSError* error;
                    UploadImage* uploadImage = [[UploadImage alloc] initWithData:data error:&error];
                    if (error == nil) {
                        NSLog(@"%@", uploadImage);
                        [_uploadedImageIds addObject:uploadImage.imageId];
                        [self submitTopic];
                    } else {
                        NSLog(@"%@", error);
                    }
                } else {
                    [self.view hideToastActivity];
                    [self.view makeToast:errorMessage];
                }
            }];
            
        }];

    } else {
        
        TopicAdd* topicAdd = [[TopicAdd alloc] init];
        topicAdd.forumId = self.forumId;
        topicAdd.title = self.titleTextFiled.text;
        PostAdd* postAdd = [[PostAdd alloc] init];
        postAdd.content = self.contentTextView.text;
        postAdd.imageIds = [_uploadedImageIds copy];
        topicAdd.firstPost = postAdd;
        
        NSLog(@"%@", topicAdd);
        
        [[NetworkManager sharedManager] putDataWithUrl:@"topic" data:[topicAdd toJSONData] completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
            [self.view hideToastActivity];
            if (statusCode == 200) {
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [self.view makeToast:errorMessage];
            }
        }];
    }
}


#pragma mark UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _selectedAssets.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SelectedImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    if (indexPath.row == _selectedAssets.count) {
        cell.imageView.image = [UIImage imageNamed:@"icon_images_add.png"];
        cell.removeButton.hidden = YES;
    } else {
        cell.removeButton.tag = indexPath.row;
        [cell.removeButton addTarget:self action:@selector(removeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        cell.removeButton.hidden = NO;
        
        PHAsset *asset = [_selectedAssets objectAtIndex:indexPath.row];
        
        
        CGFloat scale = UIScreen.mainScreen.scale;
        CGSize targetSize = CGSizeMake(100 * scale, 100 * scale);
        
        PHImageManager *manager = [PHImageManager defaultManager];
        [manager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:_thumbnailRequestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            cell.imageView.image = result;
            [cell setNeedsLayout];
            [cell layoutIfNeeded];
        }];
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _selectedAssets.count) {
        [self pickImages];
    } else { // preview photos / 预览照片

    }
}

#pragma mark Click Event

- (void)removeButtonPressed:(UIButton *)sender {
    [_selectedAssets removeObjectAtIndex:sender.tag];
    
    [self.imagesCollectionView performBatchUpdates:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
        [self.imagesCollectionView deleteItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
        [self.imagesCollectionView reloadData];
    }];
}

- (void)pickImages {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            // init picker
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            
            // set delegate
            picker.delegate = self;
            
            // set initial selected assets
            picker.selectedAssets = _selectedAssets;
            
            // set default album (Camera Roll)
            picker.defaultAssetCollection = PHAssetCollectionSubtypeSmartAlbumUserLibrary;
            
            // to show selection order
            picker.showsSelectionIndex = YES;
            
            // to present picker as a form sheet in iPad
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                picker.modalPresentationStyle = UIModalPresentationFormSheet;
            
            // present picker
            [self presentViewController:picker animated:YES completion:nil];
            
        });
    }];
}

#pragma mark - Assets Picker Delegate

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    _selectedAssets = [NSMutableArray arrayWithArray:assets];
    [self.imagesCollectionView reloadData];
}


// implement should select asset delegate
- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(PHAsset *)asset
{
    NSInteger max = 5;
    
    // show alert gracefully
    if (picker.selectedAssets.count >= max)
    {
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Attention"
                                            message:[NSString stringWithFormat:@"Please select not more than %ld assets", (long)max]
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action =
        [UIAlertAction actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                               handler:nil];
        
        [alert addAction:action];
        
        [picker presentViewController:alert animated:YES completion:nil];
    }
    
    // limit selection to max
    return (picker.selectedAssets.count < max);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

}


@end
