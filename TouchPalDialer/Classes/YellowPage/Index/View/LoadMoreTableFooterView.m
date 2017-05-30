//
//  LoadMoreTableFooterView.h
//  TableViewPull
//
//  Created by Ye Dingding on 10-12-24.
//  Copyright 2010 Intridea, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


#import "LoadMoreTableFooterView.h"
#import "ImageUtils.h"
#import "IndexConstant.h"

#define TEXT_COLOR	 [UIColor colorWithRed:177.0/255.0 green:177.0/255.0 blue:177.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f


@interface LoadMoreTableFooterView (Private)
- (void)setState:(LoadMoreState)aState;
@end


@implementation LoadMoreTableFooterView

@synthesize delegate = _delegate;
@synthesize scrView;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        		self.backgroundColor = [ImageUtils colorFromHexString:SEPARATOR_BG_COLOR andDefaultColor:nil];

		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 20.0f, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont systemFontOfSize:15.0f];
		label.textColor = TEXT_COLOR;
		label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label];
		_statusLabel=label;

		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		view.frame = CGRectMake((frame.size.width - 10) / 2, 20.0f, 20.0f, 20.0f);
		[self addSubview:view];
		_activityView = view;
        self.hidden = NO;

		[self setState:LoadMoreNormal];
    }

    return self;
}


#pragma mark -
#pragma mark Setters

- (void)setState:(LoadMoreState)aState{
	switch (aState) {
		case LoadMoreNormal:
            _statusLabel.hidden = NO;
            [_activityView stopAnimating];
            _statusLabel.text = NSLocalizedString(@"上拉或点击加载更多", @"上拉或点击加载更多");
            break;
		case LoadMoreLoading:
        case LoadMorePulling:
            _statusLabel.hidden = YES;
			[_activityView startAnimating];
			break;
        case LoadFinished:
            _statusLabel.hidden = NO;
            [_activityView stopAnimating];
            _statusLabel.text = NSLocalizedString(@"没有更多数据", @"没有更多数据");
        case LoadFailed:
            _statusLabel.hidden = NO;
            [_activityView stopAnimating];
            _statusLabel.text = NSLocalizedString(@"加载失败，点击重新加载", @"加载失败，点击重新加载");
		default:
			break;
	}

	_state = aState;
}

#pragma doclick
- (void) doClick
{
    cootek_log(@"");
    if (_state != LoadMoreLoading) {
        if ([_delegate respondsToSelector:@selector(loadMoreTableFooterDidTriggerRefresh:)]) {
            [_delegate loadMoreTableFooterDidTriggerRefresh:self];
        }
        [self setState:LoadMoreLoading];
    }

}

#pragma mark -
#pragma mark ScrollView Methods

- (void)loadMoreScrollViewDidScroll:(UIScrollView *)scrollView {
	if (_state == LoadMoreLoading) {
		scrollView.contentInset = UIEdgeInsetsMake(scrollView.contentInset.top, scrollView.contentInset.left, 60.0f, scrollView.contentInset.right);
    }else if (_state == LoadFailed) {
        scrollView.contentInset = UIEdgeInsetsMake(scrollView.contentInset.top, scrollView.contentInset.left, 60.0f, scrollView.contentInset.right);
	} else if (scrollView.isDragging) {

		BOOL _loading = NO;
		if ([_delegate respondsToSelector:@selector(loadMoreTableFooterDataSourceIsLoading:)]) {
			_loading = [_delegate loadMoreTableFooterDataSourceIsLoading:self];
		}

		if (_state == LoadMoreNormal && scrollView.contentOffset.y > 0 && scrollView.contentOffset.y < (scrollView.contentSize.height - scrollView.frame.size.height + LOAD_MORE_OFFSET) && scrollView.contentOffset.y > (scrollView.contentSize.height + scrollView.frame.size.height) && !_loading) {
			self.frame = CGRectMake(0, scrollView.contentSize.height, self.frame.size.width, self.frame.size.height);
			self.hidden = NO;
		} else if (_state == LoadMoreNormal && scrollView.contentOffset.y > 0 && scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height + LOAD_MORE_OFFSET) && !_loading) {
			[self setState:LoadMorePulling];
		} else if (_state == LoadMorePulling && scrollView.contentOffset.y > 0 && scrollView.contentOffset.y < (scrollView.contentSize.height - scrollView.frame.size.height + LOAD_MORE_OFFSET) && scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height) && !_loading) {
			[self setState:LoadMoreNormal];
		}

		if (scrollView.contentInset.bottom != 0) {
			scrollView.contentInset = UIEdgeInsetsMake(scrollView.contentInset.top, scrollView.contentInset.left, 0.0f, scrollView.contentInset.right);
		}
        if (_state == LoadMorePulling) {
            if (scrView) {
                [self setState:LoadMoreLoading];
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.2];
                scrView.contentInset = UIEdgeInsetsMake(scrView.contentInset.top, scrView.contentInset.left, 60.0f, scrView.contentInset.right);
                [UIView commitAnimations];
                [self loadMoreScrollViewDidEndDragging:scrView];
            }
        }
	}
}

- (void)loadMoreScrollViewDidEndDragging:(UIScrollView *)scrollView {

	BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(loadMoreTableFooterDataSourceIsLoading:)]) {
		_loading = [_delegate loadMoreTableFooterDataSourceIsLoading:self];
	}

    CGFloat offsetY = scrollView.contentOffset.y;
	if (offsetY > 0 && offsetY > (scrollView.contentSize.height - scrollView.frame.size.height + LOAD_MORE_OFFSET) && !_loading) {
		if ([_delegate respondsToSelector:@selector(loadMoreTableFooterDidTriggerRefresh:)]) {
			[_delegate loadMoreTableFooterDidTriggerRefresh:self];
		}

		[self setState:LoadMoreLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		scrollView.contentInset = UIEdgeInsetsMake(scrollView.contentInset.top, scrollView.contentInset.left, 60.0f, scrollView.contentInset.right);
		[UIView commitAnimations];
	} else if(_loading){
        [self setState:LoadMoreLoading];
        scrollView.contentInset = UIEdgeInsetsMake(scrollView.contentInset.top, scrollView.contentInset.left, 60.0f, scrollView.contentInset.right);
    }
}

- (void)loadMoreScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[scrollView setContentInset:UIEdgeInsetsMake(scrollView.contentInset.top, scrollView.contentInset.left, 0.0f, scrollView.contentInset.right)];
	[UIView commitAnimations];
	[self setState:LoadMoreNormal];
	self.hidden = NO;
}

- (void)loadMoreScrollViewDataSourceNoMore:(UIScrollView *)scrollView {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    scrollView.contentInset = UIEdgeInsetsMake(scrollView.contentInset.top, scrollView.contentInset.left, 60.0f, scrollView.contentInset.right);
    [UIView commitAnimations];

    [self setState:LoadFinished];
    self.hidden = NO;
}

- (void)loadMoreScrollViewDataSourceFailed:(UIScrollView *)scrollView {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    scrollView.contentInset = UIEdgeInsetsMake(scrollView.contentInset.top, scrollView.contentInset.left, 60.0f, scrollView.contentInset.right);
    [UIView commitAnimations];

    [self setState:LoadFailed];
    [self loadMoreScrollViewDataSourceDidFinishedLoading:scrollView];
    self.hidden = NO;
}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
    _delegate=nil;
    _activityView = nil;
    _statusLabel = nil;
    [super dealloc];
}
@end
