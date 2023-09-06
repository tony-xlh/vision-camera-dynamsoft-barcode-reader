//
//  FaceDetectorFrameProcessorPlugin.m
//  VisionCameraDynamsoftBarcodeReader
//
//  Created by xulihang on 2023/9/6.
//  Copyright © 2023 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VisionCamera/FrameProcessorPlugin.h>
#import <VisionCamera/FrameProcessorPluginRegistry.h>
#import <VisionCamera/Frame.h>

@interface FaceDetectorFrameProcessorPlugin : FrameProcessorPlugin
@end

@implementation FaceDetectorFrameProcessorPlugin

- (instancetype) initWithOptions:(NSDictionary*)options; {
  self = [super init];
  return self;
}

- (id)callback:(Frame*)frame withArguments:(NSDictionary*)arguments {
  CMSampleBufferRef buffer = frame.buffer;
  UIImageOrientation orientation = frame.orientation;
  // code goes here
    return @[@{@"barcodeText":@"test"}];
}

+ (void) load {
  [FrameProcessorPluginRegistry addFrameProcessorPlugin:@"decode"
                                        withInitializer:^FrameProcessorPlugin*(NSDictionary* options) {
    return [[FaceDetectorFrameProcessorPlugin alloc] initWithOptions:options];
  }];
}

@end
