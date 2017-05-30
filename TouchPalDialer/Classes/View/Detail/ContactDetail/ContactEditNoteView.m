//
//  ContactEditNoteView.m
//  TouchPalDialer
//
//  Created by Leon Lu on 13-5-26.
//
//

#import "ContactEditNoteView.h"
#import "TPDialerResourceManager.h"
#import "UITableView+TP.h"
#import "UIView+WithSkin.h"
#import "SkinHandler.h"
#import "ContactNoteTextView.h"
#import "PersonDBA.h"
#import "SyncContactInApp.h"
#import "HeaderBar.h"
#import "TPHeaderButton.h"
#import "FunctionUtility.h"

#define TABLE_CELL_HEIGHT 50.0

#define NOTE_VIEW_MAX_HEIGHT 140.0
#define NOTE_CELL_BASE_HEIGHT 0.0
#define NOTE_CELL_BASE_HEIGHT_NOTE_EDITING 38.0
#define NOTE_VIEW_HEIGHT_INSET 10.0

@interface ContactEditNoteView ()
@property (nonatomic, retain) ContactNoteTextView *noteView;
@end

@implementation ContactEditNoteView
@synthesize personId = personId_;
@synthesize note = note_;
@synthesize noteView = noteView_;

- (id)initWithPersonId:(NSInteger)personId note:(NSString *)note
{
    self = [super initWithFrame:CGRectMake(0, 0, TPScreenWidth(), TPHeightFit(460))];
    if (self) {
        personId_ = personId;
        note_ = note == nil ? @"" : [note copy];

        self.backgroundColor = [[TPDialerResourceManager sharedManager] getUIColorFromNumberString:@"tp_color_grey_50"];
        
        // HeaderBar
        UIView *headBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TPScreenWidth(), 45+TPHeaderBarHeightDiff())] ;
        headBar.backgroundColor = [FunctionUtility getBgColorOfLongPressView];
        
        // Label
        UILabel* headerTitle = [[UILabel alloc] initWithFrame:CGRectMake((TPScreenWidth()-198)/2, TPHeaderBarHeightDiff(), 198, 45)];
        headerTitle.textColor = [UIColor whiteColor];
        headerTitle.font = [UIFont systemFontOfSize:FONT_SIZE_3];
        headerTitle.textAlignment = NSTextAlignmentCenter;
        headerTitle.backgroundColor = [UIColor clearColor];
        headerTitle.text = NSLocalizedString(@"Edit note", @"");
        [headBar addSubview:headerTitle];
        // BackButton
        UIButton *cancel_but = [[UIButton alloc]initWithFrame:CGRectMake(0, TPHeaderBarHeightDiff(), 50, 45)];
        [cancel_but setBackgroundImage:[TPDialerResourceManager getImage:@"white_navigation_back_icon@2x.png"] forState:UIControlStateNormal];
        [cancel_but addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
        [headBar addSubview:cancel_but];
        // saveButton
        TPHeaderButton *tmpEdit = [[TPHeaderButton alloc] initRightBtnWithFrame:CGRectMake(TPScreenWidth() - 50, 0, 50, 45)];
        [tmpEdit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [tmpEdit addTarget:self action:@selector(saveNote) forControlEvents:UIControlEventTouchUpInside];
        [tmpEdit setTitle:NSLocalizedString(@"Save", @"") forState:UIControlStateNormal];
        tmpEdit.titleLabel.font = [UIFont systemFontOfSize:FONT_SIZE_3];
        [headBar addSubview:tmpEdit];
        
        [self addSubview:headBar];
        
        self.noteView = [[ContactNoteTextView alloc] init];
        self.noteView.text = note_;
        self.noteView.frame = [self calculateNoteViewRectInNonNoteEditingMode];
        self.noteView.delegate = self;
        [self addSubview:noteView_];
        [self.noteView becomeFirstResponder];
        
        
        UIImageView *iconView = [[UIImageView alloc] initWithFrame: CGRectMake(2880, TPHeaderBarHeight(), 30, 50)];
        iconView.image = [[TPDialerResourceManager sharedManager] getImageByName:@"detail_icon_note@2x.png"];
        [self addSubview:iconView];
    }
    return self;
}

- (void)gotoBack
{
    [self removeFromSuperview]; // this will cause deallocation of self.
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.noteView.frame = [self calculateNoteViewRectInNoteEditingMode];
}

- (void)saveNote
{
    NSString *noteToSave = [NSString stringWithString:noteView_.text];
    noteToSave = [noteToSave stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSInteger personId = personId_;
    BOOL equals = [noteToSave isEqualToString:self.note];
    
    [self removeFromSuperview]; // this will cause deallocation of self.
    
    if (!equals) {
        // this will indirectly raise an event to refresh the whole page
        [PersonDBA saveNoteInfo:noteToSave ByRecordId:personId_];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
            [SyncContactInApp editPerson:[PersonDBA getConatctInfoByRecordID:personId]];
        });
    }
}


- (CGRect)calculateNoteViewRectInNoteEditingMode
{
    CGRect textViewFrame = noteView_.frame;
    textViewFrame.size.height = noteView_.contentSize.height + NOTE_VIEW_HEIGHT_INSET > NOTE_VIEW_MAX_HEIGHT ? NOTE_VIEW_MAX_HEIGHT : noteView_.contentSize.height + NOTE_VIEW_HEIGHT_INSET;
    return textViewFrame;
}

- (CGRect)calculateNoteViewRectInNonNoteEditingMode
{
    CGSize constrainedSize = CGSizeMake(260 - 16, CGFLOAT_MAX); // why -16? this is a textview other than a label
    
//    NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc]init] autorelease];
//    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
//    NSDictionary * tdic = @{NSFontAttributeName:noteView_.font, NSParagraphStyleAttributeName:paragraphStyle};
//    CGSize oneLineSize = [@" " boundingRectWithSize:constrainedSize
//                                        options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
//                                     attributes:tdic
//                                        context:nil].size;
    
    CGSize oneLineSize = [@" " sizeWithFont:noteView_.font
                          constrainedToSize:constrainedSize
                              lineBreakMode:NSLineBreakByWordWrapping];
//    tdic = @{NSFontAttributeName:noteView_.font, NSParagraphStyleAttributeName:paragraphStyle};
//    CGSize noteSize = [noteView_.text boundingRectWithSize:constrainedSize
//                                     options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
//                                  attributes:tdic
//                                     context:nil].size;
    
    
    CGSize noteSize = [noteView_.text sizeWithFont:noteView_.font
                                 constrainedToSize:constrainedSize
                                     lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat height = noteSize.height == 0.0 ? oneLineSize.height : noteSize.height;
    height += 26;
    
    return CGRectMake(10, CELL_HEIGHT + TPHeaderBarHeightDiff(), TPScreenWidth() - 20, height > NOTE_VIEW_MAX_HEIGHT ? NOTE_VIEW_MAX_HEIGHT : height);
}

- (void)dealloc
{
    [SkinHandler removeRecursively:self];
}

@end
