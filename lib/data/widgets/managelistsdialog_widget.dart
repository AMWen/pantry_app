import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:pantry_app/data/widgets/basic_widgets.dart';
import 'package:pantry_app/utils/snackbar_util.dart';

import '../../utils/hivebox_utils.dart';
import '../classes/tab_configuration.dart';
import '../classes/tab_item.dart';
import '../constants.dart';

class ManageListsDialog extends StatefulWidget {
  const ManageListsDialog({super.key});

  @override
  ManageListsDialogState createState() => ManageListsDialogState();
}

class ManageListsDialogState extends State<ManageListsDialog> {
  @override
  void initState() {
    super.initState();
  }

  Future<bool?> _resetLists() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: alertPadding,
          title: AlertTitle('Are you sure you want to reset lists to default?'),
          content: Text('Any new lists will be removed. This action cannot be undone.'),
          actions: [
            CancelButton(),
            FilledButton(
              onPressed: () async {
                Box<TabConfiguration> tabBox = getTabConfigurationsBox();
                Navigator.of(context).pop(true);
                for (var key in tabBox.keys) {
                  await tabBox.delete(key); // delete all
                }
                for (var config in defaultTabConfigurations) {
                  await tabBox.put(config.title, config); // add defaults
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showEditListDialog(String tabTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: alertPadding,
          title: AlertTitle('Edit a list'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // click item
                // 'title': 'Pantry',
                // itemType dropdown
                // icon
                // countable or not
                // has moveTo or not
                // edit option
              ],
            ),
          ),
          actions: [CancelButton()],
        );
      },
    );
  }

  Future<void> _showEditDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: alertPadding,
          title: AlertTitle('Edit a list'),
          content: SingleChildScrollView(
            child: Column(
              children:
                  generateTabItems().map<Widget>((TabItem tabItem) {
                    return ListTile(
                      minTileHeight: 10,
                      leading: tabItem.icon,
                      title: Text(tabItem.label, style: TextStyles.mediumText),
                      onTap: () {
                        _showEditListDialog(tabItem.label);
                      },
                    );
                  }).toList(),
            ),
          ),
          actions: [CancelButton()],
        );
      },
    );
  }

  Future<void> _showAddDialog() async {
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

  Future<void> _deleteList(String tabTitle) async {
    // Soft delete, only delete from tab configurations, not box settings and list items
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: alertPadding,
          title: AlertTitle('Are you sure you want to delete $tabTitle?'),
          content: Text('This action cannot be undone.'),
          actions: [
            CancelButton(),
            FilledButton(
              onPressed: () async {
                Box<TabConfiguration> tabBox = getTabConfigurationsBox();
                tabBox.delete(tabTitle);
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // remove previous _showDeleteDialog
                await _showDeleteDialog(); // re-render
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteDialog() async {
    await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: alertPadding,
          title: AlertTitle('Delete list(s)'),
          content: SingleChildScrollView(
            child: Column(
              children:
                  generateTabItems().map<Widget>((TabItem tabItem) {
                    return ListTile(
                      minTileHeight: 10,
                      leading: tabItem.icon,
                      title: Text(tabItem.label, style: TextStyles.mediumText),
                      onTap: () {
                        if (generateTabItems().length > 1) {
                          _deleteList(tabItem.label);
                        } else {
                          showErrorSnackbar(context, 'Need to keep at least one list.');
                        }
                      },
                    );
                  }).toList(),
            ),
          ),
          actions: [CancelButton()],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: alertPadding,
      title: AlertTitle('Manage Lists'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              minTileHeight: 10,
              leading: Icon(Icons.edit),
              title: Text('Edit a list', style: TextStyles.mediumText),
              onTap: () async {
                await _showEditDialog();
              },
            ),
            ListTile(
              minTileHeight: 10,
              leading: Icon(Icons.add),
              title: Text('Add a list', style: TextStyles.mediumText),
              onTap: () async {
                await _showAddDialog();
              },
            ),
            ListTile(
              minTileHeight: 10,
              leading: Icon(Icons.remove),
              title: Text('Delete list(s)', style: TextStyles.mediumText),
              onTap: () async {
                await _showDeleteDialog();
              },
            ),
            ListTile(
              minTileHeight: 10,
              leading: Icon(Icons.restore),
              title: Text('Reset lists to default', style: TextStyles.mediumText),
              onTap: () async {
                bool? result = await _resetLists();
                print('result');
                print(result ?? 'null');
                if (mounted && result == true) {
                  showErrorSnackbar(context, 'Lists have been reset!');
                }
              },
            ),
          ],
        ),
      ),
      actions: [CancelButton()],
    );
  }
}
