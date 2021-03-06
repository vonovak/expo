/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI40_0_0RCTPhotoLibraryImageLoader.h"

#import <Photos/Photos.h>
#import <ABI40_0_0React/ABI40_0_0RCTLog.h>
#import <ABI40_0_0React/ABI40_0_0RCTUtils.h>
#import <ABI40_0_0ReactCommon/ABI40_0_0RCTTurboModule.h>

#import "ABI40_0_0RCTCameraRollPlugins.h"

@interface ABI40_0_0RCTPhotoLibraryImageLoader () <ABI40_0_0RCTTurboModule>
@end

@implementation ABI40_0_0RCTPhotoLibraryImageLoader

ABI40_0_0RCT_EXPORT_MODULE()

@synthesize bridge = _bridge;

#pragma mark - ABI40_0_0RCTImageLoader

- (BOOL)canLoadImageURL:(NSURL *)requestURL
{
  if (![PHAsset class]) {
    return NO;
  }
  return [requestURL.scheme caseInsensitiveCompare:@"assets-library"] == NSOrderedSame ||
    [requestURL.scheme caseInsensitiveCompare:@"ph"] == NSOrderedSame;
}

- (ABI40_0_0RCTImageLoaderCancellationBlock)loadImageForURL:(NSURL *)imageURL
                                              size:(CGSize)size
                                             scale:(CGFloat)scale
                                        resizeMode:(ABI40_0_0RCTResizeMode)resizeMode
                                   progressHandler:(ABI40_0_0RCTImageLoaderProgressBlock)progressHandler
                                partialLoadHandler:(ABI40_0_0RCTImageLoaderPartialLoadBlock)partialLoadHandler
                                 completionHandler:(ABI40_0_0RCTImageLoaderCompletionBlock)completionHandler
{
  // Using PhotoKit for iOS 8+
  // The 'ph://' prefix is used by FBMediaKit to differentiate between
  // assets-library. It is prepended to the local ID so that it is in the
  // form of an NSURL which is what assets-library uses.
  NSString *assetID = @"";
  PHFetchResult *results;
  if (!imageURL) {
    completionHandler(ABI40_0_0RCTErrorWithMessage(@"Cannot load a photo library asset with no URL"), nil);
    return ^{};
  } else if ([imageURL.scheme caseInsensitiveCompare:@"assets-library"] == NSOrderedSame) {
    assetID = [imageURL absoluteString];
    results = [PHAsset fetchAssetsWithALAssetURLs:@[imageURL] options:nil];
  } else {
    assetID = [imageURL.absoluteString substringFromIndex:@"ph://".length];
    results = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetID] options:nil];
  }
  if (results.count == 0) {
    NSString *errorText = [NSString stringWithFormat:@"Failed to fetch PHAsset with local identifier %@ with no error message.", assetID];
    completionHandler(ABI40_0_0RCTErrorWithMessage(errorText), nil);
    return ^{};
  }

  PHAsset *asset = [results firstObject];
  PHImageRequestOptions *imageOptions = [PHImageRequestOptions new];

  // Allow PhotoKit to fetch images from iCloud
  imageOptions.networkAccessAllowed = YES;

  if (progressHandler) {
    imageOptions.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary<NSString *, id> *info) {
      static const double multiplier = 1e6;
      progressHandler(progress * multiplier, multiplier);
    };
  }

  // Note: PhotoKit defaults to a deliveryMode of PHImageRequestOptionsDeliveryModeOpportunistic
  // which means it may call back multiple times - we probably don't want that
  imageOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;

  BOOL useMaximumSize = CGSizeEqualToSize(size, CGSizeZero);
  CGSize targetSize;
  if (useMaximumSize) {
    targetSize = PHImageManagerMaximumSize;
    imageOptions.resizeMode = PHImageRequestOptionsResizeModeNone;
  } else {
    targetSize = CGSizeApplyAffineTransform(size, CGAffineTransformMakeScale(scale, scale));
    imageOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
  }

  PHImageContentMode contentMode = PHImageContentModeAspectFill;
  if (resizeMode == ABI40_0_0RCTResizeModeContain) {
    contentMode = PHImageContentModeAspectFit;
  }

  PHImageRequestID requestID =
  [[PHImageManager defaultManager] requestImageForAsset:asset
                                             targetSize:targetSize
                                            contentMode:contentMode
                                                options:imageOptions
                                          resultHandler:^(UIImage *result, NSDictionary<NSString *, id> *info) {
    if (result) {
      completionHandler(nil, result);
    } else {
      completionHandler(info[PHImageErrorKey], nil);
    }
  }];

  return ^{
    [[PHImageManager defaultManager] cancelImageRequest:requestID];
  };
}

@end

Class ABI40_0_0RCTPhotoLibraryImageLoaderCls(void) {
  return ABI40_0_0RCTPhotoLibraryImageLoader.class;
}
