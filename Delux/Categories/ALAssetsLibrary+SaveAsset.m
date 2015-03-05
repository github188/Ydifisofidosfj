//
//  ALAssetsLibrary+SaveAsset.m
//
//  Created by Darktt on 13/7/24.
//  Copyright (c) 2013 Darktt Personal Company. All rights reserved.
//

#import <AssetsLibrary/ALAssetsGroup.h>
#import "ALAssetsLibrary+SaveAsset.h"

@implementation ALAssetsLibrary (SaveAsset)

- (void)saveImageToAlbumWithImage:(UIImage *)image album:(NSString *)albumName completionBlock:(ALAssetsLibrarySaveCompletionBlock)completionBlock
{
    ALAssetsLibraryWriteImageCompletionBlock _completionBlock = ^(NSURL *assetURL, NSError *error){
        if (error != nil) {
            completionBlock(error);
            return;
        }
      
        [self addAssetToAlbumWithAssetURL:assetURL album:albumName completionBlock:completionBlock];
    };
    
    [self writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:_completionBlock];
}

- (void)addAssetToAlbumWithAssetURL:(NSURL *)assetURL album:(NSString *)albumName completionBlock:(ALAssetsLibrarySaveCompletionBlock)completionBlock
{
    __block BOOL albumFound = NO;
    
    ALAssetsLibraryGroupsEnumerationResultsBlock resultBlock = ^(ALAssetsGroup *group, BOOL *stop){
        if (group == nil) {
            
            if (!albumFound) {
                
                NSError *error = [NSError errorWithDomain:@"Album Not Found!!" code:ALAssetsLibraryWriteFailedError userInfo:nil];
                
                completionBlock(error);
            }
            
            return;
        }
        
        NSString *groupAlbumName = [group valueForProperty:ALAssetsGroupPropertyName];
        
        if ([albumName compare:groupAlbumName] != NSOrderedSame) {
            return;
        }
        
        albumFound = YES;
        *stop = YES;
        
        // If album name same and album is "camera roll" or "saved photos" ignore save to album;
        ALAssetsGroupType groupType = [[group valueForProperty:ALAssetsGroupPropertyType] integerValue];
        if (groupType == ALAssetsGroupSavedPhotos) {
            completionBlock(nil);
            return;
        }
        
        ALAssetsLibraryAssetForURLResultBlock result = ^(ALAsset *asset){
            [group addAsset:asset];
            
            completionBlock(nil);
        };
        
        [self assetForURL:assetURL resultBlock:result failureBlock:completionBlock];
    };
    
    ALAssetsGroupType groupType = ALAssetsGroupAlbum | ALAssetsGroupSavedPhotos;
    [self enumerateGroupsWithTypes:groupType usingBlock:resultBlock failureBlock:completionBlock];
}

@end
