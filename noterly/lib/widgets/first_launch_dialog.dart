import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class FirstLaunchDialog extends Dialog {
  /// The most recent build number in which this dialog was updated.
  static const int lastUpdatedBuildNumber = 11;

  final Function onComplete;
  final bool isShownAfterUpdate;

  FirstLaunchDialog({
    Key? key,
    required this.onComplete,
    this.isShownAfterUpdate = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var pages = <_LaunchDialogPage>[
      _LaunchDialogPage(
        title: 'Welcome to Noterly',
        subtitle: 'Simple notification reminders',
        content: "Here's some basic information to get you started.",
      ),
      _LaunchDialogPage(
        title: 'Reminders',
        content: 'Noterly is designed for quick, simple reminders. You may find a to-do list or calendar app more suitable for more complex tasks.',
        icon: Icons.notifications_active,
      ),
      _LaunchDialogPage(
        title: 'Create a notification',
        content: 'Tap the floating button to create a new notification.',
        child: FloatingActionButton.extended(
          onPressed: () {
            const messages = ["That's right!", 'Well done!', "You've got it!", 'Great job!', 'Great success!'];
            var message = messages[DateTime.now().second % messages.length];
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
          },
          label: Text(translate('main.action.new')),
          icon: const Icon(Icons.add),
        ),
      ),
      _LaunchDialogPage(
        title: 'Manage notifications',
        content: 'Completed your task? Swipe the notification away. To delete a notification, go to the archive page and swipe it away.',
        child: Column(
          children: [
            Material(
              elevation: 1,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                  Container(
                    color: Theme.of(context).primaryColor,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 32, 16),
                      child: Icon(
                        Icons.archive,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Swipe to archive'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      _LaunchDialogPage(
        title: 'Snoozing reminders',
        content: 'You can snooze a reminder by tapping the button in the notification. Customise the snooze duration in settings.',
      ),
      _LaunchDialogPage(
        title: "That's it!",
        content: "You're ready to start using Noterly. You can always come back to this page in settings.",
      ),
    ];
    var currentPage = 0;

    return Dialog(
      child: StatefulBuilder(
        builder: (context, setState) {
          var hasSubtitle = pages[currentPage].subtitle != null;
          Widget subtitle = hasSubtitle ? Text(pages[currentPage].subtitle!, style: Theme.of(context).textTheme.titleMedium) : const SizedBox();

          var hasChild = !(pages[currentPage].child == null && pages[currentPage].image == null);
          Widget child = Padding(
            padding: EdgeInsets.symmetric(vertical: hasChild ? 16 : 8),
            child: pages[currentPage].child ?? const SizedBox(),
          );

          var hasIcon = pages[currentPage].icon != null;

          var title = hasIcon
              ? Row(
                  children: [
                    Icon(pages[currentPage].icon),
                    const SizedBox(width: 16),
                    Text(pages[currentPage].title, style: Theme.of(context).textTheme.titleLarge),
                  ],
                )
              : Text(pages[currentPage].title, style: Theme.of(context).textTheme.titleLarge);
          var content = Text(pages[currentPage].content);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    title,
                    subtitle,
                    child,
                    content,
                    if (isShownAfterUpdate && currentPage == 0) ...[
                      const SizedBox(height: 16),
                      Text("You're seeing this because this first launch experience has been updated.", style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ],
                ),
              ),
              DotsIndicator(
                dotsCount: pages.length,
                position: currentPage,
                mainAxisAlignment: MainAxisAlignment.center,
              ),
              ButtonBar(
                children: [
                  TextButton(
                    onPressed: () {
                      if (currentPage == 0) {
                        onComplete();
                        Navigator.of(context).pop();
                      } else {
                        setState(() {
                          currentPage--;
                        });
                      }
                    },
                    child: Text(currentPage == 0 ? 'Skip' : 'Back'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (currentPage == pages.length - 1) {
                        onComplete();
                        Navigator.of(context).pop();
                      } else {
                        setState(() {
                          currentPage++;
                        });
                      }
                    },
                    child: Text(currentPage == pages.length - 1 ? 'Done' : 'Next'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LaunchDialogPage {
  /// The title of the page
  String title;

  /// A subtitle to show directly below the title
  String? subtitle;

  /// The main text content of the page
  String content;

  /// An image to show on the page
  Image? image;

  /// A widget to show on the page
  Widget? child;

  /// An icon to show before the title
  IconData? icon;

  _LaunchDialogPage({
    required this.title,
    this.subtitle,
    required this.content,
    this.image,
    this.child,
    this.icon,
  });
}
