//  ViewController.m
//  FavoritePhotos
//
//  Created by Fletcher Rhoads on 1/27/14.
//  Copyright (c) 2014 Fletcher Rhoads. All rights reserved.

#import "ViewController.h"
#import "FlickerPhotoCell.h"
#define flikrAPIKey @"645eea2a5e67ccc928a9c8fe11f7c51b"

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
{
    __weak IBOutlet UICollectionView *flickerCollectionView;
    __weak IBOutlet UISearchBar *searchBar;
    __weak IBOutlet UIButton *searchButton;
    
    NSArray *flickrPhotosArray;
    NSMutableArray *flickrPhotoURLs;
    NSString *searchString;
    NSMutableArray *flickrFavs;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    flickrFavs = [NSMutableArray new];
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)pullPhotosFromFlikr
{
    NSURL *searchURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.search&text=%@&sort=relevance&safe_search=2&api_key=%@&format=json&nojsoncallback=1", searchString, flikrAPIKey]];
    NSURLRequest *flickrRequest = [NSURLRequest requestWithURL:searchURL];
    [NSURLConnection sendAsynchronousRequest:flickrRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        flickrPhotosArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError][@"photos"][@"photo"];
        flickrPhotoURLs = [NSMutableArray arrayWithCapacity:flickrPhotosArray.count];
        
        for (NSDictionary *photo in flickrPhotosArray)
        {
            NSNumber *farm = photo[@"farm"];
            NSString *eyedee = photo[@"id"];
            NSString *secret = photo[@"secret"];
            NSString *server = photo[@"server"];
            NSString *photoURL = [NSString stringWithFormat: @"http://farm%@.staticflickr.com/%@/%@_%@.jpg", farm, server, eyedee, secret];
            [flickrPhotoURLs addObject:photoURL];
        }
        [flickerCollectionView reloadData];
    }];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FlickerPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FlickrCell" forIndexPath:indexPath];
 //   if (cell == nil) {
//        cell = [[[UICollectionViewCell alloc] initWithStyle: UICollectionViewCell
//                                       reuseIdentifier: CellIdentifier];
    cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[flickrPhotoURLs objectAtIndex:indexPath.row]]]];
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (flickrPhotoURLs.count > 10) {
        return 10;
    }else{
        return flickrPhotoURLs.count;
    }
}

- (IBAction)onSearchButtonTapped:(id)sender
{
    searchString = searchBar.text;
    
    [self pullPhotosFromFlikr];
    
    [searchBar resignFirstResponder];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FlickerPhotoCell *cell = (FlickerPhotoCell*)[collectionView cellForItemAtIndexPath:indexPath];
    if (!cell.isSelected) {
        cell.contentView.backgroundColor = [UIColor yellowColor];
        cell.isSelected = YES;
        [flickrFavs addObject:cell.imageView.image];
        }else{
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        cell.contentView.backgroundColor = [UIColor blackColor];
        [flickrFavs removeObject:cell.imageView.image];
        cell.isSelected = NO;
    }
}

-(NSURL*) documentDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
}

-(void)save
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSURL *plist = [[self documentDirectory] URLByAppendingPathComponent:@"faves.plist"];
    [flickrFavs writeToURL:plist atomically:YES];
    NSLog(@"plist = %@", plist);
    
    [userDefaults setObject:[NSDate date] forKey:@"last save"];
    [userDefaults synchronize];
}

-(void)load
{
    NSURL *plist = [[self documentDirectory] URLByAppendingPathComponent:@"faves.plist"];
    flickrFavs = [NSMutableArray arrayWithContentsOfURL:plist] ?: [NSMutableArray new];
}

-(IBAction)unwindFromSearchTab:(UITabBar)segue
{
    
}


-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if ([item.title isEqualToString:@"Search"])
        
    if ([item.title isEqualToString:@"Favorites"])
}


@end
