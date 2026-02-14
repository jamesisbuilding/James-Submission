// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'image_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ImageModel {

 String get uid; String get title; String get description; bool get isFavourite; String get url; List<Color> get colorPalette; String get localPath; Uint8List? get byteList; String get pixelSignature;
/// Create a copy of ImageModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageModelCopyWith<ImageModel> get copyWith => _$ImageModelCopyWithImpl<ImageModel>(this as ImageModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.isFavourite, isFavourite) || other.isFavourite == isFavourite)&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other.colorPalette, colorPalette)&&(identical(other.localPath, localPath) || other.localPath == localPath)&&const DeepCollectionEquality().equals(other.byteList, byteList)&&(identical(other.pixelSignature, pixelSignature) || other.pixelSignature == pixelSignature));
}


@override
int get hashCode => Object.hash(runtimeType,uid,title,description,isFavourite,url,const DeepCollectionEquality().hash(colorPalette),localPath,const DeepCollectionEquality().hash(byteList),pixelSignature);

@override
String toString() {
  return 'ImageModel(uid: $uid, title: $title, description: $description, isFavourite: $isFavourite, url: $url, colorPalette: $colorPalette, localPath: $localPath, byteList: $byteList, pixelSignature: $pixelSignature)';
}


}

/// @nodoc
abstract mixin class $ImageModelCopyWith<$Res>  {
  factory $ImageModelCopyWith(ImageModel value, $Res Function(ImageModel) _then) = _$ImageModelCopyWithImpl;
@useResult
$Res call({
 String uid, String title, String description, bool isFavourite, String url, List<Color> colorPalette, String localPath, Uint8List? byteList, String pixelSignature
});




}
/// @nodoc
class _$ImageModelCopyWithImpl<$Res>
    implements $ImageModelCopyWith<$Res> {
  _$ImageModelCopyWithImpl(this._self, this._then);

  final ImageModel _self;
  final $Res Function(ImageModel) _then;

/// Create a copy of ImageModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? title = null,Object? description = null,Object? isFavourite = null,Object? url = null,Object? colorPalette = null,Object? localPath = null,Object? byteList = freezed,Object? pixelSignature = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isFavourite: null == isFavourite ? _self.isFavourite : isFavourite // ignore: cast_nullable_to_non_nullable
as bool,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,colorPalette: null == colorPalette ? _self.colorPalette : colorPalette // ignore: cast_nullable_to_non_nullable
as List<Color>,localPath: null == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String,byteList: freezed == byteList ? _self.byteList : byteList // ignore: cast_nullable_to_non_nullable
as Uint8List?,pixelSignature: null == pixelSignature ? _self.pixelSignature : pixelSignature // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ImageModel].
extension ImageModelPatterns on ImageModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImageModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImageModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImageModel value)  $default,){
final _that = this;
switch (_that) {
case _ImageModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImageModel value)?  $default,){
final _that = this;
switch (_that) {
case _ImageModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String title,  String description,  bool isFavourite,  String url,  List<Color> colorPalette,  String localPath,  Uint8List? byteList,  String pixelSignature)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImageModel() when $default != null:
return $default(_that.uid,_that.title,_that.description,_that.isFavourite,_that.url,_that.colorPalette,_that.localPath,_that.byteList,_that.pixelSignature);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String title,  String description,  bool isFavourite,  String url,  List<Color> colorPalette,  String localPath,  Uint8List? byteList,  String pixelSignature)  $default,) {final _that = this;
switch (_that) {
case _ImageModel():
return $default(_that.uid,_that.title,_that.description,_that.isFavourite,_that.url,_that.colorPalette,_that.localPath,_that.byteList,_that.pixelSignature);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String title,  String description,  bool isFavourite,  String url,  List<Color> colorPalette,  String localPath,  Uint8List? byteList,  String pixelSignature)?  $default,) {final _that = this;
switch (_that) {
case _ImageModel() when $default != null:
return $default(_that.uid,_that.title,_that.description,_that.isFavourite,_that.url,_that.colorPalette,_that.localPath,_that.byteList,_that.pixelSignature);case _:
  return null;

}
}

}

/// @nodoc


class _ImageModel extends ImageModel {
  const _ImageModel({required this.uid, required this.title, required this.description, required this.isFavourite, required this.url, required final  List<Color> colorPalette, required this.localPath, this.byteList, required this.pixelSignature}): _colorPalette = colorPalette,super._();
  

@override final  String uid;
@override final  String title;
@override final  String description;
@override final  bool isFavourite;
@override final  String url;
 final  List<Color> _colorPalette;
@override List<Color> get colorPalette {
  if (_colorPalette is EqualUnmodifiableListView) return _colorPalette;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_colorPalette);
}

@override final  String localPath;
@override final  Uint8List? byteList;
@override final  String pixelSignature;

/// Create a copy of ImageModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImageModelCopyWith<_ImageModel> get copyWith => __$ImageModelCopyWithImpl<_ImageModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImageModel&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.isFavourite, isFavourite) || other.isFavourite == isFavourite)&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other._colorPalette, _colorPalette)&&(identical(other.localPath, localPath) || other.localPath == localPath)&&const DeepCollectionEquality().equals(other.byteList, byteList)&&(identical(other.pixelSignature, pixelSignature) || other.pixelSignature == pixelSignature));
}


@override
int get hashCode => Object.hash(runtimeType,uid,title,description,isFavourite,url,const DeepCollectionEquality().hash(_colorPalette),localPath,const DeepCollectionEquality().hash(byteList),pixelSignature);

@override
String toString() {
  return 'ImageModel(uid: $uid, title: $title, description: $description, isFavourite: $isFavourite, url: $url, colorPalette: $colorPalette, localPath: $localPath, byteList: $byteList, pixelSignature: $pixelSignature)';
}


}

/// @nodoc
abstract mixin class _$ImageModelCopyWith<$Res> implements $ImageModelCopyWith<$Res> {
  factory _$ImageModelCopyWith(_ImageModel value, $Res Function(_ImageModel) _then) = __$ImageModelCopyWithImpl;
@override @useResult
$Res call({
 String uid, String title, String description, bool isFavourite, String url, List<Color> colorPalette, String localPath, Uint8List? byteList, String pixelSignature
});




}
/// @nodoc
class __$ImageModelCopyWithImpl<$Res>
    implements _$ImageModelCopyWith<$Res> {
  __$ImageModelCopyWithImpl(this._self, this._then);

  final _ImageModel _self;
  final $Res Function(_ImageModel) _then;

/// Create a copy of ImageModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? title = null,Object? description = null,Object? isFavourite = null,Object? url = null,Object? colorPalette = null,Object? localPath = null,Object? byteList = freezed,Object? pixelSignature = null,}) {
  return _then(_ImageModel(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isFavourite: null == isFavourite ? _self.isFavourite : isFavourite // ignore: cast_nullable_to_non_nullable
as bool,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,colorPalette: null == colorPalette ? _self._colorPalette : colorPalette // ignore: cast_nullable_to_non_nullable
as List<Color>,localPath: null == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String,byteList: freezed == byteList ? _self.byteList : byteList // ignore: cast_nullable_to_non_nullable
as Uint8List?,pixelSignature: null == pixelSignature ? _self.pixelSignature : pixelSignature // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
