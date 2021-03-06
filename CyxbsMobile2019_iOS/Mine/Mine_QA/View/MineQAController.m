//
//  MineQAController.m
//  CyxbsMobile2019_iOS
//
//  Created by 方昱恒 on 2020/1/22.
//  Copyright © 2020 Redrock. All rights reserved.
//

#import "MineQAController.h"
#import "MineSegmentedView.h"
#import "MineQATableViewController.h"
#import "MineQAPresenter.h"

@interface MineQAController ()<MineQAProtocol>

@property (nonatomic, weak) MineQATableViewController *vc1;
@property (nonatomic, weak) MineQATableViewController *vc2;

@property (nonatomic, weak) MBProgressHUD *hud;

@end

@implementation MineQAController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteDraft:) name:@"MyQuestionsDraftDelete" object:nil];
    
    self.presenter = [[MineQAPresenter alloc] init];
    [self.presenter attachView:self];
    
    self.view.backgroundColor = [UIColor colorWithRed:248/255.0 green:249/255.0 blue:252/255.0 alpha:1];
    self.navigationController.navigationBar.hidden = NO;
    
    MineQATableViewController *vc1 = [[MineQATableViewController alloc] initWithTitle:self.title andSubTitle:@"已发布"];
    if ([self.title isEqualToString:@"评论回复"]) {
        vc1.subTittle = @"发出评论";
    }
    
    if (@available(iOS 11.0, *)) {
        vc1.tableView.backgroundColor = [UIColor colorNamed:@"Mine_QA_BackgroundColor"];
    } else {
        // Fallback on earlier versions
    }
    vc1.superController = self;
    self.vc1 = vc1;
    
    
    MineQATableViewController *vc2 = [[MineQATableViewController alloc] initWithTitle:self.title andSubTitle:@"草稿箱"];
    if ([self.title isEqualToString:@"评论回复"]) {
        vc2.subTittle = @"收到回复";
    }
    
    if (@available(iOS 11.0, *)) {
        vc2.tableView.backgroundColor = [UIColor colorNamed:@"Mine_QA_BackgroundColor"];
    } else {
        // Fallback on earlier versions
    }
    vc2.superController = self;
    self.vc2 = vc2;
    
    NSArray *arr = @[vc1, vc2];
    
    
    MineSegmentedView *segmentedView = [[MineSegmentedView alloc] initWithChildViewControllers:arr];
    segmentedView.frame = self.view.bounds;
    if (@available(iOS 11.0, *)) {
        segmentedView.backgroundColor = [UIColor colorNamed:@"Mine_QA_BackgroundColor"];
    } else {
        // Fallback on earlier versions
    }
    [self.view addSubview:segmentedView];
    
    UIView *navigationBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_W, TOTAL_TOP_HEIGHT)];
    if (@available(iOS 11.0, *)) {
        navigationBar.backgroundColor = [UIColor colorNamed:@"Mine_QA_HeaderBarColor"];
    } else {
        // Fallback on earlier versions
    }
    [self.view addSubview:navigationBar];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((MAIN_SCREEN_W - 85) / 2.0, 7 + STATUSBARHEIGHT, 85, 30)];
    titleLabel.text = self.title;
    titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size: 21];
    if (@available(iOS 11.0, *)) {
        titleLabel.textColor = [UIColor colorNamed:@"Mine_QA_TitleLabelColor"];
    } else {
        // Fallback on earlier versions
    }
    [navigationBar addSubview:titleLabel];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(17, 12.5 + STATUSBARHEIGHT, 19, 19);
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
    [backButton setImage:[UIImage imageNamed:@"我的返回"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [navigationBar addSubview:backButton];
    
    
    // 请求数据
    if ([self.title isEqualToString:@"我的提问"]) {
        [self.presenter requestQuestionsListWithPageNum:@(self.vc1.pageNum) andSize:@6];
        [self.presenter requestQuestionsDraftListWithPageNum:@(self.vc2.pageNum) andSize:@6];
    } else if ([self.title isEqualToString:@"我的回答"]) {
        [self.presenter requestAnswerListWithPageNum:@(self.vc1.pageNum) andSize:@6];
        [self.presenter requestAnswerDraftListWithPageNum:@(self.vc2.pageNum) andSize:@6];
    } else if ([self.title isEqualToString:@"评论回复"]) {
        [self.presenter requestCommentListWithPageNum:@(self.vc1.pageNum) andSize:@6];
        [self.presenter requestReCommentListWithPageNum:@(self.vc2.pageNum) andSize:@6];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = NO;
    [self.presenter dettachView];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    [self.presenter dettachView];
}


#pragma mark - presenter回调
- (void)questionListRequestSucceeded:(NSArray<MineQAMyQuestionItem *> *)itemsArray {
    if (itemsArray.count < 6) {
        self.vc1.itemsArray = [[self.vc1.itemsArray arrayByAddingObjectsFromArray:itemsArray] mutableCopy];
        self.vc1.pageNum++;
        [self.vc1.tableView reloadData];
        [self.vc1.tableView.mj_footer endRefreshingWithNoMoreData];
    } else {
        [self.vc1.tableView.mj_footer endRefreshing];
        self.vc1.itemsArray = [[self.vc1.itemsArray arrayByAddingObjectsFromArray:itemsArray] mutableCopy];
        self.vc1.pageNum++;
        [self.vc1.tableView reloadData];
    }
}

- (void)questionDraftListRequestSucceeded:(NSArray<MineQAMyQuestionDraftItem *> *)itemsArray {
    if (itemsArray.count < 6) {
        self.vc2.itemsArray = [[self.vc2.itemsArray arrayByAddingObjectsFromArray:itemsArray] mutableCopy];
        self.vc2.pageNum++;
        [self.vc2.tableView reloadData];
        [self.vc2.tableView.mj_footer endRefreshingWithNoMoreData];
    } else {
        [self.vc2.tableView.mj_footer endRefreshing];
        self.vc2.itemsArray = [[self.vc2.itemsArray arrayByAddingObjectsFromArray:itemsArray] mutableCopy];
        self.vc2.pageNum++;
        [self.vc2.tableView reloadData];
    }
}

- (void)answerListRequestSucceeded:(NSArray<MineQAMyAnswerItem *> *)itemsArray {
    if (itemsArray.count < 6) {
        self.vc1.itemsArray = [[self.vc1.itemsArray arrayByAddingObjectsFromArray:itemsArray] mutableCopy];
        self.vc1.pageNum++;
        [self.vc1.tableView reloadData];
        [self.vc1.tableView.mj_footer endRefreshingWithNoMoreData];
    } else {
        [self.vc1.tableView.mj_footer endRefreshing];
        self.vc1.itemsArray = [[self.vc1.itemsArray arrayByAddingObjectsFromArray:itemsArray] mutableCopy];
        self.vc1.pageNum++;
        [self.vc1.tableView reloadData];
    }
}

- (void)answerDraftListRequestSucceeded:(NSArray<MineQAMyAnswerDraftItem *> *)itemsArray {
    if (itemsArray.count < 6) {
        self.vc2.itemsArray = [[self.vc2.itemsArray arrayByAddingObjectsFromArray:itemsArray] mutableCopy];
        self.vc2.pageNum++;
        [self.vc2.tableView reloadData];
        [self.vc2.tableView.mj_footer endRefreshingWithNoMoreData];
    } else {
        [self.vc2.tableView.mj_footer endRefreshing];
        self.vc2.itemsArray = [[self.vc2.itemsArray arrayByAddingObjectsFromArray:itemsArray] mutableCopy];
        self.vc2.pageNum++;
        [self.vc2.tableView reloadData];
    }
}

- (void)commentListRequestSucceeded:(NSArray<MineQACommentItem *> *)itemsArray {
    if (itemsArray.count < 6) {
        self.vc1.itemsArray = [[self.vc1.itemsArray arrayByAddingObjectsFromArray:itemsArray] mutableCopy];
        self.vc1.pageNum++;
        [self.vc1.tableView reloadData];
        [self.vc1.tableView.mj_footer endRefreshingWithNoMoreData];
    } else {
        [self.vc1.tableView.mj_footer endRefreshing];
        self.vc1.itemsArray = [[self.vc1.itemsArray arrayByAddingObjectsFromArray:itemsArray] mutableCopy];
        self.vc1.pageNum++;
        [self.vc1.tableView reloadData];
    }
}

- (void)reCommentListRequestSucceeded:(NSArray<MineQARecommentItem *> *)itemsArray {
    if (itemsArray.count < 6) {
        self.vc2.itemsArray = [[self.vc2.itemsArray arrayByAddingObjectsFromArray:itemsArray] mutableCopy];
        self.vc2.pageNum++;
        [self.vc2.tableView reloadData];
        [self.vc2.tableView.mj_footer endRefreshingWithNoMoreData];
    } else {
        [self.vc2.tableView.mj_footer endRefreshing];
        self.vc2.itemsArray = [[self.vc2.itemsArray arrayByAddingObjectsFromArray:itemsArray] mutableCopy];
        self.vc2.pageNum++;
        [self.vc2.tableView reloadData];
    }
}

// 上拉加载
- (void)pullUpToLoadWithTitle:(NSString *)title andSubTitle:(NSString *)subTitle {
    if ([self.title isEqualToString:@"我的提问"]) {
        if ([subTitle isEqualToString:@"已发布"]) {
            [self.presenter requestQuestionsListWithPageNum:@(self.vc1.pageNum) andSize:@6];
        } else {
            [self.presenter requestQuestionsDraftListWithPageNum:@(self.vc2.pageNum) andSize:@6];
        }
    } else if ([self.title isEqualToString:@"我的回答"]) {
        if ([subTitle isEqualToString:@"已发布"]) {
            [self.presenter requestAnswerListWithPageNum:@(self.vc1.pageNum) andSize:@6];
        } else {
            [self.presenter requestAnswerDraftListWithPageNum:@(self.vc2.pageNum) andSize:@6];
        }
    } else if ([self.title isEqualToString:@"评论回复"]) {
        if ([subTitle isEqualToString:@"发出评论"]) {
            [self.presenter requestCommentListWithPageNum:@(self.vc1.pageNum) andSize:@6];
        } else {
            [self.presenter requestReCommentListWithPageNum:@(self.vc2.pageNum) andSize:@6];
        }
    }

}

- (void)draftDeleteSuccess {
    self.vc2.pageNum = 1;
    [self.vc2.itemsArray removeAllObjects];
    if ([self.title isEqualToString:@"我的提问"]) {
        [self.presenter requestQuestionsDraftListWithPageNum:@(self.vc2.pageNum) andSize:@6];
    } else if ([self.title isEqualToString:@"我的回答"]) {
        [self.presenter requestAnswerDraftListWithPageNum:@(self.vc2.pageNum) andSize:@6];
    }
    [self.hud hide:YES];
}

- (void)draftDeleteFailure {
    
}


#pragma mark - 通知中心
- (void)deleteDraft:(NSNotification *)notifacation {
    NSLog(@"%@", notifacation.userInfo[@"id"]);
    NSString *alertTitle = @"确定要删除这条草稿吗？";
    NSString *message = @"删除后将无法恢复";
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"删除中...";
        self.hud = hud;
        
        [self.presenter deleteDraftWithDraftID:notifacation.userInfo[@"id"]];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"手滑了" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:cancel];
    [alertController addAction:confirm];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
@end
