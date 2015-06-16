//
//  RTTextInputBar.m
//  IM
//
//  Created by 郭志伟 on 15/6/15.
//  Copyright (c) 2015年 rooten. All rights reserved.
//

#import "RTTextInputBar.h"

@interface RTTextInputBar()

@property (nonatomic, strong) UILabel *charCountLabel;

@property (nonatomic, strong) NSLayoutConstraint *leftButtonWC;
@property (nonatomic, strong) NSLayoutConstraint *leftButtonHC;
@property (nonatomic, strong) NSLayoutConstraint *leftMarginWC;
@property (nonatomic, strong) NSLayoutConstraint *bottomMarginWC;
@property (nonatomic, strong) NSLayoutConstraint *rightButtonWC;
@property (nonatomic, strong) NSLayoutConstraint *rightMarginWC;
@property (nonatomic, strong) NSArray *charCountLabelVCs;
@property (nonatomic, strong) NSLayoutConstraint *textViewHC;

@end

@implementation RTTextInputBar


+ (instancetype)showInView:(UIView *)view {
    CGFloat screenH = CGRectGetHeight([UIScreen mainScreen].bounds);
    CGFloat screenW = CGRectGetWidth([UIScreen mainScreen].bounds);
    RTTextInputBar *textBar = [[RTTextInputBar alloc] initWithFrame:CGRectMake(0, screenH, screenW, 44)];
    [view addSubview:textBar];
    return textBar;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self rt_commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self rt_commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        [self rt_commonInit];
    }
    return self;
}

- (void)rt_commonInit {
    
    self.charCountLabelNormalColor = [UIColor lightGrayColor];
    self.charCountLabelWarningColor = [UIColor redColor];
    
    [self addSubview:self.textView];
    [self addSubview:self.leftButton];
    [self addSubview:self.rightButton];
    [self addSubview:self.charCountLabel];
    self.contentInset = UIEdgeInsetsMake(5.0, 8.0, 5.0, 8.0);
    
    [self rt_setupConstraints];
    [self rt_updateConstraintConstants];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rt_didChangeTextViewText:) name:UITextViewTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rt_didChangeTextViewContentSize:) name:RTTextViewContentSizeDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RTTextViewContentSizeDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
}

- (void)rt_setupConstraints {
    [self.rightButton sizeToFit];
    
    UIImage *leftButtonImg = [self.leftButton imageForState:UIControlStateNormal];
    CGFloat leftVerMargin = (self.intrinsicContentSize.height - leftButtonImg.size.height) / 2.0;
    CGFloat rightVerMargin = (self.intrinsicContentSize.height - CGRectGetHeight(self.rightButton.frame) / 2.0);
    
    NSDictionary *views = @{@"textView": self.textView,
                            @"leftButton": self.leftButton,
                            @"rightButton": self.rightButton,
                            @"charCountLabel": self.charCountLabel
                            };
    NSDictionary *metrics = @{@"top": @(self.contentInset.top),
                              @"bottom": @(self.contentInset.bottom),
                              @"left": @(self.contentInset.left),
                              @"right": @(self.contentInset.right),
                              @"leftVerMargin": @(leftVerMargin),
                              @"rightVerMargin": @(rightVerMargin),
                              @"minTextViewHeight": @(self.textView.intrinsicContentSize.height)
                              };
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(left)-[leftButton(0)]-(<=left)-[textView]-(right)-[rightButton(0)]-(right)-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[leftButton(0)]-(0@750)-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[rightButton]-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(left@250)-[charCountLabel(<=50@1000)]-(right@750)-|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(<=top)-[textView(minTextViewHeight@250)]-(bottom)-|" options:0 metrics:metrics views:views]];
    
    self.leftButtonWC = [self rt_constraintForAttribute:NSLayoutAttributeWidth firstItem:self.leftButton secondItem:nil];
    self.leftButtonHC = [self rt_constraintForAttribute:NSLayoutAttributeHeight firstItem:self.leftButton secondItem:nil];
    self.textViewHC = [self rt_constraintForAttribute:NSLayoutAttributeHeight firstItem:self.textView secondItem:nil];
    
    self.leftMarginWC = [self rt_constraintsForAttribute:NSLayoutAttributeLeading][0];
    self.bottomMarginWC = [self rt_constraintForAttribute:NSLayoutAttributeBottom firstItem:self secondItem:self.leftButton];
    
    self.rightButtonWC = [self rt_constraintForAttribute:NSLayoutAttributeWidth firstItem:self.rightButton secondItem:nil];
    self.rightMarginWC = [self rt_constraintsForAttribute:NSLayoutAttributeTrailing][0];
}

- (void)rt_updateConstraintConstants {
    CGFloat zero = 0.0;
    CGSize leftButtonSize = [self.leftButton imageForState:self.leftButton.state].size;
    
    if (leftButtonSize.width > 0) {
        self.leftButtonHC.constant = roundf(leftButtonSize.height);
        self.bottomMarginWC.constant = roundf((self.intrinsicContentSize.height - leftButtonSize.height) / 2.0);
    }
    
    self.leftButtonWC.constant = roundf(leftButtonSize.width);
    self.leftMarginWC.constant = (leftButtonSize.width > 0) ? self.contentInset.left : zero;
    
    self.rightButtonWC.constant = [self rt_appropriateRightButtonWidth];
    self.rightMarginWC.constant = [self rt_appropriateRightButtonMargin];
}

- (CGFloat)rt_appropriateRightButtonWidth
{
    NSString *title = [self.rightButton titleForState:UIControlStateNormal];
    CGSize rigthButtonSize = [title sizeWithAttributes:@{NSFontAttributeName: self.rightButton.titleLabel.font}];
    return rigthButtonSize.width+self.contentInset.right;
}

- (CGFloat)rt_appropriateRightButtonMargin
{
    return self.contentInset.right;
}


#pragma mark - Getters

- (UIButton *)leftButton {
    if (!_leftButton)
    {
        _leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _leftButton.translatesAutoresizingMaskIntoConstraints = NO;
        _leftButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    }
    return _leftButton;
}

- (UIButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _rightButton.translatesAutoresizingMaskIntoConstraints = NO;
        _rightButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        _rightButton.enabled = NO;
        [_rightButton setTitle:@"发送" forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(didPressRightButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightButton;
}

- (UITextView *)textView {
    if (!_textView)
    {
        _textView = [[RTTextView alloc] init];
        _textView.translatesAutoresizingMaskIntoConstraints = NO;
        _textView.font = [UIFont systemFontOfSize:15.0];
        _textView.maxNumberOfLines = 4;
        
        _textView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        _textView.keyboardType = UIKeyboardTypeTwitter;
        _textView.returnKeyType = UIReturnKeyDefault;
        _textView.enablesReturnKeyAutomatically = YES;
        _textView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, -1.0, 0.0, 1.0);
        _textView.textContainerInset = UIEdgeInsetsMake(8.0, 4.0, 8.0, 0.0);
        _textView.layer.cornerRadius = 5.0;
        _textView.layer.borderWidth = 0.5;
        _textView.layer.borderColor =  [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:205.0/255.0 alpha:1.0].CGColor;
    }
    return _textView;
}

- (CGFloat)minimumInputbarHeight
{
    return self.intrinsicContentSize.height;
}

- (CGFloat)appropriateHeight
{
    CGFloat height = 0.0;
    CGFloat minimumHeight = [self minimumInputbarHeight];
    
    if (self.textView.numberOfLines == 1) {
        height = minimumHeight;
    }
    else if (self.textView.numberOfLines < self.textView.maxNumberOfLines) {
        height = [self rt_inputBarHeightForLines:self.textView.numberOfLines];
    }
    else {
        height = [self rt_inputBarHeightForLines:self.textView.maxNumberOfLines];
    }
    
    if (height < minimumHeight) {
        height = minimumHeight;
    }
    
    return roundf(height);
}

- (CGFloat)rt_deltaInputbarHeight
{
    return self.textView.intrinsicContentSize.height-self.textView.font.lineHeight;
}

- (CGFloat)rt_inputBarHeightForLines:(NSUInteger)numberOfLines
{
    CGFloat height = [self rt_deltaInputbarHeight];
    
    height += roundf(self.textView.font.lineHeight*numberOfLines);
    height += self.contentInset.top+self.contentInset.bottom;
    return height;
}

- (UILabel *)charCountLabel
{
    if (!_charCountLabel) {
        _charCountLabel = [UILabel new];
        _charCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _charCountLabel.backgroundColor = [UIColor clearColor];
        _charCountLabel.textAlignment = NSTextAlignmentRight;
        _charCountLabel.font = [UIFont systemFontOfSize:11.0];
        _charCountLabel.hidden = NO;
    }
    return _charCountLabel;
}


- (void)textDidUpdate {
    CGFloat inputbarHeight = self.appropriateHeight;
    CGFloat interval = roundf(inputbarHeight - self.textViewHC.constant - self.contentInset.top-self.contentInset.bottom);
    self.rightButton.enabled = [self canPressRightButton];
    if (fabs(interval) > 0) {
        self.textViewHC.constant = inputbarHeight - self.contentInset.top - self.contentInset.bottom;
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - interval, self.frame.size.width, self.frame.size.height + interval);
        [self layoutIfNeeded];
    }
    [self.textView scrollsToTop];
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, 44.0);
}


- (BOOL)canPressRightButton
{
    NSString *text = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (text.length > 0 && ![self limitExceeded]) {
        return YES;
    }
    
    return NO;
}


+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

- (NSLayoutConstraint *)rt_constraintForAttribute:(NSLayoutAttribute)attribute firstItem:(id)first secondItem:(id)second
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstAttribute = %d AND firstItem = %@ AND secondItem = %@", attribute, first, second];
    return [[self.constraints filteredArrayUsingPredicate:predicate] firstObject];
}

- (NSArray *)rt_constraintsForAttribute:(NSLayoutAttribute)attribute
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstAttribute = %d", attribute];
    return [self.constraints filteredArrayUsingPredicate:predicate];
}

#pragma mark - Notification Events

- (void)rt_didChangeTextViewText:(NSNotification *)notification
{
    RTTextView *textView = (RTTextView *)notification.object;
    
    // Skips this it's not the expected textView.
    if (![textView isEqual:self.textView]) {
        return;
    }
    
    // Updates the char counter label
    if (self.maxCharCount > 0) {
        [self rt_updateCounter];
    }
    
    [self textDidUpdate];
}

- (void)rt_didChangeTextViewContentSize:(NSNotification *)notification
{
    // Skips this it's not the expected textView.
    if (![notification.object isEqual:self.textView]) {
        return;
    }
    
    // Animated only if the view already appeared.
    [self textDidUpdate];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGFloat keyboardH = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    [UIView animateWithDuration:0.2f animations:^{
        CGFloat srceenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
        self.frame = CGRectMake(self.frame.origin.x, srceenHeight - self.frame.size.height - keyboardH, CGRectGetWidth(self.frame) , self.frame.size.height);
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.2f animations:^{
        CGFloat screenH = CGRectGetHeight([UIScreen mainScreen].bounds);
        CGFloat screenW = CGRectGetWidth([UIScreen mainScreen].bounds);
        self.frame = CGRectMake(0, screenH, screenW, self.frame.size.height);
    }];
}

#pragma mark - Setter
- (void)setContentInset:(UIEdgeInsets)insets
{
    if (UIEdgeInsetsEqualToEdgeInsets(self.contentInset, insets)) {
        return;
    }
    
    if (UIEdgeInsetsEqualToEdgeInsets(self.contentInset, UIEdgeInsetsZero)) {
        _contentInset = insets;
        return;
    }
    
    _contentInset = insets;
    
    // Add new constraints
    [self removeConstraints:self.constraints];
    [self rt_setupConstraints];
    
    // Add constant values and refresh layout
    [self rt_updateConstraintConstants];
    [super layoutIfNeeded];
}

- (void)didPressRightButton:(id)sender {
    if ([self.rtDelegate respondsToSelector:@selector(textInputBar:didPressSendBtnWithText:)]) {
        [self.rtDelegate textInputBar:self didPressSendBtnWithText:self.textView.text];
    }
    self.textView.text = @"";
    [self.textView resignFirstResponder];
}

#pragma mark - Character Counter

- (void)rt_updateCounter
{
    NSString *text = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSString *counter = nil;
    counter = [NSString stringWithFormat:@"%lu", (unsigned long)text.length];
    self.charCountLabel.text = counter;
    self.charCountLabel.textColor = [self limitExceeded] ? self.charCountLabelWarningColor : self.charCountLabelNormalColor;
}

- (BOOL)limitExceeded
{
    NSString *text = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (self.maxCharCount > 0 && text.length > self.maxCharCount) {
        return YES;
    }
    return NO;
}


@end
