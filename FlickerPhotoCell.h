//
//  FlickerPhotoCell.h
//  FavoritePhotos
//
//  Created by Fletcher Rhoads on 1/27/14.
//  Copyright (c) 2014 Fletcher Rhoads. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickerPhotoCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property BOOL isSelected;

@end
