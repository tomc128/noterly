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
        title: translate('tutorial.page.0.title'),
        subtitle: translate('tutorial.page.0.subtitle'),
        content: translate('tutorial.page.0.content'),
      ),
      _LaunchDialogPage(
        title: translate('tutorial.page.1.title'),
        content: translate('tutorial.page.1.content'),
        icon: Icons.notifications_active,
      ),
      _LaunchDialogPage(
        title: translate('tutorial.page.2.title'),
        content: translate('tutorial.page.2.content'),
        child: FloatingActionButton.extended(
          onPressed: () {
            var messages = [
              translate('tutorial.page.2.confirmation.0'),
              translate('tutorial.page.2.confirmation.1'),
              translate('tutorial.page.2.confirmation.2'),
              translate('tutorial.page.2.confirmation.3'),
              translate('tutorial.page.2.confirmation.4'),
            ];
            var message = messages[DateTime.now().second % messages.length];
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
          },
          label: Text(translate('main.action.new')),
          icon: const Icon(Icons.add),
        ),
      ),
      _LaunchDialogPage(
        title: translate('tutorial.page.3.title'),
        content: translate('tutorial.page.3.content'),
        child: Column(
          children: [
            Material(
              elevation: 0,
              shadowColor: Colors.transparent,
              color: Theme.of(context).primaryColor,
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
                  Expanded(
                    child: Material(
                      elevation: 1,
                      shadowColor: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(translate('tutorial.page.3.example')),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      _LaunchDialogPage(
        title: translate('tutorial.page.4.title'),
        content: translate('tutorial.page.4.content'),
      ),
      _LaunchDialogPage(
        title: translate('tutorial.page.5.title'),
        content: translate('tutorial.page.5.content'),
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
                      Text(translate('tutorial.updated_experience_text'), style: Theme.of(context).textTheme.labelSmall),
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
                    child: Text(translate(currentPage == 0 ? 'tutorial.action.skip' : 'tutorial.action.back')),
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
                    child: Text(translate(currentPage == pages.length - 1 ? 'tutorial.action.done' : 'tutorial.action.next')),
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
