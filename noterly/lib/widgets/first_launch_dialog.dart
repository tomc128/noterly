import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class FirstLaunchDialog extends Dialog {
  final Function onComplete;

  FirstLaunchDialog({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var pages = <_LaunchDialogPage>[
      _LaunchDialogPage(
        title: 'Welcome to Noterly',
        content: 'Noterly is a simple app for creating and managing notifications.',
      ),
      _LaunchDialogPage(
        title: 'Create a notification',
        content: 'Tap the floating button to create a new notification.',
        child: FloatingActionButton.extended(
          onPressed: () {},
          label: Text(translate('main.action.new')),
          icon: const Icon(Icons.add),
        ),
      ),
      _LaunchDialogPage(
        title: 'Manage notifications',
        content: 'Swipe a notification in the app to mark it as done. Go to the archive page to swipe to delete notifications.',
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
    ];
    var currentPage = 0;

    return Dialog(
      child: StatefulBuilder(
        builder: (context, setState) {
          var title = Text(pages[currentPage].title, style: Theme.of(context).textTheme.titleLarge);
          var content = Text(pages[currentPage].content);

          var hasChild = !(pages[currentPage].child == null && pages[currentPage].image == null);

          Widget widget = Padding(
            padding: EdgeInsets.symmetric(vertical: hasChild ? 16 : 8),
            child: pages[currentPage].child ?? SizedBox(),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    title,
                    widget,
                    content,
                  ],
                ),
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
  String title;
  String content;
  Image? image;
  Widget? child;

  _LaunchDialogPage({
    required this.title,
    required this.content,
    this.image,
    this.child,
  });
}
