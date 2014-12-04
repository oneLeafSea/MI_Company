//
//  PageViewController.m
//  dongrun_beijing
//
//  Created by 郭志伟 on 14-11-1.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "PageViewController.h"
#import "XLForm.h"
#import "PagesMgrViewController.h"

@interface PageViewController ()<SwipeContainerChildItem> {

}

@end

@implementation PageViewController

- (instancetype)init {
    XLFormDescriptor *form = [self newForm];
    [self initializeForm:form];
    return [super initWithForm:form];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    if([[[UIDevice currentDevice]systemVersion]floatValue]>=7.0
       && [[[UIDevice currentDevice]systemVersion]floatValue]<8.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (BOOL) initializeForm:(XLFormDescriptor *)form {
    NSLog(@"you should overide initialize Form method!");
    return YES;
}

- (BOOL) VerifyData {
    return YES;
}

- (BOOL) SaveData {
    return YES;
}

- (NSString *)nameForPageContainer:(PagesMgrViewController *)swipeContainer {
    return self.title;
}

@end

#pragma mark -PageViewController (helper)

@implementation PageViewController (helper)

- (XLFormDescriptor *) newForm {
    XLFormDescriptor *form = [XLFormDescriptor formDescriptor];
    return form;
}

- (XLFormSectionDescriptor *) newSectionWithTitle:(NSString *)title {
    XLFormSectionDescriptor *section = [XLFormSectionDescriptor formSectionWithTitle:title];
    return section;
}

- (XLFormRowDescriptor *) newTextWithTag:(NSString *)tag Title:(NSString *)title Placeholder:(NSString *)placeholder {
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeText];
    if (placeholder) {
        [row.cellConfigAtConfigure setObject:placeholder forKey:@"textField.placeholder"];
    }
    [row.cellConfigAtConfigure setObject:[UIColor lightGrayColor] forKey:@"textField.textColor"];
    row.title = title;
    return row;
}

- (XLFormRowDescriptor *) newNameWithTag:(NSString *)tag title:(NSString *)title Placeholder:(NSString *)placeholder {
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeName title:title];
    if (placeholder) {
        [row.cellConfigAtConfigure setObject:placeholder forKey:@"textField.placeholder"];
    }
    return row;
}

- (XLFormRowDescriptor *) newURLWithTag:(NSString *)tag Title:(NSString *)title  Placeholder:(NSString *)placeholder{
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeURL title:title];
    if (placeholder) {
        [row.cellConfigAtConfigure setObject:placeholder forKey:@"textField.placeholder"];
    }
    return row;
}

- (XLFormRowDescriptor *) newEmailWithTag:(NSString *)tag Title:(NSString *)title Placeholder:(NSString *)placeholder{
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeEmail title:title];
    if (placeholder) {
        [row.cellConfigAtConfigure setObject:placeholder forKey:@"textField.placeholder"];
    }
    return row;
}

- (XLFormRowDescriptor *) newPasswordWithTag:(NSString *)tag Title:(NSString *)title Placeholder:(NSString *)placeholder{
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypePassword title:title];
    if (placeholder) {
        [row.cellConfigAtConfigure setObject:placeholder forKey:@"textField.placeholder"];
    }
    return row;
}

- (XLFormRowDescriptor *) newNumberWithTag:(NSString *)tag Title:(NSString *)title Placeholder:(NSString *)placeholder {
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeNumber title:title];
    if (placeholder) {
        [row.cellConfigAtConfigure setObject:placeholder forKey:@"textField.placeholder"];
    }
    return row;
}

- (XLFormRowDescriptor *) newPhoneWithTag:(NSString *)tag Title:(NSString *)title Placeholder:(NSString *)placeholder{
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeNumber title:title];
    if (placeholder) {
        [row.cellConfigAtConfigure setObject:placeholder forKey:@"textField.placeholder"];
    }
    return row;
}

- (XLFormRowDescriptor *) newTwitterWithTag:(NSString *)tag Title:(NSString *)title Placeholder:(NSString *)placeholder {
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeTwitter title:title];
    if (placeholder) {
        [row.cellConfigAtConfigure setObject:placeholder forKey:@"textField.placeholder"];
    }
    return row;
}

- (XLFormRowDescriptor *) newAccountWithTag:(NSString *)tag Title:(NSString *)title Placeholder:(NSString *)placeholder{
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeAccount title:title];
    if (placeholder) {
        [row.cellConfigAtConfigure setObject:placeholder forKey:@"textField.placeholder"];
    }
    return row;
}

- (XLFormRowDescriptor *) newIntegerWithTag:(NSString *)tag Title:(NSString *)title Placeholder:(NSString *)placeholder {
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeInteger title:title];
    if (placeholder) {
        [row.cellConfigAtConfigure setObject:placeholder forKey:@"textField.placeholder"];
    }
    return row;
}

- (XLFormRowDescriptor *) newDecimalWithTag:(NSString *)tag Title:(NSString *)title Placeholder:(NSString *)placeholder{
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeDecimal title:title];
    if (placeholder) {
        [row.cellConfigAtConfigure setObject:placeholder forKey:@"textField.placeholder"];
    }
    return row;
}

- (XLFormRowDescriptor *) newTextViewWithTag:(NSString *)tag Title:(NSString *)title Placeholder:(NSString *)placeHolder {
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeTextView title:title];
    if (placeHolder) {
        [row.cellConfigAtConfigure setObject:placeHolder forKey:@"textView.placeholder"];
    }
    
    return row;
}

#pragma mark - selector
- (XLFormRowDescriptor *) newSelectorPushWithTag:(NSString *)tag Title:(NSString *)title Options:(NSArray *)options defaultIndex:(NSUInteger)index {
    if (index >= options.count) {
        NSLog(@"the index is invalid, tag is %@.", tag);
        return nil;
    }
    
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeSelectorPush title:title];
    row.selectorOptions = [self genOptionObjs:options];
    row.selectorTitle = title;
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(index) displayText:options[index]];
    return row;
}

- (XLFormRowDescriptor *)newSelectorPopoverWithTag:(NSString *)tag Title:(NSString *)title Options:(NSArray *)options defaultIndex:(NSUInteger)index {
    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        NSLog(@"this method only for pad!");
        return nil;
    }
    if (index >= options.count) {
        NSLog(@"the index is invalid, tag is%@.", tag);
        return nil;
    }
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeSelectorPopover title:title];
    row.selectorOptions = [self genOptionObjs:options];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(index) displayText:options[index]];
    return row;
}

- (XLFormRowDescriptor *) newSelectorActionSheetWithTag:(NSString *)tag Title:(NSString *)title Options:(NSArray *)options defaultIndex:(NSUInteger)index {
    if (index >= options.count) {
        NSLog(@"the index is invalid, tag is%@.", tag);
        return nil;
    }
    
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeSelectorActionSheet title:title];
    row.selectorOptions = [self genOptionObjs:options];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(index) displayText:options[index]];
    return row;
}

- (XLFormRowDescriptor *) newSelectorAlertViewWithTag:(NSString *)tag Title:(NSString *)title Options:(NSArray *)options defaultIndex:(NSUInteger)index {
    if (index >= options.count) {
        NSLog(@"the index is invalid, tag is%@.", tag);
        return nil;
    }
    
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeSelectorAlertView title:title];
    row.selectorOptions = [self genOptionObjs:options];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(index) displayText:options[index]];
    return row;
}


- (XLFormRowDescriptor *) newSelectorPickerViewWithTag:(NSString *)tag Title:(NSString *)title Options:(NSArray *)options defaultIndex:(NSUInteger)index {
    if (index >= options.count) {
        NSLog(@"the index is invalid, tag is%@.", tag);
        return nil;
    }
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeSelectorPickerView title:title];
    row.selectorOptions = [self genOptionObjs:options];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(index) displayText:options[index]];
    return row;
}

- (XLFormRowDescriptor *) newSelectorPickerViewInlineWithTag:(NSString *)tag Title:(NSString *)title Options:(NSArray *)options defaultIndex:(NSUInteger)index {
    if (index >= options.count) {
        NSLog(@"the index is invalid, tag is%@.", tag);
        return nil;
    }
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeSelectorPickerViewInline title:title];
    row.selectorOptions = [self genOptionObjs:options];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(index) displayText:options[index]];
    return row;
}

- (XLFormRowDescriptor *) newMultipleSelectorWithTag:(NSString *)tag Title:(NSString *)title Options:(NSArray *)options defaultValues:(NSArray *)vals {
    
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeMultipleSelector title:title];
    row.selectorOptions = options;
    row.value = vals;
    row.selectorTitle = title;
    return row;
}


- (XLFormRowDescriptor *) newMultipleSelectorPopoverWithTag:(NSString *)tag Title:(NSString *)title Options:(NSArray *)options defaultValues:(NSArray *)vals {
    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad){
        NSLog(@"this method only for pad!");
        return nil;
    }
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeMultipleSelectorPopover title:title];
    row.selectorOptions = options;
    row.value = vals;
    return row;
}

- (XLFormRowDescriptor *) newSelectorLeftRightWithTag:(NSString *)tag Title:(NSString *)title Options:(NSArray *)options {
    
//    NSMutableArray *leftOptions = [[NSMutableArray alloc]init];
//    for (NSDictionary *opt in options) {
//        
//    }
//    
//    Row *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeSelectorLeftRight title:title];
//    row.leftRightSelectorLeftOptionSelected = [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Option 2"];
//    
//    
//    NSArray * rightOptions = [self genOptionObjs:aRightOptions];
//    
//    // create right selectors
//    NSMutableArray * leftRightSelectorOptions = [[NSMutableArray alloc] init];
//    NSMutableArray * mutableRightOptions = [rightOptions mutableCopy];
//    
//
//    [mutableRightOptions removeObjectAtIndex:0];
//    
//    XLFormLeftRightSelectorOption * leftRightSelectorOption = [XLFormLeftRightSelectorOption formLeftRightSelectorOptionWithLeftValue:[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Option 1"] httpParameterKey:@"option_1" rightOptions:mutableRightOptions];
//    
//    [leftRightSelectorOptions addObject:leftRightSelectorOption];
//    
//    mutableRightOptions = [rightOptions mutableCopy];
//    [mutableRightOptions removeObjectAtIndex:1];
//    leftRightSelectorOption = [XLFormLeftRightSelectorOption formLeftRightSelectorOptionWithLeftValue:[XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Option 2"] httpParameterKey:@"option_2" rightOptions:mutableRightOptions];
//    [leftRightSelectorOptions addObject:leftRightSelectorOption];
//    
//    mutableRightOptions = [rightOptions mutableCopy];
//    [mutableRightOptions removeObjectAtIndex:2];
//    leftRightSelectorOption = [XLFormLeftRightSelectorOption formLeftRightSelectorOptionWithLeftValue:[XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Option 3"]  httpParameterKey:@"option_3" rightOptions:mutableRightOptions];
//    [leftRightSelectorOptions addObject:leftRightSelectorOption];
//    
//    mutableRightOptions = [rightOptions mutableCopy];
//    [mutableRightOptions removeObjectAtIndex:3];
//    leftRightSelectorOption = [XLFormLeftRightSelectorOption formLeftRightSelectorOptionWithLeftValue:[XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Option 4"] httpParameterKey:@"option_4" rightOptions:mutableRightOptions];
//    [leftRightSelectorOptions addObject:leftRightSelectorOption];
//    
//    mutableRightOptions = [rightOptions mutableCopy];
//    [mutableRightOptions removeObjectAtIndex:4];
//    leftRightSelectorOption = [XLFormLeftRightSelectorOption formLeftRightSelectorOptionWithLeftValue:[XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Option 5"] httpParameterKey:@"option_5" rightOptions:mutableRightOptions];
//    [leftRightSelectorOptions addObject:leftRightSelectorOption];
//    
//    row.selectorOptions  = leftRightSelectorOptions;
//    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Right Option 4"];
//    [section addFormRow:row];
    return nil;
}


- (XLFormRowDescriptor *) newSelectorSegmentedControlWithTag:(NSString *)tag Title:(NSString *)title Options:(NSArray *)options defaultValue:(NSString *)value {
    XLFormRowDescriptor * row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeSelectorSegmentedControl title:title];
    row.selectorOptions = options;
    row.value = value;
    return row;
}


- (XLFormRowDescriptor *) newDateInlineWithTag:(NSString *)tag Title:(NSString *)title defaultValue:(NSDate *)date {
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeDateInline title:title];
    if (date == nil) {
        row.value = [NSDate new];
    } else {
        row.value = date;
    }
    return row;
}

- (XLFormRowDescriptor *) newDateTimeInlineWithTag:(NSString *)tag Title:(NSString *)title defaultValue:(NSDate *)date {
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeDateTimeInline title:title];
    if (date == nil) {
        row.value = [NSDate new];
    } else {
        row.value = date;
    }
    return row;
}

- (XLFormRowDescriptor *) newTimeInlineWithTag:(NSString *)tag Title:(NSString *)title defaultValue:(NSDate *)date {
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeTimeInline title:title];
    if (date == nil) {
        row.value = [NSDate new];
    } else {
        row.value = date;
    }
    return row;
}

- (XLFormRowDescriptor *) newDateWithTag:(NSString *)tag Title:(NSString *)title defaultValue:(NSDate *)date {
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeDate title:title];
    if (date == nil) {
        row.value = [NSDate new];
    } else {
        row.value = date;
    }
    return row;
}

- (XLFormRowDescriptor *)newDateTimeWithTag:(NSString *)tag Title:(NSString *)title defaultValue:(NSDate *)date {
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeDateTime title:title];
    if (date == nil) {
        row.value = [NSDate new];
    } else {
        row.value = date;
    }
    return row;
}

- (XLFormRowDescriptor *)newTimeWithTag:(NSString *)tag Title:(NSString *)title defaultValue:(NSDate *)date {
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeTime title:title];
    if (date == nil) {
        row.value = [NSDate new];
    } else {
        row.value = date;
    }
    return row;
}

- (XLFormRowDescriptor *)newDatePickerWithTag:(NSString *)tag Title:(NSString *)title defaultValue:(NSDate *)date {
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeDatePicker title:title];
    if (date == nil) {
        row.value = [NSDate new];
    } else {
        row.value = date;
    }
    return row;
}

- (XLFormRowDescriptor *)newPickerWithTag:(NSString *)tag Options:(NSArray *)options defaultValue:(NSString *)value {
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypePicker];
    row.selectorOptions = options;
    row.value = value;
    return row;
}

- (XLFormRowDescriptor *)newSliderWithTag:(NSString *)tag Title:(NSString *)title defaultValue:(NSUInteger)val Step:(NSUInteger)step Max:(NSUInteger)max Min:(NSUInteger)min {
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeSlider title:title];
    row.value = @(val);
    [row.cellConfigAtConfigure setObject:@(max) forKey:@"slider.maximumValue"];
    [row.cellConfigAtConfigure setObject:@(min) forKey:@"slider.minimumValue"];
    [row.cellConfigAtConfigure setObject:@(step) forKey:@"steps"];
    return row;
}

- (XLFormRowDescriptor *)newBooleanCheckWithTag:(NSString *)tag Title:(NSString *)title defaultValue:(BOOL)vaule {
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeBooleanCheck title:title];
    row.value = @(vaule);
    return row;
}

- (XLFormRowDescriptor *)newBooleanSwitchWithTag:(NSString *)tag Title:(NSString *)title defaultValue:(BOOL)vaule {
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeBooleanSwitch title:title];
    row.value = @(vaule);
    return row;
}

- (XLFormRowDescriptor *) newButtonWithTag:(NSString *)tag Title:(NSString *)title {
    XLFormRowDescriptor * row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeButton title:title];
    return row;
}

- (XLFormRowDescriptor *) newInfoWithTag:(NSString *)tag Title:(NSString *)title Value:(NSString *)value {
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:tag rowType:XLFormRowDescriptorTypeInfo];
    row.title = title;
    row.value = value;
    return row;
}

- (XLFormRowDescriptor *) newStepCounterWithTag:(NSString *)tag Title:(NSString *)title {
    XLFormRowDescriptor *row = [XLFormRowDescriptor formRowDescriptorWithTag:title rowType:XLFormRowDescriptorTypeStepCounter title:title];
    return row;
}

#pragma mark - private metod
- (NSArray *)genOptionObjs:(NSArray *)src {
    __block NSMutableArray *arr = [[NSMutableArray alloc] init];
    [src enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *val = obj;
        XLFormOptionsObject *optObj = [XLFormOptionsObject formOptionsObjectWithValue:@(idx) displayText:val];
        [arr addObject:optObj];
    }];
    return arr;
}

@end

