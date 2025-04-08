import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/file_utils.dart';
import '../../utils/hivebox_utils.dart';
import '../../utils/widget_utils.dart';
import '../classes/list_item.dart';
import '../constants.dart';
import 'basic_widgets.dart';
import 'managelistsdialog_widget.dart';
import 'moveitemsdialog_widget.dart';

enum Menu { info, help, manage, move }

class PopupMenu extends StatefulWidget {
  final ValueNotifier<int> refreshNotifier;
  final String boxName;
  final Box<ListItem> itemBox;
  final Set<int> selectedItemIds;

  const PopupMenu({
    super.key,
    required this.refreshNotifier,
    required this.boxName,
    required this.itemBox,
    required this.selectedItemIds,
  });

  @override
  PopupMenuState createState() => PopupMenuState();
}

class PopupMenuState extends State<PopupMenu> {
  Future<void> _launchUrl(String url) async {
    // Prepend "http://" if no protocol is provided
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }

    final Uri parsedUrl = Uri.parse(url);

    if (!await launchUrl(parsedUrl)) {
      if (mounted) {
        showErrorSnackbar(context, 'Could not launch $url');
      }
    }
  }

  void _showManageListsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ManageListsDialog(refreshNotifier: widget.refreshNotifier);
      },
    );
    initializeHiveBoxes();
  }

  Future<String?> _showMoveItemsDialog() async {
    if (widget.selectedItemIds.isNotEmpty) {
      return showDialog<String?>(
        context: context,
        builder: (BuildContext context) {
          return MoveItemsDialog(
            boxName: widget.boxName,
            itemBox: widget.itemBox,
            selectedItemIds: widget.selectedItemIds,
          );
        },
      );
    } else {
      showErrorSnackbar(context, 'No items selected for migration!');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      child: PopupMenuButton<Menu>(
        icon: const Icon(Icons.more_vert),
        onSelected: (Menu item) {},
        itemBuilder:
            (BuildContext context) => <PopupMenuEntry<Menu>>[
              PopupMenuItem<Menu>(
                value: Menu.move,
                child: ListTile(
                  leading: Icon(Icons.local_shipping),
                  title: Text('Move items'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    String? moveTo = await _showMoveItemsDialog();
                    if (moveTo != null) {
                      widget.selectedItemIds.clear();
                      setLastUpdated(widget.boxName);
                      setLastUpdated(moveTo);
                    }
                  },
                ),
              ),
              PopupMenuItem<Menu>(
                value: Menu.manage,
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Manage Lists'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showManageListsDialog();
                  },
                ),
              ),
              PopupMenuItem<Menu>(
                value: Menu.help,
                child: ListTile(
                  leading: Icon(Icons.help_outline),
                  title: Text('How to Use'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _launchUrl(
                      'https://github.com/AMWen/pantry_app?tab=readme-ov-file#key-features-in-detail',
                    );
                  },
                ),
              ),
              PopupMenuItem<Menu>(
                value: Menu.info,
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Info'),
                  onTap: () {
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          contentPadding: alertPadding,
                          title: AlertTitle('Pantry App'),
                          content: Text(
                            'A simple and intuitive mobile app built with Flutter that helps you keep '
                            'track of all your lists. Meant to be a no-frills, offline app, not '
                            'requiring creation or access to any accounts.',
                          ),
                          actions: [OkButton()],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
      ),
    );
  }
}
