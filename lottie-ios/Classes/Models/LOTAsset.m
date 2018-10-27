//
//  LOTAsset.m
//  Pods
//
//  Created by Brandon Withrow on 2/16/17.
//
//

#import "LOTAsset.h"
#import "LOTLayer.h"
#import "LOTLayerGroup.h"
#import "LOTAssetGroup.h"
#import "LOTCacheProvider.h"

@implementation LOTAsset

- (instancetype)initWithJSON:(NSDictionary *)jsonDictionary
              withAssetGroup:(LOTAssetGroup * _Nullable)assetGroup
             withAssetBundle:(NSBundle *_Nonnull)bundle
               withFramerate:(NSNumber *)framerate {
  self = [super init];
  if (self) {
    _assetBundle = bundle;
    [self _mapFromJSON:jsonDictionary
        withAssetGroup:assetGroup
     withFramerate:framerate];
  }
  return self;
}

- (void)_mapFromJSON:(NSDictionary *)jsonDictionary
      withAssetGroup:(LOTAssetGroup * _Nullable)assetGroup
       withFramerate:(NSNumber *)framerate {
  _referenceID = [jsonDictionary[@"id"] copy];
  
  if (jsonDictionary[@"w"]) {
    _assetWidth = [jsonDictionary[@"w"] copy];
  }
  
  if (jsonDictionary[@"h"]) {
    _assetHeight = [jsonDictionary[@"h"] copy];
  }
  
  if (jsonDictionary[@"u"]) {
    _imageDirectory = [jsonDictionary[@"u"] copy];
  }
  
  if (jsonDictionary[@"p"]) {
    _imageName = [jsonDictionary[@"p"] copy];
  }

  _immutable = [jsonDictionary[@"immutable"] boolValue];

  if ([jsonDictionary[@"videoPath"] length]) {
      _videoName = [jsonDictionary[@"videoPath"] copy];
  }
    
  NSArray *layersJSON = jsonDictionary[@"layers"];
  if (layersJSON) {
    _layerGroup = [[LOTLayerGroup alloc] initWithLayerJSON:layersJSON
                                            withAssetGroup:assetGroup
                                             withFramerate:framerate];
  }
}

- (UIImage *)defaultImage
{
    UIImage *image = nil;
    AVAsset* video = nil;
    if (self.assetImage) {
        image = self.assetImage;
    } else if (self.assetVideo) {
        video = self.assetVideo;
    } else if (self.imageName && self.imageName.length>0) {
        if (self.rootDirectory.length > 0) {
            NSString *rootDirectory  = self.rootDirectory;
            if (self.imageDirectory.length > 0) {
                rootDirectory = [rootDirectory stringByAppendingPathComponent:self.imageDirectory];
            }
            NSString *imagePath = [rootDirectory stringByAppendingPathComponent:self.imageName];
            
            id<LOTImageCache> imageCache = [LOTCacheProvider imageCache];
            if (imageCache) {
                image = [imageCache imageForKey:imagePath];
                if (!image) {
                    image = [UIImage imageWithContentsOfFile:imagePath];
                    [imageCache setImage:image forKey:imagePath];
                }
            } else {
                image = [UIImage imageWithContentsOfFile:imagePath];
            }
        } else {
            NSString *imagePath = [self.assetBundle pathForResource:self.imageName ofType:nil];
            image = [UIImage imageWithContentsOfFile:imagePath];
            if(!image) {
                image = [UIImage imageNamed:self.imageName inBundle: self.assetBundle compatibleWithTraitCollection:nil];
            }
        }
    } else if (self.videoName && self.videoName.length>0) {
        if (self.rootDirectory.length > 0) {
            NSString *rootDirectory  = self.rootDirectory;
            if (self.imageDirectory.length > 0) {
                rootDirectory = [rootDirectory stringByAppendingPathComponent:self.imageDirectory];
            }
            NSString *videoPath = [rootDirectory stringByAppendingPathComponent:self.videoName];
            NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
            video = [AVAsset assetWithURL:videoURL];
        } else {
            NSString *videoPath = [self.assetBundle pathForResource:self.videoName ofType:nil];
            NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
            video = [AVAsset assetWithURL:videoURL];
        }
    }
    
    return image?:[self imageFromVideo:video];
}

- (UIImage *)imageFromVideo:(AVAsset *)video
{
    if (!video) return nil;
    
    AVAssetImageGenerator *generate = [AVAssetImageGenerator assetImageGeneratorWithAsset:video];
    
    CMTime time= CMTimeMakeWithSeconds(1, video.preferredRate);
    CMTime actualTime;
    NSError *error = nil;
    CGImageRef cgImage= [generate copyCGImageAtTime:time actualTime:&actualTime error:&error];
    if(error) return nil;
    
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return image;
}
@end
