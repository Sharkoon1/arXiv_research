// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ReportSummary _$ReportSummaryFromJson(Map<String, dynamic> json) {
  return _ReportSummary.fromJson(json);
}

/// @nodoc
mixin _$ReportSummary {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'paper_count')
  int get paperCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'news_count')
  int get newsCount => throw _privateConstructorUsedError;

  /// Serializes this ReportSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReportSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReportSummaryCopyWith<ReportSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportSummaryCopyWith<$Res> {
  factory $ReportSummaryCopyWith(
          ReportSummary value, $Res Function(ReportSummary) then) =
      _$ReportSummaryCopyWithImpl<$Res, ReportSummary>;
  @useResult
  $Res call(
      {String id,
      String name,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'paper_count') int paperCount,
      @JsonKey(name: 'news_count') int newsCount});
}

/// @nodoc
class _$ReportSummaryCopyWithImpl<$Res, $Val extends ReportSummary>
    implements $ReportSummaryCopyWith<$Res> {
  _$ReportSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReportSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? createdAt = null,
    Object? paperCount = null,
    Object? newsCount = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      paperCount: null == paperCount
          ? _value.paperCount
          : paperCount // ignore: cast_nullable_to_non_nullable
              as int,
      newsCount: null == newsCount
          ? _value.newsCount
          : newsCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReportSummaryImplCopyWith<$Res>
    implements $ReportSummaryCopyWith<$Res> {
  factory _$$ReportSummaryImplCopyWith(
          _$ReportSummaryImpl value, $Res Function(_$ReportSummaryImpl) then) =
      __$$ReportSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'paper_count') int paperCount,
      @JsonKey(name: 'news_count') int newsCount});
}

/// @nodoc
class __$$ReportSummaryImplCopyWithImpl<$Res>
    extends _$ReportSummaryCopyWithImpl<$Res, _$ReportSummaryImpl>
    implements _$$ReportSummaryImplCopyWith<$Res> {
  __$$ReportSummaryImplCopyWithImpl(
      _$ReportSummaryImpl _value, $Res Function(_$ReportSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReportSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? createdAt = null,
    Object? paperCount = null,
    Object? newsCount = null,
  }) {
    return _then(_$ReportSummaryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      paperCount: null == paperCount
          ? _value.paperCount
          : paperCount // ignore: cast_nullable_to_non_nullable
              as int,
      newsCount: null == newsCount
          ? _value.newsCount
          : newsCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReportSummaryImpl implements _ReportSummary {
  const _$ReportSummaryImpl(
      {required this.id,
      required this.name,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'paper_count') required this.paperCount,
      @JsonKey(name: 'news_count') required this.newsCount});

  factory _$ReportSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReportSummaryImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'paper_count')
  final int paperCount;
  @override
  @JsonKey(name: 'news_count')
  final int newsCount;

  @override
  String toString() {
    return 'ReportSummary(id: $id, name: $name, createdAt: $createdAt, paperCount: $paperCount, newsCount: $newsCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.paperCount, paperCount) ||
                other.paperCount == paperCount) &&
            (identical(other.newsCount, newsCount) ||
                other.newsCount == newsCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, createdAt, paperCount, newsCount);

  /// Create a copy of ReportSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportSummaryImplCopyWith<_$ReportSummaryImpl> get copyWith =>
      __$$ReportSummaryImplCopyWithImpl<_$ReportSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReportSummaryImplToJson(
      this,
    );
  }
}

abstract class _ReportSummary implements ReportSummary {
  const factory _ReportSummary(
          {required final String id,
          required final String name,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'paper_count') required final int paperCount,
          @JsonKey(name: 'news_count') required final int newsCount}) =
      _$ReportSummaryImpl;

  factory _ReportSummary.fromJson(Map<String, dynamic> json) =
      _$ReportSummaryImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'paper_count')
  int get paperCount;
  @override
  @JsonKey(name: 'news_count')
  int get newsCount;

  /// Create a copy of ReportSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportSummaryImplCopyWith<_$ReportSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReportDetail _$ReportDetailFromJson(Map<String, dynamic> json) {
  return _ReportDetail.fromJson(json);
}

/// @nodoc
mixin _$ReportDetail {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get briefing => throw _privateConstructorUsedError;
  List<Paper> get papers => throw _privateConstructorUsedError;
  List<NewsItem> get news => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ReportDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReportDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReportDetailCopyWith<ReportDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportDetailCopyWith<$Res> {
  factory $ReportDetailCopyWith(
          ReportDetail value, $Res Function(ReportDetail) then) =
      _$ReportDetailCopyWithImpl<$Res, ReportDetail>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? briefing,
      List<Paper> papers,
      List<NewsItem> news,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$ReportDetailCopyWithImpl<$Res, $Val extends ReportDetail>
    implements $ReportDetailCopyWith<$Res> {
  _$ReportDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReportDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? briefing = freezed,
    Object? papers = null,
    Object? news = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      briefing: freezed == briefing
          ? _value.briefing
          : briefing // ignore: cast_nullable_to_non_nullable
              as String?,
      papers: null == papers
          ? _value.papers
          : papers // ignore: cast_nullable_to_non_nullable
              as List<Paper>,
      news: null == news
          ? _value.news
          : news // ignore: cast_nullable_to_non_nullable
              as List<NewsItem>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReportDetailImplCopyWith<$Res>
    implements $ReportDetailCopyWith<$Res> {
  factory _$$ReportDetailImplCopyWith(
          _$ReportDetailImpl value, $Res Function(_$ReportDetailImpl) then) =
      __$$ReportDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? briefing,
      List<Paper> papers,
      List<NewsItem> news,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$ReportDetailImplCopyWithImpl<$Res>
    extends _$ReportDetailCopyWithImpl<$Res, _$ReportDetailImpl>
    implements _$$ReportDetailImplCopyWith<$Res> {
  __$$ReportDetailImplCopyWithImpl(
      _$ReportDetailImpl _value, $Res Function(_$ReportDetailImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReportDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? briefing = freezed,
    Object? papers = null,
    Object? news = null,
    Object? createdAt = null,
  }) {
    return _then(_$ReportDetailImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      briefing: freezed == briefing
          ? _value.briefing
          : briefing // ignore: cast_nullable_to_non_nullable
              as String?,
      papers: null == papers
          ? _value._papers
          : papers // ignore: cast_nullable_to_non_nullable
              as List<Paper>,
      news: null == news
          ? _value._news
          : news // ignore: cast_nullable_to_non_nullable
              as List<NewsItem>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReportDetailImpl implements _ReportDetail {
  const _$ReportDetailImpl(
      {required this.id,
      required this.name,
      this.briefing,
      final List<Paper> papers = const [],
      final List<NewsItem> news = const [],
      @JsonKey(name: 'created_at') required this.createdAt})
      : _papers = papers,
        _news = news;

  factory _$ReportDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReportDetailImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? briefing;
  final List<Paper> _papers;
  @override
  @JsonKey()
  List<Paper> get papers {
    if (_papers is EqualUnmodifiableListView) return _papers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_papers);
  }

  final List<NewsItem> _news;
  @override
  @JsonKey()
  List<NewsItem> get news {
    if (_news is EqualUnmodifiableListView) return _news;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_news);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'ReportDetail(id: $id, name: $name, briefing: $briefing, papers: $papers, news: $news, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.briefing, briefing) ||
                other.briefing == briefing) &&
            const DeepCollectionEquality().equals(other._papers, _papers) &&
            const DeepCollectionEquality().equals(other._news, _news) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      briefing,
      const DeepCollectionEquality().hash(_papers),
      const DeepCollectionEquality().hash(_news),
      createdAt);

  /// Create a copy of ReportDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportDetailImplCopyWith<_$ReportDetailImpl> get copyWith =>
      __$$ReportDetailImplCopyWithImpl<_$ReportDetailImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReportDetailImplToJson(
      this,
    );
  }
}

abstract class _ReportDetail implements ReportDetail {
  const factory _ReportDetail(
          {required final String id,
          required final String name,
          final String? briefing,
          final List<Paper> papers,
          final List<NewsItem> news,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$ReportDetailImpl;

  factory _ReportDetail.fromJson(Map<String, dynamic> json) =
      _$ReportDetailImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get briefing;
  @override
  List<Paper> get papers;
  @override
  List<NewsItem> get news;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of ReportDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportDetailImplCopyWith<_$ReportDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CollectResult _$CollectResultFromJson(Map<String, dynamic> json) {
  return _CollectResult.fromJson(json);
}

/// @nodoc
mixin _$CollectResult {
  @JsonKey(name: 'report_id')
  String get reportId => throw _privateConstructorUsedError;
  @JsonKey(name: 'report_name')
  String get reportName => throw _privateConstructorUsedError;
  List<Paper> get papers => throw _privateConstructorUsedError;
  List<NewsItem> get news => throw _privateConstructorUsedError;
  String? get briefing => throw _privateConstructorUsedError;
  List<String> get errors => throw _privateConstructorUsedError;

  /// Serializes this CollectResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CollectResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CollectResultCopyWith<CollectResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CollectResultCopyWith<$Res> {
  factory $CollectResultCopyWith(
          CollectResult value, $Res Function(CollectResult) then) =
      _$CollectResultCopyWithImpl<$Res, CollectResult>;
  @useResult
  $Res call(
      {@JsonKey(name: 'report_id') String reportId,
      @JsonKey(name: 'report_name') String reportName,
      List<Paper> papers,
      List<NewsItem> news,
      String? briefing,
      List<String> errors});
}

/// @nodoc
class _$CollectResultCopyWithImpl<$Res, $Val extends CollectResult>
    implements $CollectResultCopyWith<$Res> {
  _$CollectResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CollectResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reportId = null,
    Object? reportName = null,
    Object? papers = null,
    Object? news = null,
    Object? briefing = freezed,
    Object? errors = null,
  }) {
    return _then(_value.copyWith(
      reportId: null == reportId
          ? _value.reportId
          : reportId // ignore: cast_nullable_to_non_nullable
              as String,
      reportName: null == reportName
          ? _value.reportName
          : reportName // ignore: cast_nullable_to_non_nullable
              as String,
      papers: null == papers
          ? _value.papers
          : papers // ignore: cast_nullable_to_non_nullable
              as List<Paper>,
      news: null == news
          ? _value.news
          : news // ignore: cast_nullable_to_non_nullable
              as List<NewsItem>,
      briefing: freezed == briefing
          ? _value.briefing
          : briefing // ignore: cast_nullable_to_non_nullable
              as String?,
      errors: null == errors
          ? _value.errors
          : errors // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CollectResultImplCopyWith<$Res>
    implements $CollectResultCopyWith<$Res> {
  factory _$$CollectResultImplCopyWith(
          _$CollectResultImpl value, $Res Function(_$CollectResultImpl) then) =
      __$$CollectResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'report_id') String reportId,
      @JsonKey(name: 'report_name') String reportName,
      List<Paper> papers,
      List<NewsItem> news,
      String? briefing,
      List<String> errors});
}

/// @nodoc
class __$$CollectResultImplCopyWithImpl<$Res>
    extends _$CollectResultCopyWithImpl<$Res, _$CollectResultImpl>
    implements _$$CollectResultImplCopyWith<$Res> {
  __$$CollectResultImplCopyWithImpl(
      _$CollectResultImpl _value, $Res Function(_$CollectResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of CollectResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reportId = null,
    Object? reportName = null,
    Object? papers = null,
    Object? news = null,
    Object? briefing = freezed,
    Object? errors = null,
  }) {
    return _then(_$CollectResultImpl(
      reportId: null == reportId
          ? _value.reportId
          : reportId // ignore: cast_nullable_to_non_nullable
              as String,
      reportName: null == reportName
          ? _value.reportName
          : reportName // ignore: cast_nullable_to_non_nullable
              as String,
      papers: null == papers
          ? _value._papers
          : papers // ignore: cast_nullable_to_non_nullable
              as List<Paper>,
      news: null == news
          ? _value._news
          : news // ignore: cast_nullable_to_non_nullable
              as List<NewsItem>,
      briefing: freezed == briefing
          ? _value.briefing
          : briefing // ignore: cast_nullable_to_non_nullable
              as String?,
      errors: null == errors
          ? _value._errors
          : errors // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CollectResultImpl implements _CollectResult {
  const _$CollectResultImpl(
      {@JsonKey(name: 'report_id') required this.reportId,
      @JsonKey(name: 'report_name') required this.reportName,
      final List<Paper> papers = const [],
      final List<NewsItem> news = const [],
      this.briefing,
      final List<String> errors = const []})
      : _papers = papers,
        _news = news,
        _errors = errors;

  factory _$CollectResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$CollectResultImplFromJson(json);

  @override
  @JsonKey(name: 'report_id')
  final String reportId;
  @override
  @JsonKey(name: 'report_name')
  final String reportName;
  final List<Paper> _papers;
  @override
  @JsonKey()
  List<Paper> get papers {
    if (_papers is EqualUnmodifiableListView) return _papers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_papers);
  }

  final List<NewsItem> _news;
  @override
  @JsonKey()
  List<NewsItem> get news {
    if (_news is EqualUnmodifiableListView) return _news;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_news);
  }

  @override
  final String? briefing;
  final List<String> _errors;
  @override
  @JsonKey()
  List<String> get errors {
    if (_errors is EqualUnmodifiableListView) return _errors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_errors);
  }

  @override
  String toString() {
    return 'CollectResult(reportId: $reportId, reportName: $reportName, papers: $papers, news: $news, briefing: $briefing, errors: $errors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CollectResultImpl &&
            (identical(other.reportId, reportId) ||
                other.reportId == reportId) &&
            (identical(other.reportName, reportName) ||
                other.reportName == reportName) &&
            const DeepCollectionEquality().equals(other._papers, _papers) &&
            const DeepCollectionEquality().equals(other._news, _news) &&
            (identical(other.briefing, briefing) ||
                other.briefing == briefing) &&
            const DeepCollectionEquality().equals(other._errors, _errors));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      reportId,
      reportName,
      const DeepCollectionEquality().hash(_papers),
      const DeepCollectionEquality().hash(_news),
      briefing,
      const DeepCollectionEquality().hash(_errors));

  /// Create a copy of CollectResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CollectResultImplCopyWith<_$CollectResultImpl> get copyWith =>
      __$$CollectResultImplCopyWithImpl<_$CollectResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CollectResultImplToJson(
      this,
    );
  }
}

abstract class _CollectResult implements CollectResult {
  const factory _CollectResult(
      {@JsonKey(name: 'report_id') required final String reportId,
      @JsonKey(name: 'report_name') required final String reportName,
      final List<Paper> papers,
      final List<NewsItem> news,
      final String? briefing,
      final List<String> errors}) = _$CollectResultImpl;

  factory _CollectResult.fromJson(Map<String, dynamic> json) =
      _$CollectResultImpl.fromJson;

  @override
  @JsonKey(name: 'report_id')
  String get reportId;
  @override
  @JsonKey(name: 'report_name')
  String get reportName;
  @override
  List<Paper> get papers;
  @override
  List<NewsItem> get news;
  @override
  String? get briefing;
  @override
  List<String> get errors;

  /// Create a copy of CollectResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CollectResultImplCopyWith<_$CollectResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
