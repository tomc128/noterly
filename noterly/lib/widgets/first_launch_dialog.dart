import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:noterly/l10n/localisations_util.dart';

class FirstLaunchDialog extends Dialog {
  /// The most recent build number in which this dialog was updated.
  static const int lastUpdatedBuildNumber = 11;

  final Function onComplete;
  final bool isShownAfterUpdate;

  const FirstLaunchDialog({
    Key? key,
    required this.onComplete,
    this.isShownAfterUpdate = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var pages = <_LaunchDialogPage>[
      _LaunchDialogPage(
        title: Strings.of(context).tutorial_page_0_title,
        subtitle: Strings.of(context).tutorial_page_0_subtitle,
        content: Strings.of(context).tutorial_page_0_content,
      ),
      _LaunchDialogPage(
        title: Strings.of(context).tutorial_page_1_title,
        content: Strings.of(context).tutorial_page_1_content,
        icon: Icons.notifications_active,
      ),
      _LaunchDialogPage(
        title: Strings.of(context).tutorial_page_2_title,
        content: Strings.of(context).tutorial_page_2_content,
        child: FloatingActionButton.extended(
          onPressed: () {
            var messages = Strings.of(context).tutorial_page_2_confirmations.split('|');
            var message = messages[DateTime.now().second % messages.length];
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
          },
          label: Text(Strings.of(context).main_action_new),
          icon: const Icon(Icons.add),
        ),
      ),
      _LaunchDialogPage(
        title: Strings.of(context).tutorial_page_3_title,
        content: Strings.of(context).tutorial_page_3_content,
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
                        child: Text(Strings.of(context).tutorial_page_3_example),
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
        title: Strings.of(context).tutorial_page_4_title,
        content: Strings.of(context).tutorial_page_4_content,
      ),
      _LaunchDialogPage(
        title: Strings.of(context).tutorial_page_5_title,
        content: Strings.of(context).tutorial_page_5_content,
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
                      Text(Strings.of(context).tutorial_updatedExperienceText, style: Theme.of(context).textTheme.labelSmall),
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
                    child: Text(currentPage == 0 ? Strings.of(context).tutorial_action_skip : Strings.of(context).tutorial_action_back),
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
                    child: Text(currentPage == pages.length - 1 ? Strings.of(context).tutorial_action_done : Strings.of(context).tutorial_action_next),
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
    this.child,
    this.icon,
  });
}
