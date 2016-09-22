//
//  EditView.m
//  MarkLite
//
//  Created by zhubch on 15-3-27.
//  Copyright (c) 2015年 zhubch. All rights reserved.
//

#import "EditView.h"
#import "Configure.h"
#import "MarkdownSyntaxGenerator.h"
#import "ZHUtils.h"

@interface EditView ()

@property(nonatomic, strong) MarkdownSyntaxGenerator *markdownSyntaxGenerator;
@property(atomic,assign) BOOL updating;
@end

@implementation EditView
{
    dispatch_queue_t updateQueue;
    UILabel *placeholderLable;
}

- (id)initWithCoder:(NSCoder *) coder {
    NSLog(@"editview");

    self = [super initWithCoder:coder];

    if (self == nil) {
        return nil;
    }

    placeholderLable = [[UILabel alloc]initWithFrame:CGRectMake(5, 8, 100, 20)];
    placeholderLable.font = [UIFont systemFontOfSize:14];
    placeholderLable.text = @"StartEdit";
    placeholderLable.textColor = [UIColor lightGrayColor];
    [self addSubview:placeholderLable];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(updateSyntax) name:UITextViewTextDidChangeNotification object:nil];
    NSLog(@"editview");

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (MarkdownSyntaxGenerator *)markdownSyntaxGenerator {
    if (_markdownSyntaxGenerator == nil) {
        _markdownSyntaxGenerator = [[MarkdownSyntaxGenerator alloc] init];
    }
    return _markdownSyntaxGenerator;
}

- (void)updateSyntax {
    placeholderLable.hidden = self.text.length != 0;

    if (self.markedTextRange) { //中文选字的时候别刷新
        return;
    }
    NSArray *models = [self.markdownSyntaxGenerator syntaxModelsForText:self.text];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    
    UIFont *font = [UIFont fontWithName:[Configure sharedConfigure].fontName size:15];
    
    [attributedString addAttributes:@{
                                      NSFontAttributeName : font ? font : [UIFont systemFontOfSize:15],
                                      NSForegroundColorAttributeName : [UIColor colorWithRGBString:@"0f2f2f"]
                                      } range:NSMakeRange(0, attributedString.length)];
    for (MarkdownSyntaxModel *model in models) {
        [attributedString addAttributes:AttributesFromMarkdownSyntaxType(model.type) range:model.range];
    }
    
    [self updateAttributedText:attributedString];
}

- (void)updateAttributedText:(NSAttributedString *) attributedString {

    self.scrollEnabled = NO;
    NSRange selectedRange = self.selectedRange;
    self.attributedText = attributedString;
    self.selectedRange = selectedRange;
    self.scrollEnabled = YES;
}

@end
