#import <Foundation/Foundation.h>
#import <VisionCamera/FrameProcessorPlugin.h>
#import <VisionCamera/FrameProcessorPluginRegistry.h>

#import "VisionCameraDynamsoftBarcodeReader-Swift.h"

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
