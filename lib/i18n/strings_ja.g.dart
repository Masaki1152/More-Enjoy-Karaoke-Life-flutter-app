///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsJa = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ja,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ja>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsCommonJa common = TranslationsCommonJa.internal(_root);
	late final TranslationsMessagesJa messages = TranslationsMessagesJa.internal(_root);
	late final TranslationsAboutJa about = TranslationsAboutJa.internal(_root);
	late final TranslationsGameJa game = TranslationsGameJa.internal(_root);
}

// Path: common
class TranslationsCommonJa {
	TranslationsCommonJa.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ja: 'スタート'
	String get start => 'スタート';

	/// ja: 'アプリについて'
	String get aboutApp => 'アプリについて';
}

// Path: messages
class TranslationsMessagesJa {
	TranslationsMessagesJa.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ja: ''
	String get example => '';
}

// Path: about
class TranslationsAboutJa {
	TranslationsAboutJa.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ja: 'カラオケを愛するすべてのあなたへ！'
	String get title => 'カラオケを愛するすべてのあなたへ！';

	/// ja: 'いつものカラオケがもっと楽しくなる遊びが、このアプリに大集合！\n\n🏆 個人戦でガチ勝負！\n🤝 ペア戦で絆を深める！\n🌟 全員での協力プレー！\n\nただ歌うだけじゃもったいない！\nさあ、最高のステージへ！'
	String get description => 'いつものカラオケがもっと楽しくなる遊びが、このアプリに大集合！\n\n🏆 個人戦でガチ勝負！\n🤝 ペア戦で絆を深める！\n🌟 全員での協力プレー！\n\nただ歌うだけじゃもったいない！\nさあ、最高のステージへ！';
}

// Path: game
class TranslationsGameJa {
	TranslationsGameJa.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ja: '遊べるゲーム一覧'
	String get gameList => '遊べるゲーム一覧';

	/// ja: '近日公開予定！\nお楽しみに...!!!'
	String get comingSoonGame => '近日公開予定！\nお楽しみに...!!!';
}

/// The flat map containing all translations for locale <ja>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'common.start' => 'スタート',
			'common.aboutApp' => 'アプリについて',
			'messages.example' => '',
			'about.title' => 'カラオケを愛するすべてのあなたへ！',
			'about.description' => 'いつものカラオケがもっと楽しくなる遊びが、このアプリに大集合！\n\n🏆 個人戦でガチ勝負！\n🤝 ペア戦で絆を深める！\n🌟 全員での協力プレー！\n\nただ歌うだけじゃもったいない！\nさあ、最高のステージへ！',
			'game.gameList' => '遊べるゲーム一覧',
			'game.comingSoonGame' => '近日公開予定！\nお楽しみに...!!!',
			_ => null,
		};
	}
}
