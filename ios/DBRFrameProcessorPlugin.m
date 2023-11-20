//
//  VisionCameraDBRPlugin.m
//  vision-camera-dynamsoft-barcode-reader
//
//  Created by xulihang on 2022/1/26.
//

#import <Foundation/Foundation.h>
#import <VisionCamera/FrameProcessorPlugin.h>
#import <VisionCamera/FrameProcessorPluginRegistry.h>
#import "VisionCameraDynamsoftBarcodeReader-Bridging-Header.h"
#import "DBRFrameProcessorPlugin.h"

@interface DBRFrameProcessorPlugin (FrameProcessorPluginLoader)
@end

@implementation DBRFrameProcessorPlugin (FrameProcessorPluginLoader)

+ (void)load
{
  [FrameProcessorPluginRegistry addFrameProcessorPlugin:@"decode"
                                        withInitializer:^FrameProcessorPlugin* (NSDictionary* options) {
    return [[DBRFrameProcessorPlugin alloc] init];
  }];
}

@end

