//
//  PageViewController.h
//  dongrun_beijing
//
//  Created by 郭志伟 on 14-11-1.
//  Copyright (c) 2014年 rooten. All rights reserved.
//

#import "XLFormViewController.h"

//typedef XLFormDescriptor Form;
//typedef XLFormSectionDescriptor Sect;
//typedef XLFormRowDescriptor     Row;

@interface PageViewController : XLFormViewController

- (BOOL) initializeForm:(XLFormDescriptor *)form;
- (BOOL) VerifyData;
- (BOOL) SaveData;


@end
/*  XML
<app>
    <modules>
        <module name = "客户拜访" type = "query" image= "base64">
             <pages>
                <page title = "title">
                    <row tag = "123" title= "title" type = "date" placeholder ="placeholder" regx = ""/>
                    <row tag = "123" title= "title" type = "date" placeholder ="placeholder"/>
                    <row tag = "123" title= "title" type = "date" placeholder ="placeholder"/>
                    <row tag = "123" title= "title" type = "date" placeholder ="placeholder"/>
                </page>
                 <page>
                     <row tag = "123" title= "title" type = "date" placeholder ="placeholder" regx = ""/>
                     <row tag = "123" title= "title" type = "date" placeholder ="placeholder"/>
                     <row tag = "123" title= "title" type = "date" placeholder ="placeholder"/>
                     <row tag = "123" title= "title" type = "date" placeholder ="placeholder"/>
                 </page>
             </pages>
        </module>
        ....
    </modules>
</app>
 */

@interface PageViewController (helper)


- (XLFormDescriptor *) newForm;

- (XLFormSectionDescriptor *) newSectionWithTitle:(NSString *)title;


#pragma mark -TextField
- (XLFormRowDescriptor *) newTextWithTag:(NSString *)tag Title:(NSString *)title Placeholder:(NSString *)placeholder;
- (XLFormRowDescriptor *) newNameWithTag:(NSString *)tag title:(NSString *)title Placeholder:(NSString *)placeholder;
- (XLFormRowDescriptor *) newURLWithTag:(NSString *)tag Title:(NSString *) title Placeholder:(NSString *)placeholder;
- (XLFormRowDescriptor *) newEmailWithTag:(NSString *)tag Title:(NSString *)title Placeholder:(NSString *)placeholder;
- (XLFormRowDescriptor *) newPasswordWithTag:(NSString *)tag Title:(NSString *)title Placeholder:(NSString *)placeholder;
- (XLFormRowDescriptor *) newNumberWithTag:(NSString *)tag Title:(NSString *)title Placeholder:(NSString *)placeholder;
- (XLFormRowDescriptor *) newPhoneWithTag:(NSString *)tag Title:(NSString *)title Placeholder:(NSString *)placeholder;
- (XLFormRowDescriptor *) newTwitterWithTag:(NSString *)tag Title:(NSString *)title Placeholder:(NSString *)placeholder;
- (XLFormRowDescriptor *) newAccountWithTag:(NSString *)tag Title:(NSString *)title Placeholder:(NSString *)placeholde;
- (XLFormRowDescriptor *) newIntegerWithTag:(NSString *)tag Title:(NSString *)title Placeholder:(NSString *)placeholde;
- (XLFormRowDescriptor *) newDecimalWithTag:(NSString *)tag Title:(NSString *)title Placeholder:(NSString *)placeholde;
- (XLFormRowDescriptor *) newTextViewWithTag:(NSString *)tag Title:(NSString *)title Placeholder:(NSString *)placeHolder;


#pragma mark -selector
/**
 *@param options is a string array.
 *@return return a push selector
 *@note  the param options must be a string array.
 **/
- (XLFormRowDescriptor *) newSelectorPushWithTag:(NSString *)tag Title:(NSString *)title Options:(NSArray *)options defaultIndex:(NSUInteger)index;

/**
 *@param options is a string array.
 *@note this method only for ipad, if not return nil.
 **/
- (XLFormRowDescriptor *) newSelectorPopoverWithTag:(NSString *)tag Title:(NSString *)title Options:(NSArray *)options defaultIndex:(NSUInteger)index;
/**
 *@param options is a string array.
 *@return return a ActionSheet selector
 *@note  the param options must be a string array.
 **/
- (XLFormRowDescriptor *) newSelectorActionSheetWithTag:(NSString *)tag Title:(NSString *)title Options:(NSArray *)options defaultIndex:(NSUInteger)index;

/**
 *@param options is a string array.
 *@return return a AlertView selector
 *@note  the param options must be a string array.
 **/
- (XLFormRowDescriptor *) newSelectorAlertViewWithTag:(NSString *)tag Title:(NSString *)title Options:(NSArray *)options defaultIndex:(NSUInteger)index;

//extern NSString *const XLFormRowDescriptorTypeSelectorLeftRight;




- (XLFormRowDescriptor *) newSelectorPickerViewWithTag:(NSString *)tag Title:(NSString *)title Options:(NSArray *)options defaultIndex:(NSUInteger)index;

- (XLFormRowDescriptor *) newSelectorPickerViewInlineWithTag:(NSString *)tag Title:(NSString *)title Options:(NSArray *)options defaultIndex:(NSUInteger)index;

- (XLFormRowDescriptor *) newMultipleSelectorWithTag:(NSString *)tag Title:(NSString *)title Options:(NSArray *)options defaultValues:(NSArray *)vals;

/**
 *@note this method only for ipad, if not return nil.
 **/
- (XLFormRowDescriptor *) newMultipleSelectorPopoverWithTag:(NSString *)tag Title:(NSString *)title Options:(NSArray *)options defaultValues:(NSArray *)vals;


- (XLFormRowDescriptor *) newSelectorLeftRightWithTag:(NSString *)tag Title:(NSString *)title Options:(NSArray *)options;

- (XLFormRowDescriptor *) newSelectorSegmentedControlWithTag:(NSString *)tag Title:(NSString *)title Options:(NSArray *)options defaultValue:(NSString *)value;

#pragma mark -date

/**
 *@param date if date is nil, the date is current date.
 **/
- (XLFormRowDescriptor *) newDateInlineWithTag:(NSString *)tag Title:(NSString *)title defaultValue:(NSDate *)date;

- (XLFormRowDescriptor *) newDateTimeInlineWithTag:(NSString *)tag Title:(NSString *)title defaultValue:(NSDate *)date;

- (XLFormRowDescriptor *) newTimeInlineWithTag:(NSString *)tag Title:(NSString *)title defaultValue:(NSDate *)date;
- (XLFormRowDescriptor *) newDateWithTag:(NSString *)tag Title:(NSString *)title defaultValue:(NSDate *)date;

- (XLFormRowDescriptor *)newDateTimeWithTag:(NSString *)tag Title:(NSString *)title defaultValue:(NSDate *)date;
- (XLFormRowDescriptor *)newTimeWithTag:(NSString *)tag Title:(NSString *)title defaultValue:(NSDate *)date;

- (XLFormRowDescriptor *)newDatePickerWithTag:(NSString *)tag Title:(NSString *)title defaultValue:(NSDate *)date;

#pragma mark other

- (XLFormRowDescriptor *) newPickerWithTag:(NSString *)tag Options:(NSArray *)options defaultValue:(NSString *)value;

- (XLFormRowDescriptor *) newSliderWithTag:(NSString *)tag Title:(NSString *)title defaultValue:(NSUInteger)val Step:(NSUInteger)step Max:(NSUInteger)max Min:(NSUInteger)min;

- (XLFormRowDescriptor *) newBooleanCheckWithTag:(NSString *)tag Title:(NSString *)title defaultValue:(BOOL)vaule;

- (XLFormRowDescriptor *) newBooleanSwitchWithTag:(NSString *)tag Title:(NSString *)title defaultValue:(BOOL)vaule;

- (XLFormRowDescriptor *) newButtonWithTag:(NSString *)tag Title:(NSString *)title;

- (XLFormRowDescriptor *) newInfoWithTag:(NSString *)tag Title:(NSString *)title Value:(NSString *)value;

- (XLFormRowDescriptor *) newStepCounterWithTag:(NSString *)tag Title:(NSString *)title;

@end
