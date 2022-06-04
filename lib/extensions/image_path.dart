extension ImagePath on String {
  String svgPath() => "assets/images/svg/$this";
  String pngPath() => "assets/images/png/$this";
  String phPath() => "assets/images/placeholder/$this";
  String lottiePath() => "assets/lotties/$this";
}
