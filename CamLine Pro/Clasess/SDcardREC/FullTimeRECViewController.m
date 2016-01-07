//
//  FullTimeRECViewController.m
//  temptest
//
//  Created by apple  on 16/1/5.
//  Copyright © 2016年 jayzhou. All rights reserved.
//
typedef enum {
    DEFULAT_PICKER_VIEW,
    WEEK_PICKER_VIEW, // 周pickerview
    HM_PICKER_VIEW   // 小时分钟 pickerview
}PickerViewType;

#define REC_TIME_ROW 0
#define REC_START_ROW 1
#define REC_END_ROW 2
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height;

#import "FullTimeRECViewController.h"
#import "MBProgressHUD+MJ.h"

@interface FullTimeRECViewController ()<UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
{
    UITextField* textFieldServer;
    UIButton * sWeekBtn;
    UIButton * sHMBtn;
    UIButton * eWeekBtn;
    UIButton * eHMBtn;
    
}
@property (retain, nonatomic) IBOutlet UITableView *displayTV;

@property (retain, nonatomic) IBOutlet UIPickerView *basicPickerView;

/**
 * cell 标题
 */
@property (nonatomic ,retain) NSArray *arrItems;
//pickerview source data
@property (nonatomic ,retain) NSArray *arrWeek;
@property (nonatomic ,retain) NSArray *arrHour;
@property (nonatomic ,retain) NSArray *arrMintue;
//
@property (nonatomic,copy) NSString* sStartWeek;
//开始时间小时 与分钟
@property (nonatomic,copy) NSString* sStartHM;

@property (nonatomic,copy) NSString* sEndWeek;
@property (nonatomic,copy) NSString* sEndHM;

@property (nonatomic ,assign) NSInteger sWeekIndex;
@property (nonatomic ,assign) NSInteger sHourIndex;
@property (nonatomic ,assign) NSInteger sMinuteIndex;

@property (nonatomic ,assign) NSInteger eWeekIndex;
@property (nonatomic ,assign) NSInteger eHourIndex;
@property (nonatomic ,assign) NSInteger eMinuteIndex;


@property (nonatomic ,assign) PickerViewType pickerType;
@property (nonatomic ,assign) NSInteger whitchBtn; //7001 8001  7002  8002

//@property (nonatomic ,retain) UIPickerView * hMPickerView;
@property (nonatomic ,retain) UIButton * tarbarCancelBtn;
@property (nonatomic ,retain) UIButton * tarbarSureBtn;


@property (retain, nonatomic) IBOutlet NSLayoutConstraint *pickerViewHeight;

@end

@implementation FullTimeRECViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    //1.1left btn
    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    customButton.frame = CGRectMake(0, 0, 44, 44);
    [customButton setBackgroundImage:[UIImage imageNamed:@"cam_back" ] forState:UIControlStateNormal];
    [customButton setBackgroundImage:[UIImage imageNamed:@"cam_back_clicked"] forState:UIControlStateHighlighted];
    [customButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:customButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -16;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, backButton, nil];
    [backButton release];
    //1.2.rightbtn
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:NSLocalizedString(@"OK", @"")
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(save:)];

    [self initData];
    
    //add gesture to hid keyborad
    
    UITapGestureRecognizer* singleRecognizer;
    singleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancleEditing)];
    singleRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleRecognizer];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self setUI];
    self.displayTV.scrollEnabled = NO;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [ self clickedChoicePickerBtn];
   
}
- (void)cancleEditing
{
    [self.view endEditing:YES];
}
- (void)setUI
{
    self.displayTV.allowsSelection = NO;
//    //2. picker view
//    CGFloat heightPV = 300;
//    CGFloat y = [UIScreen mainScreen].bounds.size.height - heightPV;
//    self.basicPickerView = [[[UIPickerView alloc]initWithFrame:CGRectMake(0, y, SCREEN_WIDTH, heightPV)] autorelease];
//    
//    self.basicPickerView.hidden = YES;
//    self.basicPickerView.delegate  = self;
//    self.basicPickerView.dataSource = self;
//    [self.view addSubview:self.basicPickerView];
    
    //3. toolbar button
    CGFloat btnWidth = 60;
    CGFloat btnHeight = 44;
    CGFloat yBtn = CGRectGetMinY(self.basicPickerView.frame) - btnHeight;
    //3.1 cancel btn
    self.tarbarCancelBtn= [[[UIButton alloc] initWithFrame:CGRectMake(0, yBtn, btnWidth, btnHeight)]autorelease];
    [self.tarbarCancelBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"Cancel", @"")] forState:UIControlStateNormal];
    [self.tarbarCancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.tarbarCancelBtn setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [self.tarbarCancelBtn addTarget:self action:@selector(clickedCancelPickerBtn:) forControlEvents:UIControlEventTouchUpInside];
    self.tarbarCancelBtn.hidden =YES;
    [self.view addSubview:self.tarbarCancelBtn];
    
    //3.2 sure btn
    self.tarbarSureBtn = [[[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - btnWidth, yBtn, btnWidth, btnHeight)] autorelease];
    [self.tarbarSureBtn setTitle:[NSString stringWithFormat:NSLocalizedString(@"Sure", @"")] forState:UIControlStateNormal];
    [self.tarbarSureBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.tarbarSureBtn setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    [self.tarbarSureBtn addTarget:self action:@selector(clickedChoicePickerBtn) forControlEvents:UIControlEventTouchUpInside];
    self.tarbarSureBtn.hidden =YES;
    [self.view addSubview:self.tarbarSureBtn];
    
}
- (void)initData
{
    self.sWeekIndex = 0;
    self.sHourIndex = 0;
    self.sMinuteIndex = 0;
    self.eWeekIndex = 0;
    self.eHourIndex = 0;
    self.eMinuteIndex = 0;
}
//nav btn
- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)save:(id)sender
{
    NSInteger start ,end;
    start = self.sWeekIndex * 49 + self.sHourIndex *2 +self.sMinuteIndex;
    end = self.eWeekIndex * 49 +self.eHourIndex * 2 + self.eMinuteIndex;
    if (end > start)
        {
            if (_delegate &&[_delegate respondsToSelector:@selector(fullTimeRECViewController:scheduleFullTimeFrom:to:withRECTime:)])
                {
                    [_delegate fullTimeRECViewController:self scheduleFullTimeFrom:start to:end withRECTime:self.RECLength];
                }
        [self.navigationController popViewControllerAnimated:YES];
    }else if (self.sWeekIndex == 6 && self.eWeekIndex == 0 && self.eHourIndex == 0 && self.eMinuteIndex == 0)
        {
            
            if (_delegate &&[_delegate respondsToSelector:@selector(fullTimeRECViewController:scheduleFullTimeFrom:to:withRECTime:)])
            {
                [_delegate fullTimeRECViewController:self scheduleFullTimeFrom:start to:342 withRECTime:self.RECLength];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else {
            [MBProgressHUD showError:[NSString stringWithFormat:NSLocalizedString(@" Error,Pls try setting time again!! ", @"")]];
    
                }
    
}

//toolbar btn
- (void)clickedCancelPickerBtn:(UIButton * )sender
{
    
    [self dismissPickerViw:YES];
}

- (void)clickedChoicePickerBtn
{
#pragma mark - todo:
    
    self.sStartWeek = [self.arrWeek objectAtIndex:self.sWeekIndex];
    self.sStartHM = [NSString stringWithFormat:@"%@:%@",self.arrHour[self.sHourIndex],self.arrMintue[self.sMinuteIndex]];
    self.sEndWeek = [self.arrWeek objectAtIndex:self.eWeekIndex];
    self.sEndHM = [NSString stringWithFormat:@"%@:%@",self.arrHour[self.eHourIndex],self.arrMintue[self.eMinuteIndex]];
    
    [self.displayTV reloadData];
    [self dismissPickerViw:YES];
}
- (void)dismissPickerViw:(BOOL)ishidden
{
    self.basicPickerView.hidden = ishidden;
    self.tarbarCancelBtn.hidden = ishidden;
    self.tarbarSureBtn.hidden = ishidden;
}

- (void) clikedSettingTimeBtn:(UIButton *)sender
{
    self.whitchBtn = sender.tag;
    // 7001->7002 start ｜end Week; 8001 ->8002 endHourMinute
    switch (sender.tag) {
        case 7001:
        {
            self.pickerType = WEEK_PICKER_VIEW;
        }
            break;
        case 7002:
        {
            self.pickerType = WEEK_PICKER_VIEW;
            
        }
            break;
        case 8001:
        {
            self.pickerType = HM_PICKER_VIEW;
            
        }
            break;
        case 8002:
        {
            self.pickerType = HM_PICKER_VIEW;
            
        }
            break;
            
        default:
            break;
    }
    [self.basicPickerView reloadAllComponents];
    [self dismissPickerViw:NO];
    [self cancleEditing];
    
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.tableFooterView = [[UIView alloc] init];
    
    NSInteger row = indexPath.row;
    static NSString *TableIdentifier = @"SectionTableIdentif";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableIdentifier]
                autorelease];
    
    
    cell.textLabel.text = self.arrItems[row];
    if (row == REC_TIME_ROW)
    {
        CGFloat widthTF = 80;
        CGFloat widthLabel = 40;
        CGFloat gap = 10;
        CGFloat xTF  = SCREEN_WIDTH - widthTF - widthLabel - gap;
        CGFloat xLabel =SCREEN_WIDTH - widthLabel - gap;
        textFieldServer = [[UITextField alloc] initWithFrame:CGRectMake(xTF, 0, widthTF, 44)];
        textFieldServer.placeholder = [[NSString stringWithFormat:NSLocalizedString(@"REC Time", @"")]copy];
        textFieldServer.text = [NSString stringWithFormat:@"%d",self.RECLength];
        textFieldServer.textAlignment = NSTextAlignmentRight;
        textFieldServer.keyboardType = UIKeyboardTypeNumberPad;
        textFieldServer.delegate = self;
        textFieldServer.tag = 6000;
        UILabel * uintL = [[UILabel alloc] initWithFrame:CGRectMake(xLabel, 0, widthLabel, 44)];
        uintL.text = [NSString stringWithFormat:NSLocalizedString(@"S", @"")];
        //            uintL.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:textFieldServer];
        [cell.contentView addSubview:uintL];
        [uintL release];
    }else if (row == REC_START_ROW || row == REC_END_ROW)
    {
        CGFloat widthBtn = 100;
        CGFloat heightBtn = 34;
        CGFloat gap = 10;
        CGFloat y = 5;
        
        NSString *btnWeekTitle = (row == REC_START_ROW) ? [self.sStartWeek copy ]:[self.sEndWeek copy];
        NSString *btnHMTitle = (row == REC_START_ROW) ? [self.sStartHM copy] :[self.sEndHM copy];
        
        //1.week
        CGFloat xweekBtn  = SCREEN_WIDTH - widthBtn * 2 - gap * 2;
        UIButton * weekBtn = [[UIButton alloc]initWithFrame:CGRectMake(xweekBtn, y, widthBtn, heightBtn)];
        weekBtn.tag = 7000 +row;
        weekBtn.layer.borderWidth = 2.0f;
        weekBtn.layer.cornerRadius = 5;
        weekBtn.layer.borderColor = [UIColor grayColor].CGColor;
        [weekBtn setTitle:btnWeekTitle forState:UIControlStateNormal];
        [weekBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [weekBtn addTarget:self action:@selector(clikedSettingTimeBtn:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:weekBtn];
        if (row == REC_START_ROW) {
            sWeekBtn = weekBtn;
        }else eWeekBtn = weekBtn;
        [weekBtn release];
        
        //2. hour:min
        CGFloat xBtn  = SCREEN_WIDTH - widthBtn  - gap ;
        UIButton * HMBtn = [[UIButton alloc] initWithFrame:CGRectMake(xBtn, y, widthBtn, heightBtn)];
        HMBtn.tag = 8000 +row ;
        HMBtn.layer.borderWidth = 2.0f;
        HMBtn.layer.cornerRadius = 5;
        HMBtn.layer.borderColor = [UIColor grayColor].CGColor;
        [HMBtn setTitle:btnHMTitle forState:UIControlStateNormal];
        [HMBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [HMBtn addTarget:self action:@selector(clikedSettingTimeBtn:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:HMBtn];
        if (row == REC_START_ROW) {
            sHMBtn = HMBtn;
        }else eHMBtn = HMBtn;
        [HMBtn release];
    }}
    if (row == REC_TIME_ROW) {
        
    }else if (row == REC_START_ROW || row == REC_END_ROW) {
         [sWeekBtn setTitle:_sStartWeek forState:UIControlStateNormal];
         [sHMBtn setTitle:_sStartHM forState:UIControlStateNormal];
         [eWeekBtn setTitle:_sEndWeek forState:UIControlStateNormal];
         [eHMBtn setTitle:_sEndHM forState:UIControlStateNormal];
        
    }
    return cell;
}

#pragma mark - UIPickerViewDataSource
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (self.pickerType == WEEK_PICKER_VIEW)
    {
        return 1;
    }else if (self.pickerType == HM_PICKER_VIEW)
    {
        return 2;
    }
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (self.pickerType == WEEK_PICKER_VIEW)
    {
        return self.arrWeek.count;
    }else if (self.pickerType == HM_PICKER_VIEW)
    {
        if (component == 0)
        {
            return self.arrHour.count;
        }else return self.arrMintue.count;
    }
    return 0;
    
}

#pragma mark - UIPickerViewDelegate
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (self.pickerType == WEEK_PICKER_VIEW)
    {
        return [self.arrWeek objectAtIndex:row];
    }else if (self.pickerType == HM_PICKER_VIEW)
    {
        if (component == 0 ) {
            return  [self.arrHour objectAtIndex:row];
        }else if (component == 1)
        {
            return [self.arrMintue objectAtIndex:row];
        }
    }
    
    return @"test";
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.pickerType == WEEK_PICKER_VIEW)
        {
            if (self.whitchBtn == 7001)
                {
                    self.sWeekIndex = row;
                }else if (self.whitchBtn == 7002)
                        {
                            self.eWeekIndex = row;
                        }
            
        }else if (self.pickerType == HM_PICKER_VIEW)
            {
                if (component == 0 )
                    {
                        if (self.whitchBtn == 8001)
                        {
                            self.sHourIndex = row;
                        }else if (self.whitchBtn == 8002)
                        {
                            self.eHourIndex = row;
                        }
                    }else if (component == 1)
                        {
                            if (self.whitchBtn == 8001)
                            {
                                self.sMinuteIndex = row;
                            }else if (self.whitchBtn == 8002)
                            {
                                self.eMinuteIndex = row;
                            }

                        }
            }
    
    
}
#pragma mark - textField delegate M
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
    self.RECLength = textField.text.intValue;
    
}

//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
//{
//
//    return YES;
//}
//lazy loading
- (NSArray *)arrItems
{
    if (!_arrItems) {
        _arrItems = [[NSArray alloc] initWithObjects:
                     NSLocalizedString(@"Time Period", @""),
                     NSLocalizedString(@"Start REC", @""),
                     NSLocalizedString(@"End REC", @""),
                     nil];
    }
    return _arrItems;
}

- (NSArray *)arrWeek
{
    if (!_arrWeek) {
        _arrWeek = [[NSArray alloc] initWithObjects:
                    NSLocalizedString(@"Sunday", @""),
                    NSLocalizedString(@"Monday", @""),
                    NSLocalizedString(@"Tuesday", @""),
                    NSLocalizedString(@"Wednesday", @""),
                    NSLocalizedString(@"Thursday", @""),
                    NSLocalizedString(@"Friday", @""),
                    NSLocalizedString(@"Saturday", @""),
                    
                    nil];
    }
    return _arrWeek;
}
- (NSArray *)arrHour
{
    if (!_arrHour) {
        _arrHour = [[NSArray alloc] initWithObjects:
                    @"00",
                    @"01",
                    @"02",
                    @"03",
                    @"04",
                    @"05",
                    @"06",
                    @"07",
                    @"08",
                    @"09",
                    @"10",
                    @"11",
                    @"12",
                    @"13",
                    @"14",
                    @"15",
                    @"16",
                    @"17",
                    @"18",
                    @"19",
                    @"20",
                    @"21",@"22",@"23",
                    nil];
    }
    return _arrHour;
}
- (NSArray *)arrMintue
{
    if (!_arrMintue) {
        _arrMintue = [[NSArray alloc] initWithObjects:
                      @"00",
                      @"30",
                      nil];
    }
    return _arrMintue;
}

- (void) dealloc
{
    self.delegate = nil;
    [_displayTV release];
    [_basicPickerView release];
    [_pickerViewHeight release];
   
    [self.arrItems release];
    [self.arrWeek release];
    [self.arrHour release];
    [self.arrMintue release];
    [self.basicPickerView release];
    [super dealloc];
}
@end
