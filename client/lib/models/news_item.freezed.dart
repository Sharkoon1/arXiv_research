// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'news_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NewsItem _$NewsItemFromJson(Map<String, dynamic> json) {
  return _NewsItem.fromJson(json);
}

/// @nodoc
mixin _$NewsItem {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get summary => throw _privateConstructorUsedError;
  @JsonKey(name: 'why_it_matters')
  String get whyItMatters => throw _privateConstructorUsedError;
  @JsonKey(name: 'source_name')
  String get sourceName => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  @JsonKey(name: 'published_date')
  String get publishedDate => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'importance_score')
  int get importanceScore => throw _privateConstructorUsedError;

  /// Serializes this NewsItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NewsItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NewsItemCopyWith<NewsItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NewsItemCopyWith<$Res> {
  factory $NewsItemCopyWith(NewsItem value, $Res Function(NewsItem) then) =
      _$NewsItemCopyWithImpl<$Res, NewsItem>;
  @useResult
  $Res call(
      {String id,
      String title,
      String summary,
      @JsonKey(name: 'why_it_matters') String whyItMatters,
      @JsonKey(name: 'source_name') String sourceName,
      String url,
      @JsonKey(name: 'published_date') String publishedDate,
      String category,
      @JsonKey(name: 'importance_score') int importanceScore});
}

/// @nodoc
class _$NewsItemCopyWithImpl<$Res, $Val extends NewsItem>
    implements $NewsItemCopyWith<$Res> {
  _$NewsItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NewsItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? summary = null,
    Object? whyItMatters = null,
    Object? sourceName = null,
    Object? url = null,
    Object? publishedDate = null,
    Object? category = null,
    Object? importanceScore = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      whyItMatters: null == whyItMatters
          ? _value.whyItMatters
          : whyItMatters // ignore: cast_nullable_to_non_nullable
              as String,
      sourceName: null == sourceName
          ? _value.sourceName
          : sourceName // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      publishedDate: null == publishedDate
          ? _value.publishedDate
          : publishedDate // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      importanceScore: null == importanceScore
          ? _value.importanceScore
          : importanceScore // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NewsItemImplCopyWith<$Res>
    implements $NewsItemCopyWith<$Res> {
  factory _$$NewsItemImplCopyWith(
          _$NewsItemImpl value, $Res Function(_$NewsItemImpl) then) =
      __$$NewsItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String summary,
      @JsonKey(name: 'why_it_matters') String whyItMatters,
      @JsonKey(name: 'source_name') String sourceName,
      String url,
      @JsonKey(name: 'published_date') String publishedDate,
      String category,
      @JsonKey(name: 'importance_score') int importanceScore});
}

/// @nodoc
class __$$NewsItemImplCopyWithImpl<$Res>
    extends _$NewsItemCopyWithImpl<$Res, _$NewsItemImpl>
    implements _$$NewsItemImplCopyWith<$Res> {
  __$$NewsItemImplCopyWithImpl(
      _$NewsItemImpl _value, $Res Function(_$NewsItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of NewsItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? summary = null,
    Object? whyItMatters = null,
    Object? sourceName = null,
    Object? url = null,
    Object? publishedDate = null,
    Object? category = null,
    Object? importanceScore = null,
  }) {
    return _then(_$NewsItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      whyItMatters: null == whyItMatters
          ? _value.whyItMatters
          : whyItMatters // ignore: cast_nullable_to_non_nullable
              as String,
      sourceName: null == sourceName
          ? _value.sourceName
          : sourceName // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      publishedDate: null == publishedDate
          ? _value.publishedDate
          : publishedDate // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      importanceScore: null == importanceScore
          ? _value.importanceScore
          : importanceScore // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NewsItemImpl extends _NewsItem {
  const _$NewsItemImpl(
      {required this.id,
      required this.title,
      required this.summary,
      @JsonKey(name: 'why_it_matters') required this.whyItMatters,
      @JsonKey(name: 'source_name') required this.sourceName,
      required this.url,
      @JsonKey(name: 'published_date') required this.publishedDate,
      required this.category,
      @JsonKey(name: 'importance_score') required this.importanceScore})
      : super._();

  factory _$NewsItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$NewsItemImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String summary;
  @override
  @JsonKey(name: 'why_it_matters')
  final String whyItMatters;
  @override
  @JsonKey(name: 'source_name')
  final String sourceName;
  @override
  final String url;
  @override
  @JsonKey(name: 'published_date')
  final String publishedDate;
  @override
  final String category;
  @override
  @JsonKey(name: 'importance_score')
  final int importanceScore;

  @override
  String toString() {
    return 'NewsItem(id: $id, title: $title, summary: $summary, whyItMatters: $whyItMatters, sourceName: $sourceName, url: $url, publishedDate: $publishedDate, category: $category, importanceScore: $importanceScore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NewsItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.whyItMatters, whyItMatters) ||
                other.whyItMatters == whyItMatters) &&
            (identical(other.sourceName, sourceName) ||
                other.sourceName == sourceName) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.publishedDate, publishedDate) ||
                other.publishedDate == publishedDate) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.importanceScore, importanceScore) ||
                other.importanceScore == importanceScore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, summary, whyItMatters,
      sourceName, url, publishedDate, category, importanceScore);

  /// Create a copy of NewsItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NewsItemImplCopyWith<_$NewsItemImpl> get copyWith =>
      __$$NewsItemImplCopyWithImpl<_$NewsItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NewsItemImplToJson(
      this,
    );
  }
}

abstract class _NewsItem extends NewsItem {
  const factory _NewsItem(
      {required final String id,
      required final String title,
      required final String summary,
      @JsonKey(name: 'why_it_matters') required final String whyItMatters,
      @JsonKey(name: 'source_name') required final String sourceName,
      required final String url,
      @JsonKey(name: 'published_date') required final String publishedDate,
      required final String category,
      @JsonKey(name: 'importance_score')
      required final int importanceScore}) = _$NewsItemImpl;
  const _NewsItem._() : super._();

  factory _NewsItem.fromJson(Map<String, dynamic> json) =
      _$NewsItemImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get summary;
  @override
  @JsonKey(name: 'why_it_matters')
  String get whyItMatters;
  @override
  @JsonKey(name: 'source_name')
  String get sourceName;
  @override
  String get url;
  @override
  @JsonKey(name: 'published_date')
  String get publishedDate;
  @override
  String get category;
  @override
  @JsonKey(name: 'importance_score')
  int get importanceScore;

  /// Create a copy of NewsItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NewsItemImplCopyWith<_$NewsItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
