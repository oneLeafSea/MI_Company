//
//  ModuleDefaultPageViewController.m
//  dongrun_beijing
//
//  Created by guozw on 14/11/6.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "ModuleDefaultPageViewController.h"
#import "ModuleConstants.h"
#import "PagesMgrViewController.h"
#import "LogLevel.h"


#import "Row.h"
#import "RowText.h"
#import "RowName.h"
#import "RowUrl.h"
#import "RowEmail.h"
#import "RowPassword.h"
#import "RowNumber.h"
#import "RowPhone.h"
#import "RowTwitter.h"
#import "RowAccount.h"
#import "RowInteger.h"
#import "RowDecimal.h"
#import "RowTextView.h"
#import "RowSelectorPush.h"
#import "RowSelectorPopover.h"
#import "RowSelectorActionSheet.h"
#import "RowSelectorAlertView.h"
#import "RowSelectorPickerView.h"
#import "RowSelectorPickerViewInline.h"
#import "RowMultipleSelector.h"
#import "RowMultipleSelectorPopover.h"
#import "RowSelectorSegmentedControl.h"
#import "RowDateInline.h"
#import "RowDateTimeInline.h"
#import "RowDatetime.h"
#import "RowTimeInline.h"
#import "RowDate.h"
#import "RowTime.h"
#import "RowDatePicker.h"
#import "RowSlider.h"
#import "RowBooleanCheck.h"
#import "RowBooleanSwitch.h"
#import "RowButton.h"
#import "RowInfo.h"
#import "RowStepCounter.h"


static NSString *kPlistType = @"plist";

@interface ModuleDefaultPageViewController()<SwipeContainerChildItem> {
    Page *m_page;
    
}
@property(nonatomic) NSString *title;
@end

@implementation ModuleDefaultPageViewController

- (instancetype) initWithPage:(Page *)page {
    m_page = page;
    if (self = [super init]) {
        
    }
    self.title = m_page.title;
    return self;
}

- (BOOL)initializeForm:(XLFormDescriptor *)form {
    BOOL ret = YES;
    for (Section *sect in m_page.sections) {
        if (![self buildSection:sect form:form]) {
            ret = NO;
            break;
        }
    }
    return ret;
}

- (BOOL)buildSection:(Section *)sect form:(XLFormDescriptor *)form {
    XLFormSectionDescriptor * sd = [self newSectionWithTitle:sect.title];
    BOOL ret = YES;
    for (Row *row in sect.rows) {
        if (![self buildRow:row section:sd]) {
            ret = NO;
            break;
        }
    }
    if (ret) {
        [form addFormSection:sd];
    }
    return ret;
}

- (BOOL)buildRow:(Row *)row section:(XLFormSectionDescriptor *)sect {
    if ([row.type isEqualToString:kRowTypeText]) {
        RowText *rowText = (RowText *)row;
        XLFormRowDescriptor *rd = [self newTextWithTag:rowText.type Title:rowText.title Placeholder:rowText.placeholder];
        rd.disabled = rowText.disable;
        rd.value = rowText.defaultValue;
        [sect addFormRow:rd];
        return YES;
    }
    
    if ([row.type isEqualToString:kRowTypeName]) {
        RowName *rowName = (RowName *)row;
        XLFormRowDescriptor *rd = [self newNameWithTag:rowName.tag title:rowName.title Placeholder:rowName.placeholder];
        rd.disabled = rowName.disable;
        rd.value = rowName.defaultValue;
        [sect addFormRow:rd];
        return YES;
    }
    
    if ([row.type isEqualToString:kRowTypeURL]) {
        RowUrl *rowUrl = (RowUrl *)row;
        XLFormRowDescriptor *rd = [self newURLWithTag:kRowTypeURL Title:rowUrl.title Placeholder:rowUrl.placeholder];
        rd.disabled = rowUrl.disable;
        rd.value = rowUrl.defaultValue;
        [sect addFormRow:rd];
        return YES;
    }
    
    if ([row.type isEqualToString:kRowTypeEmail]) {
        RowEmail *rowEmail = (RowEmail *)row;
        XLFormRowDescriptor *rd = [self newEmailWithTag:kRowTypeEmail Title:rowEmail.title Placeholder:rowEmail.placeholder];
        rd.disabled = rowEmail.disable;
        rd.value = rowEmail.defaultValue;
        [sect addFormRow:rd];
        return YES;
    }
    
    if ([row.type isEqualToString:kRowTypePassword]) {
        RowPassword *rowPassword = (RowPassword *)row;
        XLFormRowDescriptor *rd = [self newPasswordWithTag:kRowTypePassword Title:rowPassword.title Placeholder:rowPassword.placeholder];
        rd.disabled = rowPassword.disable;
        rd.value = rowPassword.defaultValue;
        [sect addFormRow:rd];
        return YES;
    }
    
    if ([row.type isEqualToString:kRowTypeNumber]) {
        
        RowNumber *num = (RowNumber *)row;
        XLFormRowDescriptor *rd = [self newNumberWithTag:num.tag Title:num.title Placeholder:num.placeholder];
        rd.disabled = num.disable;
        rd.value = num.defaultValue;
        [sect addFormRow:rd];
        return YES;
    }
    
    if ([row.type isEqualToString:kRowTypePhone]) {
        RowPhone *phone = (RowPhone *)row;
        XLFormRowDescriptor *rd = [self newPhoneWithTag:phone.tag Title:phone.title Placeholder:phone.placeholder];
        rd.disabled = phone.disable;
        rd.value = phone.defaultValue;
        [sect addFormRow:rd];
        return YES;
    }
    
    if ([row.type isEqualToString:kRowTypeTwitter]) {
        RowTwitter *twitter = (RowTwitter *)row;
        XLFormRowDescriptor *rd = [self newTwitterWithTag:twitter.tag Title:twitter.title Placeholder:twitter.placeholder];
        rd.disabled = twitter.disable;
        rd.value = twitter.defaultValue;
        [sect addFormRow:rd];
        return YES;
    }
    
    if ([row.type isEqualToString:kRowTypeAccount]) {
        RowAccount *account = (RowAccount *)row;
        XLFormRowDescriptor *rd = [self newAccountWithTag:account.tag Title:account.title Placeholder:account.placeholder];
        rd.disabled = account.disable;
        rd.value = account.defaultValue;
        [sect addFormRow:rd];
        return YES;
    }
    
    
    if ([row.type isEqualToString:kRowTypeInteger]) {
        RowInteger *integer = (RowInteger *)row;
        XLFormRowDescriptor *rd = [self newIntegerWithTag:integer.tag Title:integer.title Placeholder:integer.placeholder];
        rd.disabled = integer.disable;
        rd.value = integer.defaultValue;
        [sect addFormRow:rd];
        return YES;
    }
    
    if ([row.type isEqualToString:kRowTypeDecimal]) {
        RowDecimal *decimal = (RowDecimal *)row;
        XLFormRowDescriptor *rd = [self newDecimalWithTag:decimal.tag Title:decimal.title Placeholder:decimal.placeholder];
        rd.disabled = decimal.disable;
        rd.value = decimal.defaultValue;
        [sect addFormRow:rd];
        return YES;
    }
    
    if ([row.type isEqualToString:kRowTypeTextView]) {
        RowTextView *textView = (RowTextView *)row;
        XLFormRowDescriptor *rd = [self newTextViewWithTag:textView.tag Title:textView.title Placeholder:textView.placeholder];
        rd.disabled = textView.disable;
        rd.value = textView.defaultValue;
        [sect addFormRow:rd];
        return YES;
    }
    
    if ([row.type isEqualToString:kRowTypeSelectorPush]) {
        RowSelectorPush *selectorPush = (RowSelectorPush *)row;
        NSInteger index = [selectorPush.defaultValue integerValue];
        NSArray *plistContent =  [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:selectorPush.plistName ofType:kPlistType]];
        XLFormRowDescriptor *rd = [self newSelectorPushWithTag:selectorPush.tag Title:selectorPush.title Options:plistContent defaultIndex:index];
        rd.disabled = selectorPush.disable;
        [sect addFormRow:rd];
        return YES;
    }
    
    // for ipad not test.
    if ([row.type isEqualToString:kRowTypeSelectorPopover]) {
        RowSelectorPopover *selectorPopover = (RowSelectorPopover *)row;
        NSInteger index = [selectorPopover.defaultValue integerValue];
        NSArray *plistContent =  [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:selectorPopover.plistName ofType:kPlistType]];
        XLFormRowDescriptor *rd = [self newSelectorPopoverWithTag:selectorPopover.tag Title:selectorPopover.title Options:plistContent defaultIndex:index];
        rd.disabled = selectorPopover.disable;
        [sect addFormRow:rd];
        return YES;
    }
    
    if ([row.type isEqualToString:kRowTypeSelectorActionSheet]) {
        RowSelectorActionSheet *selectorActionSheet = (RowSelectorActionSheet *)row;
        NSInteger index = [selectorActionSheet.defaultValue integerValue];
        NSArray *plistContent =  [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:selectorActionSheet.plistName ofType:kPlistType]];
        XLFormRowDescriptor *rd = [self newSelectorActionSheetWithTag:selectorActionSheet.tag Title:selectorActionSheet.title Options:plistContent defaultIndex:index];
        rd.disabled = selectorActionSheet.disable;
        [sect addFormRow:rd];
        return YES;
    }
    
    if ([row.type isEqualToString:kRowTypeSelectorAlertView]) {
        RowSelectorAlertView *selectorAlertView = (RowSelectorAlertView *)row;
        NSInteger index = [selectorAlertView.defaultValue integerValue];
        NSArray *plistContent =  [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:selectorAlertView.plistName ofType:kPlistType]];
        XLFormRowDescriptor *rd = [self newSelectorAlertViewWithTag:selectorAlertView.tag Title:selectorAlertView.title Options:plistContent defaultIndex:index];
        rd.disabled = selectorAlertView.disable;
        [sect addFormRow:rd];
        return YES;
    }
    
    if ([row.type isEqualToString:kRowTypeSelectorPickerView]) {
        RowSelectorPickerView *selectorPickerView = (RowSelectorPickerView *)row;
        NSInteger index = [selectorPickerView.defaultValue integerValue];
        NSArray *plistContent =  [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:selectorPickerView.plistName ofType:kPlistType]];
        XLFormRowDescriptor *rd = [self newSelectorPickerViewWithTag:selectorPickerView.tag Title:selectorPickerView.title Options:plistContent defaultIndex:index];
        rd.disabled = selectorPickerView.disable;
        [sect addFormRow:rd];
        return YES;
    }
    
    if ([row.type isEqualToString:kRowTypeSelectorPickerViewInline]) {
        RowSelectorPickerViewInline *selectorPickerViewInline = (RowSelectorPickerViewInline *)row;
        NSInteger index = [selectorPickerViewInline.defaultValue integerValue];
        NSArray *plistContent =  [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:selectorPickerViewInline.plistName ofType:kPlistType]];
        XLFormRowDescriptor *rd = [self newSelectorPickerViewInlineWithTag:selectorPickerViewInline.tag Title:selectorPickerViewInline.title Options:plistContent defaultIndex:index];
        rd.disabled = selectorPickerViewInline.disable;
        [sect addFormRow:rd];
        return YES;
    }
    
    if ([row.type isEqualToString:kRowTypeMultipleSelector]) {
        RowMultipleSelector *multipleSelector = (RowMultipleSelector *)row;
//        NSInteger index = [multipleSelector.defaultValue integerValue];
        NSArray *plistContent =  [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:multipleSelector.plistName ofType:kPlistType]];
        XLFormRowDescriptor *rd = [self newMultipleSelectorWithTag:multipleSelector.tag Title:multipleSelector.title Options:plistContent defaultValues:nil];
        rd.disabled = multipleSelector.disable;
        [sect addFormRow:rd];
        return YES;
    }
    
    if ([row.type isEqualToString:kRowTypeMultipleSelectorPopover]) {
        RowMultipleSelectorPopover *multipleSelectorPopover = (RowMultipleSelectorPopover *)row;
        //        NSInteger index = [multipleSelector.defaultValue integerValue];
        NSArray *plistContent =  [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:multipleSelectorPopover.plistName ofType:kPlistType]];
        XLFormRowDescriptor *rd = [self newMultipleSelectorPopoverWithTag:multipleSelectorPopover.tag Title:multipleSelectorPopover.title Options:plistContent defaultValues:nil];
        rd.disabled = multipleSelectorPopover.disable;
        [sect addFormRow:rd];
        return YES;
    }

    if ([row.type isEqualToString:kRowTypeSelectorSegmentedControl]) {
        RowSelectorSegmentedControl *selectorSegmentedControl = (RowSelectorSegmentedControl *)row;
        NSArray *plistContent =  [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:selectorSegmentedControl.plistName ofType:kPlistType]];
        XLFormRowDescriptor *rd = [self newSelectorSegmentedControlWithTag:selectorSegmentedControl.tag Title:selectorSegmentedControl.title Options:plistContent defaultValue:row.defaultValue];
        rd.disabled = selectorSegmentedControl.disable;
        [sect addFormRow:rd];
        return YES;
    }
    
    if ([row.type isEqualToString:kRowTypeDateInline]) {
        RowDateInline *dateInline = (RowDateInline *)row;
        XLFormRowDescriptor *rd = [self newDateInlineWithTag:dateInline.tag Title:dateInline.title defaultValue:nil];
        rd.disabled = dateInline.disable;
        [sect addFormRow:rd];
        return YES;
    }
    
    if ([row.type isEqualToString:kRowTypeDateTimeInline]) {
        RowDateTimeInline *datetimeInline = (RowDateTimeInline *)row;
        XLFormRowDescriptor *rd = [self newDateTimeInlineWithTag:datetimeInline.tag Title:datetimeInline.title defaultValue:nil];
        rd.disabled = datetimeInline.disable;
        [sect addFormRow:rd];
        return YES;
    }
    
    if ([row.type isEqualToString:kRowTypeTimeInline]) {
        RowTimeInline *timeInline = (RowTimeInline *)row;
        XLFormRowDescriptor *rd = [self newTimeInlineWithTag:timeInline.tag Title:timeInline.title defaultValue:nil];
        rd.disabled = timeInline.disable;
        [sect addFormRow:rd];
        return YES;
    }
    
    if ([row.type isEqualToString:kRowTypeDate]) {
        RowDate *date = (RowDate *)row;
        XLFormRowDescriptor *rd = [self newDateWithTag:date.tag Title:date.title defaultValue:nil];
        rd.disabled = date.disable;
        [sect addFormRow:rd];
        return YES;
    }
    
    if ([row.type isEqualToString:kRowTypeDateTime]) {
        RowDatetime *datetime = (RowDatetime *)row;
        XLFormRowDescriptor *rd = [self newDateTimeWithTag:datetime.tag Title:datetime.title defaultValue:nil];
        rd.disabled = datetime.disable;
        [sect addFormRow:rd];
        return YES;
    }
    
    if ([row.type isEqualToString:kRowTypeTime]) {
        RowTime *time = (RowTime *)row;
        XLFormRowDescriptor *rd = [self newTimeWithTag:time.tag Title:time.title defaultValue:nil];
        rd.disabled = time.disable;
        [sect addFormRow:rd];
        return YES;
    }
    
    if ([row.type isEqualToString:kRowTypeDatePicker]) {
        RowDatePicker *datePicker = (RowDatePicker *)row;
        XLFormRowDescriptor *rd = [self newDatePickerWithTag:datePicker.tag Title:datePicker.title defaultValue:nil];
        rd.disabled = datePicker.disable;
        [sect addFormRow:rd];
        return YES;
    }
    
    if ([row.type isEqualToString:kRowTypeSlider]) {
        RowSlider *slider = (RowSlider *)row;
        XLFormRowDescriptor *rd = [self newSliderWithTag:slider.tag Title:slider.title defaultValue:0 Step:1 Max:100 Min:0];
        rd.disabled = slider.disable;
        [sect addFormRow:rd];
        return YES;
    }
    
    if ([row.type isEqualToString:kRowTypeBooleanCheck]) {
        RowBooleanCheck *booleanCheck = (RowBooleanCheck *)row;
        BOOL defaultValue = [booleanCheck.defaultValue isEqualToString:@"yes"];
        XLFormRowDescriptor *rd = [self newBooleanCheckWithTag:booleanCheck.type Title:booleanCheck.title defaultValue:defaultValue];
        rd.disabled = booleanCheck.disable;
        [sect addFormRow:rd];
        return YES;
    }
    
    if ([row.type isEqualToString:kRowTypeBooleanSwitch]) {
        RowBooleanSwitch *booleanSwitch = (RowBooleanSwitch *)row;
        BOOL defaultValue = [booleanSwitch.defaultValue isEqualToString:@"yes"];
        XLFormRowDescriptor *rd = [self newBooleanSwitchWithTag:booleanSwitch.tag Title:booleanSwitch.title defaultValue:defaultValue];
        rd.disabled = booleanSwitch.disable;
        [sect addFormRow:rd];
        return YES;
    }
    
    if ([row.type isEqualToString:kRowTypeButton]) {
        RowButton *button = (RowButton *)row;
        XLFormRowDescriptor *rd = [self newButtonWithTag:button.tag Title:button.title];
        rd.disabled = button.disable;
        [sect addFormRow:rd];
        return YES;
    }
    
    if ([row.type isEqualToString:kRowTypeInfo]) {
        RowInfo *info = (RowInfo *)row;
        XLFormRowDescriptor *rd = [self newInfoWithTag:info.tag Title:info.title Value:info.value];
        rd.disabled = info.disable;
        [sect addFormRow:rd];
        return YES;
    }
    
    if ([row.type isEqualToString:kRowTypeStepCounter]) {
        RowStepCounter *stepCounter = (RowStepCounter *)row;
         XLFormRowDescriptor *rd = [self newStepCounterWithTag:stepCounter.tag Title:stepCounter.title];
        rd.disabled = stepCounter.disable;
        [sect addFormRow:rd];
        return YES;
    }
/*
    static NSString  *kRowTypeSelectorLeftRight = @"selectorLeftRight";
    */
    DDLogError(@"unkown row type %@ title:%@", row.type, row.title);
    return NO;
}

- (NSString *)nameForPageContainer:(PagesMgrViewController *)swipeContainer {
    return self.title;
}

@end
