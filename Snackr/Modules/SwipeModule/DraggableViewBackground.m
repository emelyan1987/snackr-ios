//
//  DraggableViewBackground.m
//  testing swiping
//
//  Created by Richard Kim on 8/23/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//

#import "DraggableViewBackground.h"
#import "AppDelegate.h"
#import "ConfigManager.h"
#import "Dish.h"
#import "BackEndManager.h"
#import "AFNetworking.h"
#import "AlertManager.h"
#import "NSMutableArray+Queue.h"


@implementation DraggableViewBackground{
    NSInteger cardsLoadedIndex; //%%% the index of the card you have loaded into the loadedCards array last
    NSMutableArray *loadedCards; //%%% the array of card loaded (change max_buffer_size to increase or decrease the number of cards this holds)
    
    UIButton* menuButton;
    UIButton* messageButton;
    UIButton* checkButton;
    UIButton* xButton;
    
    int currentPage;
    
}
//this makes it so only two cards are loaded at a time to
//avoid performance and memory costs
static const int MAX_BUFFER_SIZE = 2; //%%% max number of cards loaded at any given time, must be greater than 1
#define LIMIT_COUNT 5

@synthesize exampleCardLabels; //%%% all the labels I'm using as example data at the moment
@synthesize allCards;//%%% all the cards

- (id)initWithFrame:(CGRect)frame viewController:(UIViewController*)controller
{
    self = [super initWithFrame:frame];
    self.controller = controller;
    if (self) {
        [super layoutSubviews];
        [self setupView];
        exampleCardLabels = [[NSArray alloc]initWithObjects:@"first",@"second",@"third",@"fourth",@"last", nil]; //%%% placeholder for card-specific information
        loadedCards = [[NSMutableArray alloc] init];
        allCards = [[NSMutableArray alloc] init];
        cardsLoadedIndex = 0;
        
        currentPage = 0;
        self.frontCardView = [self getFrontCardView];
        self.backCardView = [self getBackCardView];
        
        [self addSubview:self.backCardView];
        
        [self insertSubview:self.frontCardView aboveSubview:self.backCardView];
//        [self loadCards];
        
        [[AppDelegate sharedInstance] loadDish:YES successHandler:^(NSMutableArray *array) {
            [self.frontCardView bindModel:[[AppDelegate sharedInstance].dishes dequeue]];
            [self.backCardView bindModel:[[AppDelegate sharedInstance].dishes dequeue]];
        } failureHandler:^(NSString *errorMsg) {
            [self.frontCardView showErrorMessage:errorMsg];
            [self.backCardView showErrorMessage:errorMsg];
            
            if([AppDelegate sharedInstance].feedLoadingStatus == 1)
            {
                [AlertManager showErrorMessage:errorMsg];
                [AppDelegate sharedInstance].feedLoadingStatus = 2;
            }
        }];
    }
    return self;
}

// sets up the extra buttons on the screen
-(void)setupView
{
    self.backgroundColor = [UIColor clearColor];
}

// creates a card and returns it.  This should be customized to fit your needs.
// use "index" to indicate where the information should be pulled.  If this doesn't apply to you, feel free
// to get rid of it (eg: if you are building cards from data from the internet)
- (DraggableView *) getFrontCardView {
    
    NSArray *nib_views;
    
    NSInteger where = ((AppDelegate*)[UIApplication sharedApplication].delegate).isWhatStoryboard;
    
    if (where == 1) {
        nib_views = [[NSBundle mainBundle] loadNibNamed:@"DraggableView_5" owner:self options:nil];
    } else if (where == 2){
        nib_views = [[NSBundle mainBundle] loadNibNamed:@"DraggableView_6" owner:self options:nil];
    } else if (where == 3){
        nib_views = [[NSBundle mainBundle] loadNibNamed:@"DraggableView_6plus" owner:self options:nil];
    } else if (where == 4){
        nib_views = [[NSBundle mainBundle] loadNibNamed:@"DraggableView_4s" owner:self options:nil];
    }
    
    DraggableView *draggableView = [nib_views objectAtIndex:0];
    
    CGFloat CARDWidth = draggableView.frame.size.width;
    CGFloat CARDHeight = draggableView.frame.size.height;
    
    draggableView.frame = CGRectMake(0.0f, 0.0f, CARDWidth, CARDHeight);
    draggableView.clipsToBounds = YES;
    
    draggableView.messageView.layer.cornerRadius = 10.0f;
    draggableView.messageView.backgroundColor = [UIColor colorWithRed:(226.0f/255.0f) green:(226.0f/255.0f) blue:(226.0f/255.0f) alpha:1.0f];
    draggableView.upView.layer.cornerRadius = 10.0f;
    draggableView.upView.layer.borderWidth = 1.0f;
    draggableView.upView.layer.borderColor = [UIColor colorWithRed:(151.0f/255.0f) green:(151.0f/255.0f) blue:(151.0f/255.0f) alpha:0.5f].CGColor;
    
    draggableView.food_photo.layer.cornerRadius = 10.0f;
    draggableView.food_photo.clipsToBounds = YES;
    
    [draggableView initView];
    
    
    draggableView.delegate = self;
    draggableView.controller = self.controller;
    return draggableView;
}

- (DraggableView *) getBackCardView{
    
    NSArray *nib_views;
    
    NSInteger where = ((AppDelegate*)[UIApplication sharedApplication].delegate).isWhatStoryboard;
    CGFloat y;
    
    if (where == 1) {
        nib_views = [[NSBundle mainBundle] loadNibNamed:@"DraggableView_5" owner:self options:nil];
        y = 5.0f;
    } else if (where == 2){
        nib_views = [[NSBundle mainBundle] loadNibNamed:@"DraggableView_6" owner:self options:nil];
        y = 6.0f;
    } else if (where == 3){
        nib_views = [[NSBundle mainBundle] loadNibNamed:@"DraggableView_6plus" owner:self options:nil];
        y = 7.0f;
    } else if (where == 4){
        nib_views = [[NSBundle mainBundle] loadNibNamed:@"DraggableView_4s" owner:self options:nil];
        y = 4.0f;
    }
    
    DraggableView *draggableView = [nib_views objectAtIndex:0];
    
    CGFloat CARDWidth = draggableView.frame.size.width;
    CGFloat CARDHeight = draggableView.frame.size.height;

    draggableView.frame = CGRectMake(0.0f, -y, CARDWidth, CARDHeight);
    
    
    draggableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, (290/304.f), 1.0f);
    
    draggableView.clipsToBounds = YES;
    
    draggableView.messageView.layer.cornerRadius = 10.0f;
    draggableView.messageView.backgroundColor = [UIColor colorWithRed:(181.0f/255.0f) green:(181.0f/255.0f) blue:(181.0f/255.0f) alpha:1.0f];
    
    draggableView.upView.layer.cornerRadius = 10.0f;
    draggableView.upView.layer.borderWidth = 1.0f;
    draggableView.upView.layer.borderColor = [UIColor colorWithRed:(151.0f/255.0f) green:(151.0f/255.0f) blue:(151.0f/255.0f) alpha:0.5f].CGColor;
    
    draggableView.food_photo.layer.cornerRadius = 10.0f;
    draggableView.food_photo.clipsToBounds = YES;
    
    [draggableView initView];
    
    
    draggableView.delegate = self;
    draggableView.controller = self.controller;
    
    [draggableView hideSwipeMark];
    return draggableView;
}


-(DraggableView *)createDraggableViewWithDataAtIndex:(NSInteger)index
{
    NSArray *nib_views;
    
    NSInteger where = ((AppDelegate*)[UIApplication sharedApplication].delegate).isWhatStoryboard;
    
    if (where == 1) {
         nib_views = [[NSBundle mainBundle] loadNibNamed:@"DraggableView_5" owner:self options:nil];
    } else if (where == 2){
        nib_views = [[NSBundle mainBundle] loadNibNamed:@"DraggableView_6" owner:self options:nil];
    } else if (where == 3){
        nib_views = [[NSBundle mainBundle] loadNibNamed:@"DraggableView_6plus" owner:self options:nil];
    } else if (where == 4){
        nib_views = [[NSBundle mainBundle] loadNibNamed:@"DraggableView_4s" owner:self options:nil];
    }
    
    DraggableView *draggableView = [nib_views objectAtIndex:0];
    
    CGFloat CARDWidth = draggableView.frame.size.width;
    CGFloat CARDHeight = draggableView.frame.size.height;
    
    if (index == 0) {
        draggableView.frame = CGRectMake(0.0f, 0.0f, CARDWidth, CARDHeight);
    } else{
        draggableView.frame = CGRectMake(0.0f, -5.0f, CARDWidth, CARDHeight);
        draggableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, (290/304.f), 1.0f);
    }
    
    draggableView.clipsToBounds = YES;
    
    draggableView.upView.layer.cornerRadius = 10.0f;
    draggableView.upView.layer.borderWidth = 1.0f;
    draggableView.upView.layer.borderColor = [UIColor colorWithRed:(151.0f/255.0f) green:(151.0f/255.0f) blue:(151.0f/255.0f) alpha:0.5f].CGColor;
    
    draggableView.food_photo.layer.cornerRadius = 10.0f;
    draggableView.food_photo.clipsToBounds = YES;
    
    [draggableView initView];

    
    draggableView.delegate = self;
    return draggableView;
}

// loads all the cards and puts the first x in the "loaded cards" array
-(void)loadCards
{
    if([exampleCardLabels count] > 0) {
        NSInteger numLoadedCardsCap =(([exampleCardLabels count] > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:[exampleCardLabels count]);
        // if the buffer size is greater than the data size, there will be an array error, so this makes sure that doesn't happen
        
        // loops through the exampleCardsLabels array to create a card for each label.  This should be customized by removing "exampleCardLabels" with your own array of data
        for (int i = 0; i<[exampleCardLabels count]; i++) {
            DraggableView* newCard = [self createDraggableViewWithDataAtIndex:i];
            
            NSInteger imageName = i % 4;
            newCard.food_photo.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld%@", imageName, @".png"]];
            
            [allCards addObject:newCard];
            
            if (i<numLoadedCardsCap) {
                //%%% adds a small number of cards to be loaded
                [loadedCards addObject:newCard];
            }
        }
        
        // displays the small number of loaded cards dictated by MAX_BUFFER_SIZE so that not all the cards
        // are showing at once and clogging a ton of data
        for (int i = 0; i<[loadedCards count]; i++) {
            if (i>0) {
                [self insertSubview:[loadedCards objectAtIndex:i] belowSubview:[loadedCards objectAtIndex:i-1]];
            } else {
                [self addSubview:[loadedCards objectAtIndex:i]];
            }
            cardsLoadedIndex++; //%%% we loaded a card into loaded cards, so we have to increment
        }
    }
}



// action called when the card goes to the left.
-(void)cardSwipedLeft:(UIView *)card;
{
    self.backCardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f);
    
    self.backCardView.frame = CGRectMake(0.0f, 0.0f, self.backCardView.frame.size.width, self.backCardView.frame.size.height);
    
    self.backCardView.messageView.backgroundColor = [UIColor colorWithRed:(226.0f/255.0f) green:(226.0f/255.0f) blue:(226.0f/255.0f) alpha:1.0f];
    
    self.frontCardView = self.backCardView;
    
    self.backCardView = [self getBackCardView];
    
    self.backCardView.alpha = 0.0f;
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.backCardView.alpha = 1.0f;
                         [self insertSubview:self.backCardView belowSubview:self.frontCardView];
                     }completion:nil];

    
    //[self.frontCardView bindModel:[dishes dequeue]];
    [self.backCardView bindModel:[[AppDelegate sharedInstance].dishes dequeue]];
    if([AppDelegate sharedInstance].dishes.count < LIMIT_COUNT)
        [[AppDelegate sharedInstance] loadDish:NO successHandler:nil failureHandler:^(NSString *errorMsg) {
            [self.backCardView showErrorMessage:errorMsg];
            
            if([AppDelegate sharedInstance].feedLoadingStatus == 1)
            {
                [AlertManager showErrorMessage:errorMsg];
                [AppDelegate sharedInstance].feedLoadingStatus = 2;
            }

        }];
    
//    [loadedCards removeObjectAtIndex:0]; // card was swiped, so it's no longer a "loaded card"
    
//    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
//        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
//        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
//        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
//    }
}


// action called when the card goes to the right.
-(void)cardSwipedRight:(UIView *)card
{
    
    self.backCardView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f);
    
    self.backCardView.frame = CGRectMake(0.0f, 0.0f, self.backCardView.frame.size.width, self.backCardView.frame.size.height);
    
    self.backCardView.messageView.backgroundColor = [UIColor colorWithRed:(226.0f/255.0f) green:(226.0f/255.0f) blue:(226.0f/255.0f) alpha:1.0f];
    
    self.frontCardView = self.backCardView;
    
    self.backCardView = [self getBackCardView];
    
    self.backCardView.alpha = 0.0f;
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.backCardView.alpha = 1.0f;
                         [self insertSubview:self.backCardView belowSubview:self.frontCardView];
                     }completion:nil];
    
    
    
    
    
    //[self.frontCardView bindModel:[dishes dequeue]];
    [self.backCardView bindModel:[[AppDelegate sharedInstance].dishes dequeue]];
    NSLog([NSString stringWithFormat:@"Current Dishes count = %d", [AppDelegate sharedInstance].dishes.count]);
    if([AppDelegate sharedInstance].dishes.count < LIMIT_COUNT && ![[AppDelegate sharedInstance] isLoadingPhoto])
        [[AppDelegate sharedInstance] loadDish:NO successHandler:nil failureHandler:^(NSString *errorMsg) {
            [self.backCardView showErrorMessage:errorMsg];
            
            if([AppDelegate sharedInstance].feedLoadingStatus == 1)
            {
                [AlertManager showErrorMessage:errorMsg];
                [AppDelegate sharedInstance].feedLoadingStatus = 2;
            }
        }];

    //do whatever you want with the card that was swiped
    // DraggableView *c = (DraggableView *)card;
    
//    [loadedCards removeObjectAtIndex:0]; // card was swiped, so it's no longer a "loaded card"
//    
//    if (cardsLoadedIndex < [allCards count]) { // if we haven't reached the end of all cards, put another into the loaded cards
//        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
//        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
//        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
//    }

}

// when you hit the right button, this is called and substitutes the swipe
-(void)swipeRight
{
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeRight;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView rightClickAction];
}

// when you hit the left button, this is called and substitutes the swipe
-(void)swipeLeft
{
    DraggableView *dragView = [loadedCards firstObject];
    dragView.overlayView.mode = GGOverlayViewModeLeft;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView leftClickAction];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
