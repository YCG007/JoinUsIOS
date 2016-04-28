//
//  CreateForumStepTwoViewController.m
//  JoinUs
//
//  Created by Liang Qian on 23/4/2016.
//  Copyright © 2016 North Gate Code. All rights reserved.
//

#import "CreateForumStepTwoViewController.h"
#import "Utils.h"
#import "NetworkManager.h"
#import "CreateForumStepThreeViewController.h"

@interface CreateForumStepTwoViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UICollectionView *categoryCollectionView;

@end

@implementation CreateForumStepTwoViewController {
    NSArray* _categories;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.forumAdd.iconImage != nil) {
        self.iconImageView.image = self.forumAdd.iconImage;
    } else {
        self.iconImageView.image = [UIImage imageNamed:@"no_photo"];
    }
}
- (IBAction)chooseImageButtonPressed:(id)sender {
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
    
    self.iconImageView.image = pickedImage;
    self.forumAdd.iconImage = pickedImage;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)nextStepButtonPressed:(id)sender {
[self performSegueWithIdentifier:@"PushStepThree" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushStepThree"]) {
        CreateForumStepThreeViewController* createForumStepThreeViewController = segue.destinationViewController;
        createForumStepThreeViewController.forumAdd = self.forumAdd;
    }
}


@end
