import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foast_launcher/base/game.dart';
import 'package:foast_launcher/i18n/localizations.dart';
import 'package:foast_launcher/pages/app_bar.dart';
import 'package:foast_launcher/pages/download_page.dart';
import 'package:provider/provider.dart';

const double _width = 285;

class GamesPage extends StatefulWidget {
  const GamesPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  List<Game>? _games;

  void _refreshGameList({bool resetIndex = false}) {
    // Versions could be very many, here we put it into an isolate task
    compute(Game.loadFromPath, _getSelectedPath()).then((value) {
      _games = value;
      if (resetIndex) {
        context.read<GameData>().selected =
            value.isNotEmpty ? value[0] : EmptyGame();
      } else {
        // For a unknown bug
        context.read<GameData>().selected = context.read<GameData>().selected;
      }
    });
  }

  String _getSelectedPath() {
    return context.read<GameData>().standardPath
        ? getStandardPath()
        : './.minecraft';
  }

  void _handleChangePath(bool? newValue, {bool resetIndex = true}) {
    context.read<GameData>().standardPath = newValue!;
    _refreshGameList(resetIndex: resetIndex);
  }

  Widget _buildSubtitle(String text) {
    return Container(
      width: _width,
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        style: Theme.of(context).textTheme.caption,
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _buildSingleVersionCard(
      {required Widget icon,
      required String title,
      required String installed,
      required bool active,
      required onTap}) {
    return Center(
      child: Card(
        elevation: active ? 1 : 0,
        color:
            active ? Colors.white : Theme.of(context).scaffoldBackgroundColor,
        child: ListTile(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5))),
          selected: active,
          leading: icon,
          title: Text(title),
          subtitle: Text(installed),
          onTap: (!active) ? onTap : null,
        ),
      ),
    );
  }

  List<Widget> _buildVersionCards(List<Game> versions) {
    return versions
        .asMap()
        .map((index, game) {
          return MapEntry(
              index,
              _buildSingleVersionCard(
                  icon: Text('${game.icon.index}'),
                  title: game.version.displayName,
                  installed: game.getInstalled(context),
                  active: context.read<GameData>().selected.displayName ==
                      _games![index].displayName,
                  onTap: () {
                    context.read<GameData>().selected = _games![index];
                  }));
        })
        .values
        .toList();
  }

  void _deleteCurrentVersion() {
    final Game? _selectedGame = context.read<GameData>().selected;
    if (_selectedGame != null) {
      Directory(_selectedGame.path).delete(recursive: true);
      // Can't find a semantic name
      context.read<GameData>().selected = _games![0];
      _refreshGameList();
    }
  }

  @override
  Widget build(BuildContext context) {
    //final _selectedGameIndex = _games?.indexWhere((game) =>
    //game.displayName == context.read<GameData>().selected.displayName) ?? 0;
    return Scaffold(
        body: Column(children: [
      SubpageAppBar(
        title: t(context, 'games'),
      ),
      Expanded(
        flex: 1,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: _width,
                child: Column(
                  children: [
                    _buildSubtitle(t(context, 'game_path')),
                    ListView(
                      shrinkWrap: true,
                      children: [
                        RadioListTile(
                          title: Text(t(context, 'path_current')),
                          value: false,
                          groupValue: context.watch<GameData>().standardPath,
                          onChanged: _handleChangePath,
                        ),
                        RadioListTile(
                          title: Text(t(context, 'path_official')),
                          value: true,
                          groupValue: context.watch<GameData>().standardPath,
                          onChanged: _handleChangePath,
                        ),
                      ],
                    ),
                    _buildSubtitle(t(context, 'add_or_import')),
                    ListView(
                      shrinkWrap: true,
                      children: [
                        ListTile(
                          title: Text(t(context, 'install_version')),
                          leading: const Icon(Icons.download_rounded),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const DownloadPage()));
                          },
                        ),
                        ListTile(
                          title: Text(t(context, 'import_modpack')),
                          leading: const Icon(Icons.add_circle_rounded),
                          enabled: false,
                        ),
                      ],
                    ),
                    _buildSubtitle(t(context, 'operations')),
                    ListView(
                      shrinkWrap: true,
                      children: [
                        ListTile(
                            enabled: _games != null,
                            title: Text(t(context, 'delete_version')),
                            leading: const Icon(Icons.delete_rounded),
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title:
                                            Text(t(context, 'delete_version?')),
                                        content: Text(
                                            t(context, 'warn_delete_version')),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                _deleteCurrentVersion();
                                                Navigator.of(context).pop(true);
                                              },
                                              child: Text(t(
                                                  context, 'delete_version'))),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(true);
                                              },
                                              child:
                                                  Text(t(context, 'cancel'))),
                                        ],
                                      ));
                            }),
                        ListTile(
                            enabled: _games != null,
                            title: Text(t(context, 'refresh')),
                            leading: const Icon(Icons.refresh_rounded),
                            onTap: () {
                              _refreshGameList();
                            }),
                      ],
                    ),
                  ],
                )),
            const VerticalDivider(width: 1),
            Expanded(
                flex: 1,
                child: (_games?.isNotEmpty ?? true)
                    ? GridView.count(
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        padding: const EdgeInsets.all(10.0),
                        crossAxisCount: 2,
                        childAspectRatio: 4.5,
                        controller: ScrollController(),
                        children: _buildVersionCards(_games ?? []))
                    : Center(
                        child: Text(t(context, 'no_games_installed'),
                            style: Theme.of(context).textTheme.caption),
                      ))
          ],
        ),
      )
    ]));
  }

  @override
  void initState() {
    super.initState();
    _refreshGameList();
    _handleChangePath(context.read<GameData>().standardPath, resetIndex: false);
  }
}
