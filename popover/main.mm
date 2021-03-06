#import <AppKit/AppKit.h>
#include <QtGui>
#include <qtcontent.h>

// A NSViewController that controls a programatically created view
@interface ProgramaticViewController : NSViewController
{

}
@end

@implementation ProgramaticViewController

- (id)initWithView: (NSView *)aView
{
    [self initWithNibName:nil bundle:nil];
    self.view = aView;
    return self;
}

@end

ProgramaticViewController *createViewController(NSView *view)
{
    ProgramaticViewController *viewController =
        [[ProgramaticViewController alloc] initWithView:view];
    [viewController autorelease];
    return viewController;
}

// A Simple QQWindow subclass that shows a popover on mouse release
class ClickWindow : public QWindow
{
public:
    ClickWindow()
    {
        // Create Qt window
        PopoverCheckeredWindow *window = new PopoverCheckeredWindow();

        // Create popover
        m_popover = [[NSPopover alloc] init];
        [m_popover setContentSize:NSMakeSize(200, 200)];
        [m_popover setBehavior:NSPopoverBehaviorTransient];
        [m_popover setAnimates:YES];

        // Close popover on PopoverCheckeredWindow signal
        connect(window, &PopoverCheckeredWindow::closePopup, [=]() {
            [m_popover close];
        });

        // Assign the Qt window to the popoper via view controller
        NSView *popoverView = window->toNSView();
        [m_popover setContentViewController:createViewController(popoverView)];
    }

    ~ClickWindow()
    {
        [m_popover release];
    }

    void mousePressEvent(QMouseEvent *ev)
    {
        // Close currently open popover (if any)
        [m_popover close];
        
        // Show popover on the ClickWindow window at mouse position;
        NSView *thisView = reinterpret_cast<NSView *>(winId());
        NSRect position = CGRectMake(ev->localPos().x(), ev->localPos().y(), 1, 1);
        [m_popover showRelativeToRect:position
                               ofView:thisView
                        preferredEdge:NSMaxYEdge];
    }
    
private:
    NSPopover *m_popover;
};

int main(int argc, char **argv)
{
    QGuiApplication app(argc, argv);

    ClickWindow window;
    window.resize(400, 400);
    window.show();

    return app.exec();
}
