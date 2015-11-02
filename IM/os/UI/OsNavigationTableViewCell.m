//
//  OsNavigationTableViewCell.m
//  IM
//
//  Created by 郭志伟 on 15-3-5.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "OsNavigationTableViewCell.h"
#import "OsNavigationOrgCollectionCell.h"
#import "OsNavigationRootCollectionCell.h"
#import "OsNavigationSelOrgCollectionCell.h"
#import "OsOrg.h"
#import <Masonry.h>

@interface OsNavigationTableViewCell()<UICollectionViewDataSource, UICollectionViewDelegate>
//@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property(strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *collectionData;
@end

@implementation OsNavigationTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self = [[NSBundle mainBundle] loadNibNamed:@"OsNavigationTableViewCell" owner:self options:nil][0];
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(130.0, 170.0);
        self.collectionView = [[UICollectionView alloc] initWithFrame:self.contentView.bounds collectionViewLayout:layout];
        
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.backgroundColor = [UIColor whiteColor];
        [self.collectionView registerNib:[UINib nibWithNibName:@"OsNavigationOrgCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"OsNavigationOrgCollectionCell"];
        [self.collectionView registerNib:[UINib nibWithNibName:@"OsNavigationRootCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"OsNavigationRootCollectionCell"];
        [self.collectionView registerNib:[UINib nibWithNibName:@"OsNavigationSelOrgCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"OsNavigationSelOrgCollectionCell"];
        if ([[UIDevice currentDevice].systemVersion floatValue] < 9) {
            [self addSubview:self.collectionView];
            [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        } else {
            [self.contentView addSubview:self.collectionView];
            [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.contentView);
            }];
        }
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.highlighted = YES;
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"OsNavigationTableViewCell" owner:self options:nil];
        
        if (arrayOfViews.count < 1) {
            return nil;
        }
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        self = [arrayOfViews objectAtIndex:0];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCollectionData:(NSArray *)collectionData {
    _collectionData = collectionData;
    [_collectionView reloadData];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_collectionData.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
}

//-(void)scrollToBottom
//{
//    CGPoint bottomOffset = CGPointMake(0, _collectionView.contentSize.width - _collectionView.bounds.size.width);
//    [_collectionView setContentOffset:bottomOffset animated:NO];
//}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


#pragma mark - UICollectionViewDataSource methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _collectionData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OsOrg *org = [_collectionData objectAtIndex:indexPath.row];
    if (indexPath.row == 0) {
        OsNavigationRootCollectionCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"OsNavigationRootCollectionCell" forIndexPath:indexPath];
        cell.titleLbl.text = org.jgmc;
        return cell;
    }
    
    if (indexPath.row == _collectionData.count - 1) {
        OsNavigationSelOrgCollectionCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"OsNavigationSelOrgCollectionCell" forIndexPath:indexPath];
        cell.titleLbl.text = org.jgmc;
        return cell;
    }
    
    OsNavigationOrgCollectionCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"OsNavigationOrgCollectionCell" forIndexPath:indexPath];
    cell.titleLbl.text = org.jgmc;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"collection selected at row: %ld", (long)indexPath.row);
    if ([self.delgate respondsToSelector:@selector(OsNavigationTableViewCell:tappedAtIndex:)]) {
        [self.delgate OsNavigationTableViewCell:self tappedAtIndex:indexPath.row];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OsOrg *org = [_collectionData objectAtIndex:indexPath.row];
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:17.0f]};
    if (indexPath.row == 0) {
        CGSize sz = [org.jgmc sizeWithAttributes:attributes];
        return CGSizeMake(sz.width + 15, 55);
    }
    
    if (indexPath.row == 100 - 1) {
        CGSize sz = [org.jgmc sizeWithAttributes:attributes];
        return CGSizeMake(sz.width + 20 + 10, 55);
    }
    
    
    CGSize sz = [org.jgmc sizeWithAttributes:attributes];
    return CGSizeMake(sz.width + 20 + 10, 55);
}

@end
