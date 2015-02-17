//
//  fileBrowserViewController.m
//  IM
//
//  Created by 郭志伟 on 15-2-16.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "fileBrowserViewController.h"
#import "fileBrowserSelectTableViewCell.h"
#import "utils.h"
#import "UIImage+Common.h"
#import "fileBrowserSelectCellModel.h"
#import "NSDate+Common.h"

#define IS_IPHONE_4 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)480) < DBL_EPSILON)
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6_PLUS (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)

typedef NS_ENUM(UInt32, fileBrowserViewControllerType) {
    fileBrowserViewControllerTypeAll,
    fileBrowserViewControllerTypeDoc,
    fileBrowserViewControllerTypeImg,
    fileBrowserViewControllerTypeVideo,
    fileBrowserViewControllerTypeMusic
};

@interface fileBrowserViewController ()<UITableViewDataSource, UITableViewDelegate> {
    NSArray *m_allFiles;
    fileBrowserViewControllerType m_type;
    NSMutableArray *m_model;
    NSMutableDictionary *m_selectedFiles;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *allBarBtnItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *docBarBtnItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *imgBarBtnItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *videoBtnItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *musicBtnItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *statusBtnItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendBtnItem;

@end

@implementation fileBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    // Do any additional setup after loading the view.
    m_type = fileBrowserViewControllerTypeAll;
    self.sendBtnItem.enabled = NO;
    NSString *docPath = [Utils documentPath];
    self.filesPath = [docPath stringByAppendingPathComponent:@"gzw/files"];
    m_allFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.filesPath error:nil];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return ![evaluatedObject hasSuffix:@".jpg_thumb"];
    }];
    m_allFiles = [m_allFiles filteredArrayUsingPredicate:predicate];
    m_selectedFiles = [[NSMutableDictionary alloc] init];
    [self buildModel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)buildModel {
    m_model = [[NSMutableArray alloc] init];
    if (m_type == fileBrowserViewControllerTypeAll) {
        [m_allFiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *fileName = obj;
            fileBrowserSelectCellModel *cellModel = [[fileBrowserSelectCellModel alloc] init];
            cellModel.fileName = fileName;
            if ([m_selectedFiles objectForKey:fileName]) {
                cellModel.selected = YES;
            } else {
                cellModel.selected = NO;
            }
            
            [m_model addObject:cellModel];
        }];
    } else if (m_type == fileBrowserViewControllerTypeDoc) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject hasSuffix:@".doc"]
            || [evaluatedObject hasSuffix:@".docx"]
            || [evaluatedObject hasSuffix:@".xls"]
            || [evaluatedObject hasSuffix:@".ppt"];
        }];
        
        NSArray *docFiles = [m_allFiles filteredArrayUsingPredicate:predicate];
        [docFiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *fileName = obj;
            fileBrowserSelectCellModel *cellModel = [[fileBrowserSelectCellModel alloc] init];
            cellModel.fileName = fileName;
            if ([m_selectedFiles objectForKey:fileName]) {
                cellModel.selected = YES;
            } else {
                cellModel.selected = NO;
            }
            
            [m_model addObject:cellModel];
        }];
        
    } else if (m_type == fileBrowserViewControllerTypeImg) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject hasSuffix:@".jpg"]
            || [evaluatedObject hasSuffix:@".png"];
        }];
        
        NSArray *imgFiles = [m_allFiles filteredArrayUsingPredicate:predicate];
        [imgFiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *fileName = obj;
            fileBrowserSelectCellModel *cellModel = [[fileBrowserSelectCellModel alloc] init];
            cellModel.fileName = fileName;
            if ([m_selectedFiles objectForKey:fileName]) {
                cellModel.selected = YES;
            } else {
                cellModel.selected = NO;
            }
            
            [m_model addObject:cellModel];
        }];
        
    } else if (m_type == fileBrowserViewControllerTypeMusic) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject hasSuffix:@".mp3"]
            || [evaluatedObject hasSuffix:@".m4a"];
        }];
        
        NSArray *musicFiles = [m_allFiles filteredArrayUsingPredicate:predicate];
        [musicFiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *fileName = obj;
            fileBrowserSelectCellModel *cellModel = [[fileBrowserSelectCellModel alloc] init];
            cellModel.fileName = fileName;
            if ([m_selectedFiles objectForKey:fileName]) {
                cellModel.selected = YES;
            } else {
                cellModel.selected = NO;
            }
            
            [m_model addObject:cellModel];
        }];
        
    } else if (m_type == fileBrowserViewControllerTypeVideo) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject hasSuffix:@".mov"]
            || [evaluatedObject hasSuffix:@".mp4"];
        }];
        
        NSArray *vidioFiles = [m_allFiles filteredArrayUsingPredicate:predicate];
        [vidioFiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *fileName = obj;
            fileBrowserSelectCellModel *cellModel = [[fileBrowserSelectCellModel alloc] init];
            cellModel.fileName = fileName;
            if ([m_selectedFiles objectForKey:fileName]) {
                cellModel.selected = YES;
            } else {
                cellModel.selected = NO;
            }
            
            [m_model addObject:cellModel];
        }];
    } else {
        // do nothing
    }
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return m_model.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"filebrowserSelecetedCell";
    fileBrowserSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    fileBrowserSelectCellModel *cellModel = [m_model objectAtIndex:indexPath.row];
    cell.fileSelected = cellModel.selected;
    NSString *fileName = cellModel.fileName;
    NSString *extension = [fileName pathExtension];
    if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"png"]) {
        NSString *path = [self.filesPath stringByAppendingPathComponent:[m_allFiles objectAtIndex:indexPath.row]];
        cell.fileTypeImgView.image = [[UIImage imageWithContentsOfFile:path] scaleToSize:[self getImgSz]];
        cell.fileNameLbl.text = @"图片文件";
    } else {
        cell.fileNameLbl.text = [m_allFiles objectAtIndex:indexPath.row];
    }
    NSString *path = [self.filesPath stringByAppendingPathComponent:fileName];
    cell.fileSizeLbl.text = [self getfileSz:path];
    cell.timeLbl.text = [[Utils fileCreationDateAtPath:path] formatWith:nil];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 85.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    fileBrowserSelectTableViewCell *cell = (fileBrowserSelectTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    fileBrowserSelectCellModel *cellModel = [m_model objectAtIndex:indexPath.row];
    cellModel.selected = !cellModel.selected;
    if (cellModel.selected) {
        [m_selectedFiles setObject:[self.filesPath stringByAppendingPathComponent:cellModel.fileName] forKey:cellModel.fileName];
    } else {
        [m_selectedFiles removeObjectForKey:cellModel.fileName];
    }
    [self checkSendBtnValid];
    cell.fileSelected = cellModel.selected;
}
- (IBAction)allBtnItemPressed:(id)sender {
    if (m_type == fileBrowserViewControllerTypeAll) {
        return;
    }
    self.allBarBtnItem.tintColor = [UIColor colorWithRed:75/255.0f green:193/255.0f blue:210/255.0f alpha:1.0f];
    self.docBarBtnItem.tintColor = [UIColor darkGrayColor];
    self.imgBarBtnItem.tintColor = [UIColor darkGrayColor];
    self.videoBtnItem.tintColor = [UIColor darkGrayColor];
    self.musicBtnItem.tintColor = [UIColor darkGrayColor];
    m_type = fileBrowserViewControllerTypeAll;
    [self buildModel];
    [self.tableView reloadData];
}

- (IBAction)docBtnItemPressed:(id)sender {
    if (m_type == fileBrowserViewControllerTypeDoc) {
        return;
    }
    self.allBarBtnItem.tintColor = [UIColor darkGrayColor];
    self.docBarBtnItem.tintColor = [UIColor colorWithRed:75/255.0f green:193/255.0f blue:210/255.0f alpha:1.0f];
    self.imgBarBtnItem.tintColor = [UIColor darkGrayColor];
    self.videoBtnItem.tintColor = [UIColor darkGrayColor];
    self.musicBtnItem.tintColor = [UIColor darkGrayColor];
    m_type = fileBrowserViewControllerTypeDoc;
    [self buildModel];
    [self.tableView reloadData];
}

- (IBAction)imgBtnItemPressed:(id)sender {
    if (m_type == fileBrowserViewControllerTypeImg) {
        return;
    }
    self.allBarBtnItem.tintColor = [UIColor darkGrayColor];
    self.docBarBtnItem.tintColor = [UIColor darkGrayColor];
    self.imgBarBtnItem.tintColor = [UIColor colorWithRed:75/255.0f green:193/255.0f blue:210/255.0f alpha:1.0f];
    self.videoBtnItem.tintColor = [UIColor darkGrayColor];
    self.musicBtnItem.tintColor = [UIColor darkGrayColor];
    m_type = fileBrowserViewControllerTypeImg;
    [self buildModel];
    [self.tableView reloadData];
}

- (IBAction)videoBtnItemPressed:(id)sender {
    if (m_type == fileBrowserViewControllerTypeVideo) {
        return;
    }
    self.allBarBtnItem.tintColor = [UIColor darkGrayColor];
    self.docBarBtnItem.tintColor = [UIColor darkGrayColor];
    self.imgBarBtnItem.tintColor = [UIColor darkGrayColor];
    self.videoBtnItem.tintColor = [UIColor colorWithRed:75/255.0f green:193/255.0f blue:210/255.0f alpha:1.0f];
    self.musicBtnItem.tintColor = [UIColor darkGrayColor];
    m_type = fileBrowserViewControllerTypeVideo;
    [self buildModel];
    [self.tableView reloadData];
}

- (IBAction)musicBtnItemPressed:(id)sender {
    if (m_type == fileBrowserViewControllerTypeMusic) {
        return;
    }
    self.allBarBtnItem.tintColor = [UIColor darkGrayColor];
    self.docBarBtnItem.tintColor = [UIColor darkGrayColor];
    self.imgBarBtnItem.tintColor = [UIColor darkGrayColor];
    self.videoBtnItem.tintColor = [UIColor darkGrayColor];
    self.musicBtnItem.tintColor = [UIColor colorWithRed:75/255.0f green:193/255.0f blue:210/255.0f alpha:1.0f];
    m_type = fileBrowserViewControllerTypeMusic;
    [self buildModel];
    [self.tableView reloadData];
}

- (IBAction)sendBtnItemPressed:(id)sender {
    NSArray *paths = [m_selectedFiles allValues];
    if ([self.delegate respondsToSelector:@selector(fileBrowserViewController:withSelectedPaths:)]) {
        [self.delegate fileBrowserViewController:self withSelectedPaths:paths];
    }
}

- (CGSize)getImgSz {
    if (IS_IPHONE_6_PLUS) {
        return CGSizeMake(30*3, 30*3);
    }
    return CGSizeMake(30*2, 30*2);
}

- (void)checkSendBtnValid {
    if (m_selectedFiles.count == 0) {
        self.sendBtnItem.enabled = NO;
    } else {
        self.sendBtnItem.enabled = YES;
    }
    self.statusBtnItem.title = [self getSelectedFileSz];
}

- (NSString *)getSelectedFileSz {
    __block unsigned long long sum = 0;
    [m_selectedFiles enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *filePath = obj;
        unsigned long long fileSz = [Utils fileSizeAtPath:filePath error:nil];
        sum += fileSz;
    }];
    
    if (sum < 1024) {
        return [NSString stringWithFormat:@"已经选择%llu bytes", sum];
    } else if (sum >= 1024 && sum < 1024 * 1024) {
        return [NSString stringWithFormat:@"已经选择%.2fK", sum / 1024.0f];
    } else {
        return [NSString stringWithFormat:@"已经选择%.2fM", sum / (1024.0f * 1024.0f)];
    }
}

- (NSString *)getfileSz:(NSString *)filePath {
    unsigned long long fileSz = [Utils fileSizeAtPath:filePath error:nil];
    if (fileSz < 1024) {
        return [NSString stringWithFormat:@"%llu bytes", fileSz];
    } else if (fileSz >= 1024 && fileSz < 1024 * 1024) {
        return [NSString stringWithFormat:@"%.2fK", fileSz / 1024.0f];
    } else {
        return [NSString stringWithFormat:@"%.2fM", fileSz / (1024.0f * 1024.0f)];
    }
}
- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
