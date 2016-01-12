//
//  ViewController.m
//  MoveTableViewCell
//
//  Created by ZhaoHanjun on 16/1/12.
//  Copyright © 2016年 https://github.com/CoderHJZhao    . All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *arrayValue;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

#pragma mark - 懒加载

- (NSMutableArray *)arrayValue
{
    if (!_arrayValue) {
        //数据源，类似于每一个cell的key
        _arrayValue = [NSMutableArray array];
        for (int i = 0; i < 20; i++) {
            NSString *imageName = [NSString stringWithFormat:@"%d",i];
            [_arrayValue addObject:imageName];
        }

    }
    return _arrayValue;
}

#pragma mark - 视图生命中周期

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //实例化UITableView
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    self.tableView.editing = YES;
    [self.view addSubview:_tableView];
    
    //添加长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.tableView addGestureRecognizer:longPress];
    
   
}

#pragma mark - 方法实现

- (void)longPressGestureRecognized:(UILongPressGestureRecognizer *)gestureRecognizer
{

    
    UILongPressGestureRecognizer *longPress = gestureRecognizer;
    UIGestureRecognizerState state = longPress.state;
    
    CGPoint location = [longPress locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
    static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
    
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                sourceIndexPath = indexPath;
                
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                
                // Take a snapshot of the selected row using helper method.
                
                
                snapshot = [self customSnapshotFromView:cell];
                
                // Add the snapshot as subview, centered at cell's center...
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.tableView addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    
                    // Offset for gesture location.
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    cell.alpha = 0;
                    
                    // Black out.
//                    cell.backgroundColor = [UIColor whiteColor];
                } completion:^(BOOL finished) {
                    
                    cell.hidden = YES;
                    
                }];
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            // Is destination valid and is it different from source?
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                
                // ... update data source.
                [self.arrayValue exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
                // ... move the rows.
                [self.tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                
                // ... and update source so it is in sync with UI changes.
                sourceIndexPath = indexPath;
            }
            break;
        }
        default: {
            // Clean up.
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
            cell.hidden = NO;
            cell.alpha = 0;
            [UIView animateWithDuration:0.25 animations:^{
                
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                cell.alpha = 1;
                // Undo the black-out effect we did.
                cell.backgroundColor = [UIColor whiteColor];
                
            } completion:^(BOOL finished) {
                
                [snapshot removeFromSuperview];
                snapshot = nil;
                sourceIndexPath = nil;
                
            }];
            break;
        }
    }
}


- (UIView *)customSnapshotFromView:(UIView *)inputView {
    
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;

    
    return snapshot;
}

#pragma mark - UITableViewDelegate&UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrayValue count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    return cell;
    
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return YES;
//}

//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
//{
//    NSUInteger fromRow = [sourceIndexPath row];
//    NSUInteger toRow = [destinationIndexPath row];
//    id object = [_arrayValue objectAtIndex:fromRow];
//    [_arrayValue removeObjectAtIndex:fromRow];
//    [_arrayValue insertObject:object atIndex:toRow];
//}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}


@end
