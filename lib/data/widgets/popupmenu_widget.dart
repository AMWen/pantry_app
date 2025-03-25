import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/snackbar_util.dart';
import '../constants.dart';
import 'basic_widgets.dart';

enum Menu { info, download }

class PopupMenu extends StatefulWidget {
  const PopupMenu({super.key});

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

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: alertPadding,
          title: AlertTitle('Add a list'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // 'title': 'Pantry',
                // itemType dropdown
                // icon
                // countable or not
                // has moveTo or not
              ],
            ),
          ),
          actions: [CancelButton()],
        );
      },
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: alertPadding,
          title: AlertTitle('Delete list(s)'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // multiselect checkbox for deletion
              ],
            ),
          ),
          actions: [CancelButton()],
        );
      },
    );
  }

  void _showManageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: alertPadding,
          title: AlertTitle('Manage Lists'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  minTileHeight: 10,
                  title: Text('Add a list', style: TextStyles.mediumText),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showAddDialog();
                  },
                ),
                ListTile(
                  minTileHeight: 10,
                  title: Text('Delete list(s)', style: TextStyles.mediumText),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showDeleteDialog();
                  },
                ),
              ],
            ),
          ),
          actions: [CancelButton()],
        );
      },
    );
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
                value: Menu.info,
                child: ListTile(
                  leading: Icon(Icons.info),
                  title: Text('Info'),
                  onTap: () {
                    _launchUrl(
                      'https://github.com/AMWen/pantry_app?tab=readme-ov-file#key-features-in-detail',
                    );
                  },
                ),
              ),
              PopupMenuItem<Menu>(
                value: Menu.download,
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Manage Lists'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showManageDialog();
                  },
                ),
              ),
            ],
      ),
    );
  }
}
