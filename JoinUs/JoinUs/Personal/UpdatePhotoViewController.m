//
//  UpdatePhotoViewController.m
//  JoinUs
//
//  Created by Liang Qian on 9/4/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "UpdatePhotoViewController.h"
#import "Utils.h"
#import "NetworkManager.h"

@interface UpdatePhotoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@end

@implementation UpdatePhotoViewController {
    BOOL _isNewImagePicked;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _isNewImagePicked = NO;
    
    self.submitButton.enabled = NO;
    self.submitButton.backgroundColor = [UIColor lightGrayColor];
    
    UserProfile* myProfile = [[NetworkManager sharedManager] myProfile];
    if (myProfile.photo) {
        [[NetworkManager sharedManager] getResizedImageWithName:myProfile.photo dimension:320 completionHandler:^(long statusCode, NSData *data) {
            if (statusCode == 200) {
                self.photoImageView.image = [UIImage imageWithData:data];
            }
        }];
    } else {
        self.photoImageView.image = [UIImage imageNamed:@"no_photo"];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.photoImageView.layer.cornerRadius = self.photoImageView.frame.size.width / 2;
    self.photoImageView.layer.borderWidth = 4;
    self.photoImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (IBAction)pickImageButtonPressed:(id)sender {
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* takeNewPhotoAlertAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePicker animated:YES completion:nil];
        } else {
            NSLog(@"NO CAMERA!");
        }
    }];
    
    UIAlertAction* pickFromLibraryAlertAction = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }];
    
    UIAlertAction* cancelAlertAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Alert Action: Cancel!");
    }];
    
    [alertController addAction:takeNewPhotoAlertAction];
    [alertController addAction:pickFromLibraryAlertAction];
    [alertController addAction:cancelAlertAction];
    
    [self presentViewController:alertController animated:YES completion:nil];

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage* pickedImage = info[UIImagePickerControllerEditedImage];
    
    NSLog(@"Image width: %f, height: %f", pickedImage.size.width, pickedImage.size.height);
    
    self.photoImageView.image = pickedImage;
    
    _isNewImagePicked = YES;
    
    self.submitButton.enabled = YES;
    self.submitButton.backgroundColor = [UIColor colorForButtonParimary];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)submitButtonPressed:(id)sender {
    
    if (_isNewImagePicked) {
        [self.view makeToastActivity:CSToastPositionCenter];
        
        NSData* imageData = UIImageJPEGRepresentation(self.photoImageView.image, 0.9);
        [[NetworkManager sharedManager] uploadImageWithUrl:@"myProfile/photo" data:imageData completionHandler:^(long statusCode, NSData *data, NSString *errorMessage) {
            [self.view hideToastActivity];
            if (statusCode == 200) {
                NSError *error;
                UserProfile* myProfile = [[UserProfile alloc] initWithData:data error:&error];
                if (error != nil) NSLog(@"%@", error);
                
                [[NetworkManager sharedManager] setMyProfile:myProfile];
                //                NSLog(@"%@", myProfile);
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                [self.view makeToast:errorMessage];
            }
        }];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
