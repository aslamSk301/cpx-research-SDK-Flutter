/*
 * cpx_survey_cards.dart
 * CPX Research
 */

import 'package:cpx_research_sdk_flutter/model/cpx_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

import '../cpx_data.dart';

class CPXSurveyCards extends StatefulWidget {
  final CPXCardConfig? config;
  final Widget? noSurveysWidget;
  final bool hideIfEmpty;
  final EdgeInsets? padding;
  final CPXCardBuilder? builder;

  const CPXSurveyCards({
    super.key,
    this.config,
    this.noSurveysWidget,
    this.hideIfEmpty = false,
    this.padding,
    this.builder,
  });

  @override
  _CPXSurveyCardsState createState() => _CPXSurveyCardsState();
}

class _CPXSurveyCardsState extends State<CPXSurveyCards> {
  CPXData cpxData = CPXData.cpxData;
  List<Survey> surveys = [];
  late CPXCardConfig config;
  late final CPXCardBuilder cardBuilder;

  _onSurveyUpdate() => setState(() => surveys = cpxData.surveys.value ?? []);

  @override
  void initState() {
    super.initState();
    surveys = cpxData.surveys.value ?? [];
    cpxData.surveys.addListener(_onSurveyUpdate);
    config = widget.config ?? CPXCardConfig();
    cardBuilder = widget.builder ?? _defaultCPXCardBuilder;
  }

  Widget _defaultCPXCardBuilder(
      List<Survey> surveys, CPXCardConfig config, CPXText? text) {
    final cardHeight = MediaQuery.of(context).size.width /
            (MediaQuery.of(context).orientation == Orientation.portrait
                ? config.cardCount
                : config.cardCount * 2.5) +
        30;

    return SizedBox(
      height: cardHeight,
      child: GridView.builder(
        padding: widget.padding ??
            const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        itemCount: surveys.isNotEmpty ? surveys.length : config.cardCount,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 5,
        ),
        itemBuilder: (context, index) {
          if (surveys.isNotEmpty) {
            return _CPXCard(surveys[index], config, text);
          } else {
            return _CPXCardShimmer(config);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) =>
      cardBuilder(surveys, config, cpxData.text.value);
}

typedef CPXCardBuilder = Widget Function(
    List<Survey> surveys, CPXCardConfig config, CPXText? text);

class CPXCardConfig {
  final Color accentColor;
  final Color cardBackgroundColor;
  final Color inactiveStarColor;
  final Color starColor;
  final Color textColor;
  final Color payoutColor;
  final int cardCount;

  CPXCardConfig({
    this.accentColor = const Color(0xff41d7e5),
    this.cardBackgroundColor = Colors.white,
    this.inactiveStarColor = const Color(0xffdfdfdf),
    this.starColor = const Color(0xffffc400),
    this.textColor = Colors.black,
    this.payoutColor = Colors.red,
    this.cardCount = 3,
  });
}

class _CPXCard extends StatelessWidget {
  const _CPXCard(
    this.survey,
    this.config,
    this.cpxText, {
    Key? key,
  }) : super(key: key);

  final Survey survey;
  final CPXText? cpxText;
  final CPXCardConfig config;

  Widget _getStars() {
    final List<Icon> list = [];
    for (var i = 1; i <= 5; i++) {
      list.add(
        Icon(
          Icons.star,
          color: i <= (survey.statisticsRatingAvg ?? 0)
              ? config.starColor
              : config.inactiveStarColor,
        ),
      );
    }
    return Row(children: list);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: config.cardBackgroundColor,
          foregroundColor: config.inactiveStarColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: () {
          HapticFeedback.selectionClick();
          showCPXBrowserOverlay(survey.id);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                survey.payoutOriginal != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          FittedBox(
                            child: Text(
                              survey.payoutOriginal ?? '?',
                              style: TextStyle(
                                color: config.textColor,
                                fontSize: 18,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                          FittedBox(
                            child: Text(
                              survey.payout ?? '?',
                              style: TextStyle(
                                color: config.payoutColor,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      )
                    : FittedBox(
                        child: Text(
                          survey.payout ?? '?',
                          style: TextStyle(
                            color: config.accentColor,
                            fontSize: 18,
                          ),
                        ),
                      ),
                FittedBox(
                  child: Text(
                    cpxText?.currency_name_plural ?? 'Coins',
                    style: TextStyle(color: config.accentColor),
                  ),
                ),
              ],
            ),
            FittedBox(
              child: Row(
                children: [
                  Icon(
                    Icons.watch_later_outlined,
                    color: config.accentColor,
                    size: Theme.of(context).textTheme.titleSmall?.fontSize,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${survey.loi ?? ''} ${cpxText?.shortcurt_min ?? 'Mins'}',
                    style: TextStyle(color: config.textColor),
                  ),
                ],
              ),
            ),
            FittedBox(child: _getStars()),
          ],
        ),
      ),
    );
  }
}

class _CPXCardShimmer extends StatelessWidget {
  final CPXCardConfig config;

  const _CPXCardShimmer(this.config);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          decoration: BoxDecoration(
            color: config.cardBackgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}