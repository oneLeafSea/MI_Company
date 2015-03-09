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

@interface OsNavigationTableViewCell()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *collectionData;
@end

@implementation OsNavigationTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self = [[NSBundle mainBundle] loadNibNamed:@"OsNavigationTableViewCell" owner:self options:nil][0];
//        _collectionView.frame = self.bounds;
//        [self.contentView addSubview:_collectionView];
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
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.itemSize = CGSizeMake(130.0, 170.0);
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    // Register the colleciton cell
    [_collectionView registerNib:[UINib nibWithNibName:@"OsNavigationOrgCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"OsNavigationOrgCollectionCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"OsNavigationRootCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"OsNavigationRootCollectionCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"OsNavigationSelOrgCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"OsNavigationSelOrgCollectionCell"];
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
        OsNavigationRootCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OsNavigationRootCollectionCell" forIndexPath:indexPath];
        cell.titleLbl.text = org.jgmc;
        return cell;
    }
    
    if (indexPath.row == _collectionData.count - 1) {
        OsNavigationSelOrgCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OsNavigationSelOrgCollectionCell" forIndexPath:indexPath];
        cell.titleLbl.text = org.jgmc;
        return cell;
    }
    
    OsNavigationOrgCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OsNavigationOrgCollectionCell" forIndexPath:indexPath];
    cell.titleLbl.text = org.jgmc;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"collection selected at row: %ld", (long)indexPath.row);
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
        return CGSizeMake(sz.width, 55);
    }
    
    if (indexPath.row == 100 - 1) {
        CGSize sz = [org.jgmc sizeWithAttributes:attributes];
        return CGSizeMake(sz.width + 20 + 10, 55);
    }
    
    
    CGSize sz = [org.jgmc sizeWithAttributes:attributes];
    return CGSizeMake(sz.width + 20 + 10, 55);
}

@end
