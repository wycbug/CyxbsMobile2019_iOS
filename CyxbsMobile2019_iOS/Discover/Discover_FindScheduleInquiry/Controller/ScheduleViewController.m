//
//  ScheduleViewController.m
//  CyxbsMobile2019_iOS
//
//  Created by Stove on 2020/7/14.
//  Copyright © 2020 Redrock. All rights reserved.
//对于这个控制器的说明：查询老师课表、查询学生课表是分别由两个控制器管理的，而这两个控制器的类型都是本控制器

#import "ScheduleViewController.h"
#import "HistoryView.h"
#import "ClassmatesList.h"
/**最大的搜索历史记录个数*/
#define MAXLEN 9
#define Color21_49_91_F0F0F2  [UIColor colorNamed:@"color21_49_91&#F0F0F2" inBundle:[NSBundle mainBundle] compatibleWithTraitCollection:nil]
#define BACKGROUNDCOLOR  [UIColor colorNamed:@"Color#F8F9FC&#000101" inBundle:[NSBundle mainBundle] compatibleWithTraitCollection:nil]
#define SEARCHBARCOLOR  [UIColor colorNamed:@"Color#E8F1FC&2C2C2C" inBundle:[NSBundle mainBundle] compatibleWithTraitCollection:nil]



@interface ScheduleViewController ()<UITextFieldDelegate,HistoryViewDelegate>
/**搜索栏里的UITextField*/
@property (nonatomic, weak)UITextField *textField;

/**容纳搜索输入框和搜索按钮的View*/
@property (nonatomic, weak)UIView *searchBackView;

/**显示"历史记录"四个字label*/
@property (nonatomic, weak)UILabel *historyLabel;

/**各条历史记录的按钮的父控件*/
@property (nonatomic, weak)HistoryView *historyView;

/**所有用来显示历史记录的按钮都会和这个按钮一样*/
@property (nonatomic, strong)UIButton *exampleButton;

/**参数key是用来当作从缓存取搜索记录数组时需要的UserDefaultKey*/
@property (nonatomic, copy)NSString *UserDefaultKey;

/**清除历史记录的按钮*/
@property (nonatomic, strong)UIButton *clearHistoryItemBtn;

/**被查的人的身份*/
@property (nonatomic,assign)PeopleType peopleType;
@end

@implementation ScheduleViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 11.0, *)) {
        self.view.backgroundColor = BACKGROUNDCOLOR;
    } else {
        self.view.backgroundColor = [UIColor colorWithHexString:@"#F8F9FC"];
    }
    //初始化历史记录按钮样本
    [self initExampleButton];
    
    //添加搜索框
    [self addSearchField];
    
    //添加显示“历史记录”四个字的label
    [self addHistoryLabel];
    
    //添加清除历史记录的按钮
    [self addClearHistoryItemBtn];
    
    //添加历史记录按钮
    [self addHistoryItem];
}
//参数key是用来当作从缓存取搜索记录数组时需要的UserDefaultKey，PeopleType是被查的人的身份
- (instancetype)initWithUserDefaultKey:(NSString*)key andPeopleType:(PeopleType)peopleType{
    self = [super init];
    if(self){
        self.UserDefaultKey = key;
        self.peopleType = peopleType;
    }
    return self;
}

//MARK: - 初始化子控件的方法：
//添加搜索框
- (void)addSearchField {
    //add background cornerRadius view
    UIView *backView = [[UIView alloc]init];
    self.searchBackView = backView;
    [self.view addSubview:backView];
    if (@available(iOS 11.0, *)) {
        backView.backgroundColor = SEARCHBARCOLOR;
    } else {
        backView.backgroundColor = [UIColor colorWithHexString:@"#E8F1FC"];
    }
    backView.layer.cornerRadius = 23;
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(18);
        make.right.equalTo(self.view).offset(-18);
        make.top.equalTo(self.view).offset(30);
        make.height.equalTo(@44);
    }];
    
    //add search field
    UITextField *textField = [[UITextField alloc]init];
    self.textField = textField;
       [self.view addSubview:textField];
       [textField mas_makeConstraints:^(MASConstraintMaker *make) {
           make.left.equalTo(backView).offset(17);
           make.right.equalTo(backView).offset(-37);
           make.top.equalTo(backView).offset(12);
           make.bottom.equalTo(backView).offset(-11);
       }];
       [textField setFont:[UIFont fontWithName:PingFangSCRegular size:15]];
       textField.placeholder = @"输入内容";
    
    //设置return类型为search，这样键盘上就会有一个搜索按钮
    [textField setReturnKeyType:(UIReturnKeySearch)];
    
    textField.delegate = self;
    
    if (@available(iOS 11.0, *)) {
       textField.textColor = Color21_49_91_F0F0F2;
       textField.tintColor = Color21_49_91_F0F0F2;
    } else {
       textField.textColor = [UIColor colorWithRed:21/255.0 green:49/255.0 blue:91/255.0 alpha:1];
       textField.tintColor = [UIColor colorWithRed:21/255.0 green:49/255.0 blue:91/255.0 alpha:1];
    }
    textField.backgroundColor = UIColor.clearColor;
    [self addKeyBoardToolBarforTextField:textField];
}

- (void)addKeyBoardToolBarforTextField:(UITextField*)textField{
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_W, 44)];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(MAIN_SCREEN_W-60, 0, 50, 44)];
    [toolBar addSubview:btn];
    [btn setTitleColor:UIColor.systemBlueColor forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    
    [btn addTarget:self action:@selector(doneClicked) forControlEvents:UIControlEventTouchUpInside];

    
    UILabel *placeHolderLabel = [[UILabel alloc] init];
    [toolBar addSubview:placeHolderLabel];
    placeHolderLabel.text = textField.placeholder;
    placeHolderLabel.font = [UIFont systemFontOfSize:13];
    placeHolderLabel.alpha = 0.8;
    placeHolderLabel.textColor = [UIColor systemGrayColor];
    [placeHolderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(toolBar);
        make.top.equalTo(toolBar);
        make.bottom.equalTo(toolBar);
    }];
    
    textField.inputAccessoryView = toolBar;
}
//点击键盘右上角的完成按钮后调用
- (void)doneClicked{
    [self.view endEditing:YES];
    [self touchSearchButton];
}

//添加显示“历史记录”四个字的label
- (void)addHistoryLabel {
    UILabel *label = [[UILabel alloc]init];
    self.historyLabel = label;
    label.text = @"历史记录";
    if (@available(iOS 11.0, *)) {
        label.textColor = Color21_49_91_F0F0F2;
    } else {
        label.textColor = [UIColor colorWithRed:21/255.0 green:49/255.0 blue:91/255.0 alpha:1];
    }
    label.font = [UIFont fontWithName:PingFangSCBold size:15];
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.searchBackView);
        make.top.equalTo(self.searchBackView.mas_bottom).offset(21);
    }];
}

//添加清除历史记录的按钮
- (void)addClearHistoryItemBtn{
    UIButton *btn = [[UIButton alloc] init];
    [self.view addSubview:btn];
    self.clearHistoryItemBtn = btn;
    [btn setBackgroundImage:[UIImage imageNamed:@"草稿箱垃圾桶"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clearHistoryItemBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    //拿到存放历史记录的缓存数组
    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:self.UserDefaultKey];
    //如果没有历史记录，那就让按钮失效
    if(array.count==0)btn.enabled = NO;
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.historyLabel);
        make.centerX.equalTo(self.view).offset(0.4307*MAIN_SCREEN_W);
        make.width.height.mas_equalTo(0.0533*MAIN_SCREEN_W);
        make.height.mas_equalTo(0.05931*MAIN_SCREEN_W);
    }];
}

//添加历史记录按钮
- (void)addHistoryItem {
    NSMutableArray * array = [[[NSUserDefaults standardUserDefaults] objectForKey:self.UserDefaultKey] mutableCopy];
    
    //如果没取到，说明是第一次进行搜索，那么就给array初始化
    if(array==nil){
        array = [NSMutableArray array];
        
        //array初始化后还要缓存一次，不然永远只能取到nil
        [[NSUserDefaults standardUserDefaults] setObject:array forKey:self.UserDefaultKey];
    }
    
    HistoryView *view = [[HistoryView alloc]initWithFrame:CGRectMake(0, 200, self.view.width, 200) button:self.exampleButton dataArray:array];
    if(self.historyView!=nil){
        [self.historyView removeFromSuperview];
    }
    
    self.historyView = view;
    [self.view addSubview:view];
    view.btnClickedDelegate = self;
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.historyLabel.mas_bottom).offset(9);
        make.left.equalTo(self.searchBackView);
        make.right.equalTo(self.searchBackView);
        make.height.equalTo(@400);
    }];
}

//MARK: - 点击类某按钮后调用
//点击键盘上的搜索按钮后调用
- (void)touchSearchButton {
    //判断输入内容是否为空
    if ([self.textField.text isEqualToString:@""]) {
        MBProgressHUD *noInput = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        noInput.mode = MBProgressHUDModeText;
        noInput.labelText = @"输入为空";
        [noInput hide:YES afterDelay:1];
        return;
    }
    //搜索输入框的内容，如果有返回则跳转如选择同学页面
    [self requestStudentNameDataWithNSString:self.textField.text];
}

//点击了某一条历史记录后调用
- (void)touchHistoryButton:(UIButton *)sender {
    [self requestStudentNameDataWithNSString:sender.titleLabel.text];
}

//点击清除历史记录按钮后调用
- (void)clearHistoryItemBtnClicked{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"删除搜索记录" message:@"是否确定删除记录" preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *cancelAC = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
    
    UIAlertAction *deleteAC = [UIAlertAction actionWithTitle:@"删除" style:(UIAlertActionStyleDestructive) handler:^(UIAlertAction * _Nonnull action) {
        
        //1.从缓存去除记录
        [[NSUserDefaults standardUserDefaults] setObject:[@[] mutableCopy] forKey:self.UserDefaultKey];
        //2.去除控件上的记录
        
        [self.historyView removeAllSubviews];
        
        //3.让按钮取消失效
        self.clearHistoryItemBtn.enabled = NO;
    }];
    
    [ac addAction:deleteAC];
    [ac addAction:cancelAC];
    
    [self presentViewController:ac animated:YES completion:nil];
}

//MARK: -需要实现的代理方法：
//搜索框textfield的代理方法
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self touchSearchButton];
    return YES;
}

//MARK: - 其他的方法
//通过string来发送网络请求的方法
- (void)requestStudentNameDataWithNSString:(NSString*)string {
    [self.view endEditing:YES];
    
    //储存搜索记录
    [self write:string intoDataArrayWithUserDefaultKey:self.UserDefaultKey];
    
    
    __block MBProgressHUD *loading = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
       loading.mode = MBProgressHUDModeIndeterminate;
       loading.labelText = @"加载中";
       
    ClassmatesList *classmates = [[ClassmatesList alloc] initWithPeopleType:self.peopleType];
    
    
       [classmates getPeopleListWithName:string success:^(ClassmatesList * _Nonnull classmatesList) {
           [loading hide:YES];
           if (classmatesList.classmatesArray.count == 0) {
               MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
               hud.mode = MBProgressHUDModeText;
               hud.labelText = @"无结果";
               [hud hide:YES afterDelay:1];
               //没有发生跳转，那就只改变显示历史记录的控件的内部数据，而不刷新历史记录控件布局
               [self.historyView addHistoryBtnWithString:string reLayout:NO];
               return;
           }
           
           //有多个结果就跳转到搜索结果页面
           
           ChooseStudentListViewController *studentListVC = [[ChooseStudentListViewController alloc]initWithClassmatesList:classmatesList];
           studentListVC.peopleType = self.peopleType;
           [self.delegate pushToController: studentListVC];
           //跳转后刷新历史记录表
           [self.historyView addHistoryBtnWithString:string reLayout:YES];
           //如果有刷新历史记录view，就让清除历史记录的按钮可点击
           if(self.clearHistoryItemBtn.enabled==NO){
               self.clearHistoryItemBtn.enabled = YES;
           }
           
       } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
           [loading hide:YES];
           MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
           hud.mode = MBProgressHUDModeText;
           hud.labelText = @"加载失败";
           [hud hide:YES afterDelay:1];
           
           //没有发生跳转，那就只改变显示历史记录的控件的内部数据，而不刷新历史记录控件布局
           [self.historyView addHistoryBtnWithString:string reLayout:NO];
       }];
}

//初始化历史记录按钮样本的方法
- (void)initExampleButton{
    UIButton *btn = [[UIButton alloc]init];
    
    if (@available(iOS 11.0, *)) {
        btn.backgroundColor = SEARCHBARCOLOR;
    } else {
        // Fallback on earlier versions
    }
    
    if (@available(iOS 11.0, *)) {
        btn.titleLabel.textColor = Color21_49_91_F0F0F2;
        [btn setTitleColor:Color21_49_91_F0F0F2 forState:normal];
    }
    
    [btn.titleLabel setFont:[UIFont fontWithName:PingFangSCRegular size:12]];
    
    btn.layer.cornerRadius = 14;
    
    self.exampleButton = btn;
}

//把str写入key对应的那个缓存数组，再把数组放回去（在原有缓存里加上str），实现记录搜索记录的方法
- (void)write:(NSString*)str intoDataArrayWithUserDefaultKey:(NSString*)key{
    
    //写入缓存
    NSUserDefaults *defa = [NSUserDefaults standardUserDefaults];
    
    //这里取出的是一个数组，内部是部分搜索历史记录，从缓存取出来后要mutableCopy一下，不然会崩
    NSMutableArray *array = [[defa objectForKey:key] mutableCopy];
    
    //现在array不可能是nil
    
    //判断是否和以前的搜索内容一样，如果一样就移除旧的历史记录
    for (NSString *historyStr in array) {
        if ([historyStr isEqualToString:str]) {
            [array removeObject:str];
            break;
        }
    }
    
    //加到数组的第一个，这样可以把最新的历史记录显示在最上面
    [array insertObject:str atIndex:0];

    //限制最多缓存MAXLEN个历史记录
    if(array.count>MAXLEN){
        [array removeLastObject];
    }
    
    //加上重新放回去
    [defa setObject:array forKey:key];
    
}

@end
