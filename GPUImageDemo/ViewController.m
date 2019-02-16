//
//  ViewController.m
//  GPUImageDemo
//
//  Created by 王昌阳 on 2019/2/16.
//  Copyright © 2019 王昌阳. All rights reserved.
//

#import "ViewController.h"
#import <GPUImage.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <Photos/Photos.h>

@interface ViewController ()

@property (nonatomic, strong) GPUImageStillCamera *videoCamera;
@property (nonatomic, strong) GPUImageView *imageView;

@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _videoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    _videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    
    GPUImageView *filteredVideoView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:filteredVideoView atIndex:0];
    filteredVideoView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    _imageView = filteredVideoView;
    [_videoCamera addTarget:filteredVideoView];

    [_videoCamera startCameraCapture];
}

- (IBAction)changeCameraPosition:(id)sender {
    [_videoCamera rotateCamera];
}

- (IBAction)recordBtnClicked:(id)sender {
    UIButton *recordBtn = (UIButton *)sender;
    recordBtn.selected = !recordBtn.isSelected;
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    if (recordBtn.isSelected) {
        // 开始录制
        unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
        NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
        _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
        _movieWriter.encodingLiveVideo = YES;
        [_videoCamera addTarget:_movieWriter];
        _videoCamera.audioEncodingTarget = _movieWriter;
        [_movieWriter startRecording];
    } else {
        // 结束录制
        _videoCamera.audioEncodingTarget = nil;
        [_movieWriter finishRecording];
        NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
        AVAsset *videoAsset = [AVAsset assetWithURL:movieURL];
        if ([videoAsset isCompatibleWithSavedPhotosAlbum])
        {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:movieURL];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"
                                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"
                                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                    }
                });
            }];
        } else {
            NSLog(@"xxxxx");
        }
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
