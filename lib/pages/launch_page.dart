import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foast_launcher/base/game.dart' show Game, GameData;
import 'package:foast_launcher/common.dart';
import 'package:foast_launcher/localizations.dart';
import 'package:foast_launcher/pages/accounts_page.dart';
import 'package:foast_launcher/pages/games_page.dart';
import 'package:foast_launcher/pages/version_list.dart';
import 'package:provider/provider.dart';

class LaunchPage extends StatelessWidget {
  const LaunchPage({Key? key}) : super(key: key);

  void _popupVersionSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n(context).selectVersion),
        children: [
          SizedBox(
            width: 500,
            child: FutureProvider<List<Game>>(
              create: (context) => compute(
                  Game.loadFromPath, context.read<GameData>().selectedPath),
              initialData: const [],
              builder: (context, _) => VersionList(
                games: context.watch<List<Game>>(),
                onSelect: (game) {
                  context.read<GameData>().selected = game;
                  Navigator.of(context).pop();
                },
                height: 400,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              children: [
                OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      navigateToWidget(context, const GamesPage());
                    },
                    child: Text(l10n(context).manageVersions))
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedGame = context.watch<GameData>().selected;

    return Column(
      children: [
        Expanded(
            flex: 1,
            child: Stack(
              children: [
                Positioned(
                    bottom: 40,
                    right: 40,
                    child: Row(
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              height: 35,
                              width: 180,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // Navigator.of(context).push(MaterialPageRoute(
                                  //     builder: (context) => const GamesPage()));
                                  _popupVersionSelector(context);
                                },
                                icon: const Icon(FluentIcons.games_24_regular),
                                label: Text(l10n(context).selectVersion),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 35,
                              width: 180,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  navigateToWidget(
                                      context, const AccountsPage());
                                },
                                icon: const Icon(FluentIcons.person_24_regular),
                                label: Text(l10n(context).manageAccounts),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 250,
                          height: 80,
                          child: ElevatedButton(
                            onPressed: selectedGame.empty ? null : () {},
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  l10n(context).launch,
                                  style: TextStyle(
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.fontSize),
                                ),
                                Text(selectedGame.empty
                                    ? l10n(context).noGamesSelected
                                    : selectedGame.displayName)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ))
              ],
            ))
      ],
    );
  }
}
