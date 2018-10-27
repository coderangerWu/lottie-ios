//
//  LOTAsset.h
//  Pods
//
//  Created by Brandon Withrow on 2/16/17.
//
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@class LOTLayerGroup;
@class LOTLayer;
@class LOTAssetGroup;

@interface LOTAsset : NSObject

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary
              withAssetGroup:(LOTAssetGroup * _Nullable)assetGroup
             withAssetBundle:(NSBundle *_Nonnull)bundle
               withFramerate:(NSNumber *)framerate;

@property (nonatomic, readonly, nullable) NSString *referenceID;
@property (nonatomic, readonly, nullable) NSNumber *assetWidth;
@property (nonatomic, readonly, nullable) NSNumber *assetHeight;

@property (nonatomic, readonly, nullable) NSString *imageName;
@property (nonatomic, readonly, nullable) NSString *imageDirectory;

@property (nonatomic, readonly, nullable) LOTLayerGroup *layerGroup;

@property (nonatomic, readwrite) NSString *rootDirectory;
@property (nonatomic, readonly) NSBundle *assetBundle;

#pragma mark - Template
@property (nonatomic, readonly, nullable) NSString *videoName;
- (UIImage*)defaultImage;
@property (nonatomic, strong) UIImage* thumbnail;
@property (nonatomic, strong) UIImage* assetImage;
@property (nonatomic, strong) AVAsset* assetVideo;
@property (nonatomic, readwrite) BOOL immutable;

@end

NS_ASSUME_NONNULL_END
