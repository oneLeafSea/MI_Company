//
//  RowFactory.m
//  testGData
//
//  Created by 郭志伟 on 14-11-4.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "RowFactory.h"
#import "ModuleConstants.h"
#import "RowText.h"
#import "RowName.h"
#import "RowUrl.h"
#import "RowEmail.h"
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
#import "RowSelectorSegmentedControl.h"
#import "RowDateInline.h"
#import "RowDateTimeInline.h"
#import "RowTimeInline.h"
#import "RowDate.h"
#import "RowDatetime.h"
#import "RowTime.h"
#import "RowDatePicker.h"
#import "RowPicker.h"
#import "RowSlider.h"
#import "RowBooleanCheck.h"
#import "RowBooleanSwitch.h"
#import "RowButton.h"
#import "RowInfo.h"
#import "RowStepCounter.h"

//static NSString  *kRowTypeSelectorLeftRight = @"selectorLeftRight";


@implementation RowFactory

+ (Row *)produceRow:(GDataXMLElement *)e error:(NSError **)error {
    
    NSString *tag = [[e attributeForName:kRowAttrTag] stringValue];
    if (tag.length == 0) {
        NSLog(@"row must have a tag!");
        return nil;
    }
    
    NSString *type = [[e attributeForName:kRowAttrType] stringValue];
    if (type.length == 0) {
        NSLog(@"row must have a type!");
        return nil;
    }
    
    if ([type isEqualToString:kRowTypeText]) {
        RowText *row = [[RowText alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypeName]) {
        RowName *row = [[RowName alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypeURL]) {
        RowUrl *row = [[RowUrl alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypeEmail]) {
        RowEmail *row = [[RowEmail alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypePassword]) {
        RowEmail *row = [[RowEmail alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypeNumber]) {
        RowEmail *row = [[RowEmail alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypePhone]) {
        RowEmail *row = [[RowEmail alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypeTwitter]) {
        RowTwitter *row = [[RowTwitter alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypeAccount]) {
        RowAccount *row = [[RowAccount alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypeInteger]) {
        RowInteger *row = [[RowInteger alloc] initWithXmlElement:e];
        return row;
    }
    
    
    if ([type isEqualToString:kRowTypeDecimal]) {
        RowDecimal *row = [[RowDecimal alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypeTextView]) {
        RowTextView *row = [[RowTextView alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypeSelectorPush]) {
        RowSelectorPush *row = [[RowSelectorPush alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypeSelectorPopover]) {
        RowSelectorPopover *row = [[RowSelectorPopover alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypeSelectorActionSheet]) {
        RowSelectorActionSheet *row = [[RowSelectorActionSheet alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypeSelectorAlertView]) {
        RowSelectorAlertView *row = [[RowSelectorAlertView alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypeSelectorPickerView]) {
        RowSelectorPickerView *row = [[RowSelectorPickerView alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypeSelectorPickerViewInline]) {
        RowSelectorPickerViewInline *row = [[RowSelectorPickerViewInline alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypeMultipleSelector]) {
        RowMultipleSelector *row = [[RowMultipleSelector alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypeSelectorSegmentedControl]) {
        RowSelectorSegmentedControl *row = [[RowSelectorSegmentedControl alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypeDateInline]) {
        RowDateInline *row = [[RowDateInline alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypeDateTimeInline]) {
        RowDateTimeInline *row = [[RowDateTimeInline alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypeTimeInline]) {
        RowTimeInline *row = [[RowTimeInline alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypeDate]) {
        RowDate *row = [[RowDate alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypeDateTime]) {
        RowDatetime *row = [[RowDatetime alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypeTime]) {
        RowTime *row = [[RowTime alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypeDatePicker]) {
        RowDatePicker *row = [[RowDatePicker alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypePicker]) {
        RowPicker *row = [[RowPicker alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypeSlider]) {
        RowSlider *row = [[RowSlider alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypeBooleanCheck]) {
        RowBooleanCheck *row = [[RowBooleanCheck alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypeBooleanSwitch]) {
        RowBooleanSwitch *row = [[RowBooleanSwitch alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypeButton]) {
        RowButton *row = [[RowButton alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypeInfo]) {
        RowInfo *row = [[RowInfo alloc] initWithXmlElement:e];
        return row;
    }
    
    if ([type isEqualToString:kRowTypeStepCounter]) {
        RowStepCounter *row = [[RowStepCounter alloc] initWithXmlElement:e];
        return row;
    }
    NSLog(@"unkown type :%@", type);
    return nil;
}

@end
