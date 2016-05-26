//
//  TopicPostsViewController.m
//  JoinUs
//
//  Created by Liang Qian on 18/5/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "TopicPostsViewController.h"
#import "Utils.h"
#import "NetworkManager.h"
#import "ForumModels.h"
#import "PostItemTableViewCell.h"
#import "NYTPhotosViewController.h"
#import "ViewingImage.h"
#import "SelectedImageCollectionViewCell.h"
#import "PHImageManager+CTAssetsPickerController.h"


@interface TopicPostsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *topicView;
@property (weak, nonatomic) IBOutlet UILabel *topicTitleLabel;

@property (weak, nonatomic) IBOutlet UIView *createPostView;
@property (weak, nonatomic) IBOutlet UITextView *postContentTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *postContentHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *postContentBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *blockingViewTopConstraint;

@property (weak, nonatomic) IBOutlet UICollectionView *imagesCollectionView;

@end

@implementation TopicPostsViewController {
    NSMutableArray<PostItem*>* _listItems;
    TopicInfo* _topicInfo;
    BOOL _isLoggedInLastLoad;
    
    NSMutableArray *_selectedAssets;
    int _uploadedImageCount;
    NSMutableArray* _uploadedImageIds;
    PHImageRequestOptions *_submitRequestOptions;
    PHImageRequestOptions *_thumbnailRequestOptions;
    
    UIView* _blockingView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _listItems = [[NSMutableArray alloc] initWithCapacity:100];
    
    _selectedAssets = [NSMutableArray array];
    _uploadedImageCount = 0;
    _uploadedImageIds = [NSMutableArray array];
    
    [self addRefreshViewAndLoadMoreView];
    [self loadWithLoadingView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    
    //To make the border look very close to a UITextField
    [self.createPostView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.createPostView.layer setBorderWidth:1.0];
    
    //The rounded corner part, where you specify your view's corner radius:
    self.createPostView.layer.cornerRadius = 5;
    self.createPostView.clipsToBounds = YES;
    
    //To make the border look very close to a UITextField
    [self.postContentTextView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.postContentTextView.layer setBorderWidth:1.0];
    
    //The rounded corner part, where you specify your view's corner radius:
    self.postContentTextView.layer.cornerRadius = 5;
    self.postContentTextView.clipsToBounds = YES;
    
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
    
    self.postContentBottomConstraint.constant = -self.imagesCollectionView.frame.size.height;
    self.imagesCollectionView.hidden = YES;
    self.blockingViewTopConstraint.constant = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    if (_isLoggedInLastLoad != [[NetworkManager sharedManager] isLoggedIn]) {
        [self loadWithToastActivity];
    }
}

- (void)loadData {
    _isLoggedInLastLoad = [[NetworkManager sharedManager] isLoggedIn];
    NSString* url = [NSString stringWithFormat:@"topic/%@?offset=%d&limit=%d", self.topicId, self.loadingStatus == LoadingStatusLoadingMore ? (int)_listItems.count : 0, 10];
    [[NetworkManager sharedManager] getDataWithUrl:url completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
        if (statusCode == 200) {
            NSError* error;
            PostListLimited* postList = [[PostListLimited alloc] initWithData:data error:&error];
            if (error == nil) {
                _topicInfo = postList.topicInfo;
                self.topicTitleLabel.text = _topicInfo.title;
                
                CGFloat height = [self.topicView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
                CGRect headerFrame = self.topicView.frame;
                headerFrame.size.height = height;
                self.topicView.frame = headerFrame;
                self.tableView.tableHeaderView = self.topicView;
                
//                if (postList.forumInfo.deleteable) {
//                    self.deleteForumButton.hidden = NO;
//                } else {
//                    self.deleteForumButton.hidden = YES;
//                }
                
                if (postList.limit > postList.postItems.count) {
                    self.noMoreData = YES;
                } else {
                    self.noMoreData = NO;
                }
                
                if (self.loadingStatus == LoadingStatusLoadingWithLoadingView
                    || self.loadingStatus == LoadingStatusLoadingWithRefreshView
                    || self.loadingStatus == LoadingStatusLoadingWithToastActivity)
                {
                    [_listItems removeAllObjects];
                }
                
                for (PostItem* item in postList.postItems) {
                    [_listItems addObject:item];
                }
                
                [self.tableView reloadData];
            } else {
                NSLog(@"%@", error);
            }
        } else {
            if (self.loadingStatus == LoadingStatusLoadingWithLoadingView) {
                [self showErrorViewWithMessage:errorMessage];
            } else {
                [self.view makeToast:errorMessage];
            }
        }
        
        [self removeLoadingViews];
    }];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_listItems != nil) {
        return _listItems.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    PostItem* post = _listItems[indexPath.row];
    
    if (cell.tasks != nil && cell.tasks.count > 0) {
        for (NSURLSessionTask* task in cell.tasks) {
            if (task.state == NSURLSessionTaskStateRunning) {
                [task cancel];
            }
        }
    }
    
    if (cell.tasks == nil) {
        cell.tasks = [[NSMutableArray alloc] init];
    } else {
        [cell.tasks removeAllObjects];
    }
    
    cell.userPhotoImageView.layer.cornerRadius = cell.userPhotoImageView.frame.size.width / 2;
    cell.userPhotoImageView.image = [UIImage imageNamed:@"no_photo"];
    if (post.postedBy.photo != nil) {
        NSURLSessionDataTask* task = [[NetworkManager sharedManager] getResizedImageWithName:post.postedBy.photo dimension:160 completionHandler:^(long statusCode, NSData *data) {
            if (statusCode == 200) {
                cell.userPhotoImageView.image = [UIImage imageWithData:data];
            }
        }];
        [cell.tasks addObject:task];
    }
    
    cell.userNameLabel.text = post.postedBy.name;
    if (post.postedBy.gender.id == 2) {
        cell.userGenderImageView.image = [UIImage imageNamed:@"icon_male"];
    } else if (post.postedBy.gender.id == 3) {
        cell.userGenderImageView.image = [UIImage imageNamed:@"icon_female"];
    } else {
        cell.userGenderImageView.image = [UIImage imageNamed:@"icon_no_gender"];
    }
    cell.userLevelLabel.text = [NSString stringWithFormat:@" LV.%d ", post.postedBy.level];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    cell.postDateLabel.text = [dateFormatter stringFromDate:post.postDate];
    
    cell.deleteButton.tag = indexPath.row;
    [cell.deleteButton addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    if (post.deleteable) {
        cell.deleteButton.hidden = NO;
    } else {
        cell.deleteButton.hidden = YES;
    }

    cell.contentLabel.text = post.content;
    
    [cell.imagesStackView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [cell.imagesStackView removeArrangedSubview:obj];
        [obj removeFromSuperview];
    }];
    
    if (post.imageItems != nil && post.imageItems.count > 0) {
        float width = self.view.frame.size.width - 16;
        for (ImageItem* image in post.imageItems) {
            if (image.name == nil || image.name.length < 10 || image.width < 10 || image.height < 10 ) {
                continue;
            }
            UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_image"]];
            imageView.tag = indexPath.row;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            imageView.userInteractionEnabled = YES;
            
            [cell.imagesStackView addArrangedSubview:imageView];
            
            [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [imageView.widthAnchor constraintEqualToConstant:width].active = YES;
            NSLayoutConstraint* constraint = [imageView.heightAnchor constraintEqualToConstant:width * image.height / image.width];
            constraint.priority = 999;
            constraint.active = YES;
            
            NSURLSessionDataTask* task = [[NetworkManager sharedManager] getResizedImageWithName:image.name width:width * UIScreen.mainScreen.scale completionHandler:^(long statusCode, NSData *data) {
                if (statusCode == 200) {
                    imageView.image = [UIImage imageWithData:data];
                }
            }];
            [cell.tasks addObject:task];
        }
    }
    
    return cell;
}

- (void)deleteButtonPressed:(UIButton*)sender {
    long row = sender.tag;
    NSString* postId = [_listItems objectAtIndex:row].id;
    NSString* url = [NSString stringWithFormat:@"post/%@", postId];
    NSLog(@"%@", url);
    [self.view makeToastActivity:CSToastPositionCenter];
    [[NetworkManager sharedManager] deleteDataWithUrl:url data:nil completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
        [self.view hideToastActivity];
        if (statusCode == 200) {
            [self loadWithToastActivity];
        } else {
            [self.view makeToast:errorMessage];
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PostItem* postItem = [_listItems objectAtIndex:indexPath.row];
    if (postItem.imageItems != nil && postItem.imageItems.count > 0) {

        NSMutableArray* viewingImages = [NSMutableArray array];
        for (ImageItem* image in postItem.imageItems) {
            ViewingImage* viewingImage = [[ViewingImage alloc] init];
            viewingImage.imageName = image.name;
            [viewingImages addObject:viewingImage];
        }
        NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:viewingImages];
        photosViewController.delegate = self;
        [self presentViewController:photosViewController animated:YES completion:nil];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - NYTPhotosViewControllerDelegate

/**
 *  Returns the maximum zoom scale for a given object conforming to the `NYTPhoto` protocol.
 *
 *  @param photosViewController The `NYTPhotosViewController` instance that sent the delegate message.
 *  @param photo                The photo for which the maximum zoom scale is requested.
 *
 *  @return The maximum zoom scale for the given photo.
 */
- (CGFloat)photosViewController:(NYTPhotosViewController *)photosViewController maximumZoomScaleForPhoto:(id <NYTPhoto>)photo {
    return 2.0f;
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

#pragma mark - pick image

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


#pragma mark - Keyboard notification

- (void)keyboardDidShow:(NSNotification *)sender {
    self.blockingViewTopConstraint.constant = 0;
    self.imagesCollectionView.hidden = YES;
    CGRect frame = [sender.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:0.1f animations:^{
        self.postContentBottomConstraint.constant = frame.size.height - self.imagesCollectionView.frame.size.height;
    }];
    CGSize sizeThatFitsTextView = [self.postContentTextView sizeThatFits:CGSizeMake(self.postContentTextView.frame.size.width, 100.0f)];
    self.postContentHeightConstraint.constant = MIN(sizeThatFitsTextView.height, 100.0f);
    
    [self.view layoutIfNeeded];
}

- (void)keyboardWillHide:(NSNotification *)sender {
    
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
//    NSLog(@"%@", textView.text);
    
    CGSize sizeThatFitsTextView = [self.postContentTextView sizeThatFits:CGSizeMake(self.postContentTextView.frame.size.width, 100.0f)];
    self.postContentHeightConstraint.constant = MIN(sizeThatFitsTextView.height, 100.0f);
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    
    return YES;
}


#pragma mark - submit buttons

- (IBAction)blockingViewTapped:(UITapGestureRecognizer *)sender {
    self.blockingViewTopConstraint.constant = self.view.frame.size.height;
    [self.postContentTextView resignFirstResponder];
    self.postContentHeightConstraint.constant = 30;
    self.imagesCollectionView.hidden = YES;
    self.postContentBottomConstraint.constant = -self.imagesCollectionView.frame.size.height;
}


- (IBAction)addImagesButtonPressed:(id)sender {
    if (self.imagesCollectionView.hidden) {
        self.imagesCollectionView.hidden = NO;
        [self.postContentTextView resignFirstResponder];
        self.blockingViewTopConstraint.constant = 0;
        [UIView animateWithDuration:0.1f animations:^{
            self.postContentBottomConstraint.constant = 0;
        }];
    } else {
        self.imagesCollectionView.hidden = YES;
        [self.postContentTextView becomeFirstResponder];
    }
}

- (IBAction)submitPostButtonPressed:(id)sender {
    _uploadedImageCount = 0;
    [_uploadedImageIds removeAllObjects];
    
    if (self.postContentTextView.text != nil && self.postContentTextView.text.length > 2) {
        [self.view makeToastActivity:CSToastPositionCenter];
        [self submitTopic];
    } else {
        [self.view makeToast:@"发帖内容不能为空"];
    }
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
        
        PostAdd* postAdd = [[PostAdd alloc] init];
        postAdd.topicId = _topicInfo.id;
        postAdd.content = self.postContentTextView.text;
        postAdd.imageIds = [_uploadedImageIds copy];
        
        NSLog(@"%@", postAdd);
        
        [[NetworkManager sharedManager] putDataWithUrl:@"post" data:[postAdd toJSONData] completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
            [self.view hideToastActivity];
            if (statusCode == 200) {
                self.postContentTextView.text = @"";
                [_selectedAssets removeAllObjects];
                [self.imagesCollectionView reloadData];
                self.blockingViewTopConstraint.constant = self.view.frame.size.height;
                [self.postContentTextView resignFirstResponder];
                self.postContentHeightConstraint.constant = 30;
                self.imagesCollectionView.hidden = YES;
                self.postContentBottomConstraint.constant = -104;
                
                [self loadWithToastActivity];
            } else {
                [self.view makeToast:errorMessage];
            }
        }];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushCreateTopic"]) {

    }
}

@end
