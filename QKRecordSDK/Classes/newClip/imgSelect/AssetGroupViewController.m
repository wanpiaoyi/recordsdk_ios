
//  AssetGroupViewController.m
//  PingTu
//
//  Created by Yangfan on 15/2/4.
//  Copyright (c) 2015年 4gread. All rights reserved.
//

#import "AssetGroupViewController.h"
#import "AssetPickerController.h"
#import "AssetGroupViewCell.h"
#import "AssetForOneGroupViewController.h"
#import "ClipPubThings.h"

@interface AssetGroupViewController ()

@end

@implementation AssetGroupViewController

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (@available(iOS 13.0, *)) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDarkContent];

    }else{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillAppear:animated];    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self setupButtons];
    [self setupGroup];
}

// 设置TableView
- (void)setupViews {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setTitle:@"文件"];
    
    // 用来填补空白
    UIView *blackView = [[UIView alloc] init];
    [blackView setFrame:CGRectMake(0, 0, 100, 100)];
    [blackView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:blackView];
    
    self.tableView = [[UITableView alloc]
                      initWithFrame:CGRectMake(0, 64, kScreen_Width, kScreen_Height - 64 - clipPubthings.deleteBottom)
                      style:UITableViewStylePlain];
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 69;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
}

// 设置是否有取消按钮
- (void)setupButtons {
    AssetPickerController *picker =
    (AssetPickerController *)self.navigationController;
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithImage:[clipPubthings imageNamed:@"nav_bar_back_btn"] style:UIBarButtonItemStylePlain target:self action:@selector(dismiss:)];
}

// 开始了！
- (void)setupGroup {
    if (!self.assetsLibrary) {
        self.assetsLibrary = [self.class defaultAssetsLibrary];
    }
    
    if (!self.groups) {
        self.groups = [[NSMutableArray alloc] init];
    } else {
        [self.groups removeAllObjects];
    }
    
    AssetPickerController *picker =
    (AssetPickerController *)self.navigationController;
    ALAssetsFilter *assetsFilter = picker.assetsFilter;
    BOOL showImgs = picker.showImages;
    BOOL showVideo = picker.showVideo;
    WS(weakSelf);
    // 供下面的回调使用的
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        [weakSelf showNotAllowed];
    };
    
    
        // 供下面的回调使用的
        ALAssetsLibraryGroupsEnumerationResultsBlock resultsBlock =
        ^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                [group setAssetsFilter:[ALAssetsFilter allAssets]];
                if(showImgs&&showVideo){
                    [weakSelf.groups addObject:group];
                }
                [weakSelf.groups addObject:group];
            } else {
                [weakSelf reloadData];
            }
        };
        

        // Enumerate Camera roll first
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                          usingBlock:resultsBlock
                                        failureBlock:failureBlock];
    
    
    
    // 供下面的回调使用的
    ALAssetsLibraryGroupsEnumerationResultsBlock resultsBlock1 =
    ^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group setAssetsFilter:assetsFilter];
            if (group.numberOfAssets > 0 || picker.showEmptyGroups){
                [weakSelf.groups addObject:group];
            }
        } else {
            [weakSelf reloadData];
        }
    };
    // Then all other groups
    NSUInteger type =   ALAssetsGroupLibrary | ALAssetsGroupAlbum |
    ALAssetsGroupEvent | ALAssetsGroupFaces |
    ALAssetsGroupPhotoStream;
    
    [self.assetsLibrary enumerateGroupsWithTypes:type
                                      usingBlock:resultsBlock1
                                    failureBlock:failureBlock];
}

#pragma mark - Reload Data

- (void)reloadData {
    if (self.groups.count == 0) {
        [self showNoAssets];
    }
    [self.tableView reloadData];
}

#pragma mark - ALAssetsLibrary
+ (ALAssetsLibrary *)defaultAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

#pragma mark - Not allowed / No assets
- (void)showNotAllowed {
    UILabel *notAllowLabel = [[UILabel alloc] init];
    [notAllowLabel setNumberOfLines:0];
    [notAllowLabel setTextAlignment:NSTextAlignmentCenter];
    [notAllowLabel setBackgroundColor:[UIColor clearColor]];
    [notAllowLabel setFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
    [notAllowLabel setText:@"应"
     @"用无法使用您的视频。\n您可以在「隐私设"
     @"置」" @"中启用存取。"];
    [self.view addSubview:notAllowLabel];
}

- (void)showNoAssets {
    UILabel *noAssetsLabel = [[UILabel alloc] init];
    [noAssetsLabel setNumberOfLines:0];
    [noAssetsLabel setTextAlignment:NSTextAlignmentCenter];
    [noAssetsLabel setBackgroundColor:[UIColor clearColor]];
    [noAssetsLabel setFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
    [noAssetsLabel setText:@"没有视频。\n您可以使用 iTunes "
     @"将视频同步到iPhone。"];
    [self.view addSubview:noAssetsLabel];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    AssetGroupViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[clipPubthings clipBundle] loadNibNamed:@"AssetGroupViewCell"
                                              owner:nil
                                            options:nil] firstObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    ALAssetsGroup *assetsGroup = [self.groups objectAtIndex:indexPath.row];
//        NSLog(@"[ALAssetsFilter allAssets]4");
    AssetPickerController *picker =
    (AssetPickerController *)self.navigationController;

    if(indexPath.row == 0){
        BOOL showImgs = picker.showImages;
        BOOL showVideo = picker.showVideo;
        if(showVideo&&showImgs){
            [assetsGroup setAssetsFilter:[ALAssetsFilter allVideos]];
            [cell bind:assetsGroup isVideo:YES];
        }else{
            [assetsGroup setAssetsFilter:picker.assetsFilter];
            [cell bind:assetsGroup isVideo:NO];
        }
    }else{
        [assetsGroup setAssetsFilter:picker.assetsFilter];

        [cell bind:assetsGroup isVideo:NO];
    }
    

    
    return cell;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AssetPickerController *picker =
    (AssetPickerController *)self.navigationController;
    ALAssetsGroup *assetsGroup = [self.groups objectAtIndex:indexPath.row];

    if(indexPath.row == 0){
        BOOL showImgs = picker.showImages;
        BOOL showVideo = picker.showVideo;
        if(showVideo&&showImgs){
            [assetsGroup setAssetsFilter:[ALAssetsFilter allVideos]];
        }else{
            [assetsGroup setAssetsFilter:picker.assetsFilter];
        }
    }else{
        [assetsGroup setAssetsFilter:picker.assetsFilter];
    }

    AssetForOneGroupViewController *vc = [[AssetForOneGroupViewController alloc]
                                          initWithNibName:@"AssetForOneGroupViewController"
                                          bundle:[clipPubthings clipBundle]];
    vc.assetsGroup = assetsGroup;
    vc.selectAssetsArray = _selectAssetsArray;
    if(indexPath.row == 0){
    BOOL showImgs = picker.showImages;
    BOOL showVideo = picker.showVideo;
        if(showVideo&&showImgs){
            vc.name = @"视频";
        }else{
            vc.name = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
        }
    }else{
        vc.name = [assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    }
    
    [vc setSaveSelectPicBlock:^(NSMutableArray *array) {
        _selectAssetsArray = array;
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Actions
- (void)dismiss:(id)sender {
    AssetPickerController *picker =
    (AssetPickerController *)self.navigationController;
    [picker.presentingViewController dismissViewControllerAnimated:YES
                                                        completion:NULL];
}

@end
