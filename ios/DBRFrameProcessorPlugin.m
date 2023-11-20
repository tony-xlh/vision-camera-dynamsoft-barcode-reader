//
//  VisionCameraDBRPlugin.m
//  vision-camera-dynamsoft-barcode-reader
//
//  Created by xulihang on 2022/1/26.
//

#import <Foundation/Foundation.h>
#import <VisionCamera/FrameProcessorPlugin.h>
#import <VisionCamera/FrameProcessorPluginRegistry.h>
#import <VisionCamera/Frame.h>
#import "DBRFrameProcessorPlugin.h"
// Example for an Objective-C Frame Processor plugin
@interface ExampleFrameProcessorPlugin : FrameProcessorPlugin
@end

@implementation ExampleFrameProcessorPlugin

- (instancetype)initWithOptions:(NSDictionary* _Nullable)options
{
  self = [super initWithOptions:options];
  NSLog(@"ExampleFrameProcessorPlugin initialized with options: %@", options);
  return self;
}

- (id)callback:(Frame *)frame withArguments:(NSDictionary *)arguments {
  CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(frame.buffer);
  NSLog(@"ExamplePlugin: %zu x %zu Image. Logging %lu parameters:", CVPixelBufferGetWidth(imageBuffer), CVPixelBufferGetHeight(imageBuffer), (unsigned long)arguments.count);

  for (id param in arguments) {
    NSLog(@"ExamplePlugin:   -> %@ (%@)", param == nil ? @"(nil)" : [param description], NSStringFromClass([param classForCoder]));
  }

    return @[];
}

VISION_EXPORT_FRAME_PROCESSOR(ExampleFrameProcessorPlugin, decode)

@end
