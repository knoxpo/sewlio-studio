// Raw HarfBuzz C API bindings (ADR-041).
//
// ignore_for_file: library_private_types_in_public_api
//
// ponytail: this FFI surface is written against the HarfBuzz ≥ 7 C ABI
// but is UNVERIFIED in CI until a native `libharfbuzz` is bundled per
// desktop platform. It is loaded lazily: [openHarfBuzz] returns null
// when the library is absent, and every caller falls back to the pure
// Dart glyf parser. Struct layouts below mirror harfbuzz's public
// headers; if a future HarfBuzz changes them this file is the single
// place to adjust. Upgrade path: bundle the lib + enable the gated
// smoke tests in test/shaping_smoke_test.dart.
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

// ------------------------------------------------------------- opaque types
final class HbBlob extends Opaque {}

final class HbFace extends Opaque {}

final class HbFont extends Opaque {}

final class HbBuffer extends Opaque {}

final class HbDrawFuncs extends Opaque {}

final class HbDrawState extends Opaque {}

// ----------------------------------------------------------------- structs
final class HbGlyphInfo extends Struct {
  @Uint32()
  external int codepoint;
  @Uint32()
  external int mask;
  @Uint32()
  external int cluster;
  @Uint32()
  external int var1;
  @Uint32()
  external int var2;
}

final class HbGlyphPosition extends Struct {
  @Int32()
  external int xAdvance;
  @Int32()
  external int yAdvance;
  @Int32()
  external int xOffset;
  @Int32()
  external int yOffset;
  @Uint32()
  external int varField;
}

final class HbVariation extends Struct {
  @Uint32()
  external int tag;
  @Float()
  external double value;
}

final class HbFeature extends Struct {
  @Uint32()
  external int tag;
  @Uint32()
  external int value;
  @Uint32()
  external int start;
  @Uint32()
  external int end;
}

final class HbOtVarAxisInfo extends Struct {
  @Uint32()
  external int axisIndex;
  @Uint32()
  external int tag;
  @Uint32()
  external int nameId;
  @Uint32()
  external int flags;
  @Float()
  external double minValue;
  @Float()
  external double defaultValue;
  @Float()
  external double maxValue;
  @Uint32()
  external int reserved;
}

// ------------------------------------------------------- native signatures
typedef _BlobCreateN = Pointer<HbBlob> Function(
    Pointer<Uint8>, Uint32, Int32, Pointer<Void>, Pointer<Void>);
typedef _BlobCreateD = Pointer<HbBlob> Function(
    Pointer<Uint8>, int, int, Pointer<Void>, Pointer<Void>);

typedef _FaceCreateN = Pointer<HbFace> Function(Pointer<HbBlob>, Uint32);
typedef _FaceCreateD = Pointer<HbFace> Function(Pointer<HbBlob>, int);

typedef _FaceUpemN = Uint32 Function(Pointer<HbFace>);
typedef _FaceUpemD = int Function(Pointer<HbFace>);

typedef _FontCreateN = Pointer<HbFont> Function(Pointer<HbFace>);
typedef _FontCreateD = Pointer<HbFont> Function(Pointer<HbFace>);

typedef _FontSetVariationsN = Void Function(
    Pointer<HbFont>, Pointer<HbVariation>, Uint32);
typedef _FontSetVariationsD = void Function(
    Pointer<HbFont>, Pointer<HbVariation>, int);

typedef _BufferCreateN = Pointer<HbBuffer> Function();
typedef _BufferCreateD = Pointer<HbBuffer> Function();

typedef _BufferAddUtf8N = Void Function(
    Pointer<HbBuffer>, Pointer<Utf8>, Int32, Uint32, Int32);
typedef _BufferAddUtf8D = void Function(
    Pointer<HbBuffer>, Pointer<Utf8>, int, int, int);

typedef _BufferGuessN = Void Function(Pointer<HbBuffer>);
typedef _BufferGuessD = void Function(Pointer<HbBuffer>);

typedef _ShapeN = Void Function(
    Pointer<HbFont>, Pointer<HbBuffer>, Pointer<HbFeature>, Uint32);
typedef _ShapeD = void Function(
    Pointer<HbFont>, Pointer<HbBuffer>, Pointer<HbFeature>, int);

typedef _BufferGetInfosN = Pointer<HbGlyphInfo> Function(
    Pointer<HbBuffer>, Pointer<Uint32>);
typedef _BufferGetInfosD = Pointer<HbGlyphInfo> Function(
    Pointer<HbBuffer>, Pointer<Uint32>);

typedef _BufferGetPosN = Pointer<HbGlyphPosition> Function(
    Pointer<HbBuffer>, Pointer<Uint32>);
typedef _BufferGetPosD = Pointer<HbGlyphPosition> Function(
    Pointer<HbBuffer>, Pointer<Uint32>);

typedef _DestroyN = Void Function(Pointer<Void>);
typedef _DestroyD = void Function(Pointer<Void>);

typedef _DrawFuncsCreateN = Pointer<HbDrawFuncs> Function();
typedef _DrawFuncsCreateD = Pointer<HbDrawFuncs> Function();

// Draw callback ABI (HarfBuzz ≥ 7): (dfuncs, draw_data, state, ...coords, user_data)
typedef HbMoveToNative = Void Function(Pointer<HbDrawFuncs>, Pointer<Void>,
    Pointer<HbDrawState>, Float, Float, Pointer<Void>);
typedef HbLineToNative = Void Function(Pointer<HbDrawFuncs>, Pointer<Void>,
    Pointer<HbDrawState>, Float, Float, Pointer<Void>);
typedef HbQuadToNative = Void Function(Pointer<HbDrawFuncs>, Pointer<Void>,
    Pointer<HbDrawState>, Float, Float, Float, Float, Pointer<Void>);
typedef HbCubicToNative = Void Function(
    Pointer<HbDrawFuncs>,
    Pointer<Void>,
    Pointer<HbDrawState>,
    Float,
    Float,
    Float,
    Float,
    Float,
    Float,
    Pointer<Void>);
typedef HbCloseNative = Void Function(
    Pointer<HbDrawFuncs>, Pointer<Void>, Pointer<HbDrawState>, Pointer<Void>);

typedef _SetMoveToN = Void Function(Pointer<HbDrawFuncs>,
    Pointer<NativeFunction<HbMoveToNative>>, Pointer<Void>, Pointer<Void>);
typedef _SetMoveToD = void Function(Pointer<HbDrawFuncs>,
    Pointer<NativeFunction<HbMoveToNative>>, Pointer<Void>, Pointer<Void>);
typedef _SetLineToN = Void Function(Pointer<HbDrawFuncs>,
    Pointer<NativeFunction<HbLineToNative>>, Pointer<Void>, Pointer<Void>);
typedef _SetLineToD = void Function(Pointer<HbDrawFuncs>,
    Pointer<NativeFunction<HbLineToNative>>, Pointer<Void>, Pointer<Void>);
typedef _SetQuadToN = Void Function(Pointer<HbDrawFuncs>,
    Pointer<NativeFunction<HbQuadToNative>>, Pointer<Void>, Pointer<Void>);
typedef _SetQuadToD = void Function(Pointer<HbDrawFuncs>,
    Pointer<NativeFunction<HbQuadToNative>>, Pointer<Void>, Pointer<Void>);
typedef _SetCubicToN = Void Function(Pointer<HbDrawFuncs>,
    Pointer<NativeFunction<HbCubicToNative>>, Pointer<Void>, Pointer<Void>);
typedef _SetCubicToD = void Function(Pointer<HbDrawFuncs>,
    Pointer<NativeFunction<HbCubicToNative>>, Pointer<Void>, Pointer<Void>);
typedef _SetCloseN = Void Function(Pointer<HbDrawFuncs>,
    Pointer<NativeFunction<HbCloseNative>>, Pointer<Void>, Pointer<Void>);
typedef _SetCloseD = void Function(Pointer<HbDrawFuncs>,
    Pointer<NativeFunction<HbCloseNative>>, Pointer<Void>, Pointer<Void>);

typedef _FontDrawGlyphN = Void Function(
    Pointer<HbFont>, Uint32, Pointer<HbDrawFuncs>, Pointer<Void>);
typedef _FontDrawGlyphD = void Function(
    Pointer<HbFont>, int, Pointer<HbDrawFuncs>, Pointer<Void>);

typedef _VarAxisInfosN = Uint32 Function(
    Pointer<HbFace>, Uint32, Pointer<Uint32>, Pointer<HbOtVarAxisInfo>);
typedef _VarAxisInfosD = int Function(
    Pointer<HbFace>, int, Pointer<Uint32>, Pointer<HbOtVarAxisInfo>);

typedef _FeatureTagsN = Uint32 Function(
    Pointer<HbFace>, Uint32, Uint32, Pointer<Uint32>, Pointer<Uint32>);
typedef _FeatureTagsD = int Function(
    Pointer<HbFace>, int, int, Pointer<Uint32>, Pointer<Uint32>);

/// Bound HarfBuzz entry points. Constructed only when the shared library
/// loads; see [openHarfBuzz].
final class HarfBuzzLib {
  HarfBuzzLib._(DynamicLibrary lib)
      : blobCreate =
            lib.lookupFunction<_BlobCreateN, _BlobCreateD>('hb_blob_create'),
        blobDestroy =
            lib.lookupFunction<_DestroyN, _DestroyD>('hb_blob_destroy'),
        faceCreate =
            lib.lookupFunction<_FaceCreateN, _FaceCreateD>('hb_face_create'),
        faceDestroy =
            lib.lookupFunction<_DestroyN, _DestroyD>('hb_face_destroy'),
        faceUpem =
            lib.lookupFunction<_FaceUpemN, _FaceUpemD>('hb_face_get_upem'),
        fontCreate =
            lib.lookupFunction<_FontCreateN, _FontCreateD>('hb_font_create'),
        fontDestroy =
            lib.lookupFunction<_DestroyN, _DestroyD>('hb_font_destroy'),
        fontSetVariations =
            lib.lookupFunction<_FontSetVariationsN, _FontSetVariationsD>(
                'hb_font_set_variations'),
        bufferCreate = lib
            .lookupFunction<_BufferCreateN, _BufferCreateD>('hb_buffer_create'),
        bufferDestroy =
            lib.lookupFunction<_DestroyN, _DestroyD>('hb_buffer_destroy'),
        bufferAddUtf8 = lib.lookupFunction<_BufferAddUtf8N, _BufferAddUtf8D>(
            'hb_buffer_add_utf8'),
        bufferGuess = lib.lookupFunction<_BufferGuessN, _BufferGuessD>(
            'hb_buffer_guess_segment_properties'),
        shape = lib.lookupFunction<_ShapeN, _ShapeD>('hb_shape'),
        bufferGetInfos = lib.lookupFunction<_BufferGetInfosN, _BufferGetInfosD>(
            'hb_buffer_get_glyph_infos'),
        bufferGetPositions = lib.lookupFunction<_BufferGetPosN, _BufferGetPosD>(
            'hb_buffer_get_glyph_positions'),
        drawFuncsCreate =
            lib.lookupFunction<_DrawFuncsCreateN, _DrawFuncsCreateD>(
                'hb_draw_funcs_create'),
        setMoveTo = lib.lookupFunction<_SetMoveToN, _SetMoveToD>(
            'hb_draw_funcs_set_move_to_func'),
        setLineTo = lib.lookupFunction<_SetLineToN, _SetLineToD>(
            'hb_draw_funcs_set_line_to_func'),
        setQuadTo = lib.lookupFunction<_SetQuadToN, _SetQuadToD>(
            'hb_draw_funcs_set_quadratic_to_func'),
        setCubicTo = lib.lookupFunction<_SetCubicToN, _SetCubicToD>(
            'hb_draw_funcs_set_cubic_to_func'),
        setClose = lib.lookupFunction<_SetCloseN, _SetCloseD>(
            'hb_draw_funcs_set_close_path_func'),
        fontDrawGlyph = lib.lookupFunction<_FontDrawGlyphN, _FontDrawGlyphD>(
            'hb_font_draw_glyph'),
        varAxisInfos = lib.lookupFunction<_VarAxisInfosN, _VarAxisInfosD>(
            'hb_ot_var_get_axis_infos'),
        featureTags = lib.lookupFunction<_FeatureTagsN, _FeatureTagsD>(
            'hb_ot_layout_table_get_feature_tags');

  final _BlobCreateD blobCreate;
  final _DestroyD blobDestroy;
  final _FaceCreateD faceCreate;
  final _DestroyD faceDestroy;
  final _FaceUpemD faceUpem;
  final _FontCreateD fontCreate;
  final _DestroyD fontDestroy;
  final _FontSetVariationsD fontSetVariations;
  final _BufferCreateD bufferCreate;
  final _DestroyD bufferDestroy;
  final _BufferAddUtf8D bufferAddUtf8;
  final _BufferGuessD bufferGuess;
  final _ShapeD shape;
  final _BufferGetInfosD bufferGetInfos;
  final _BufferGetPosD bufferGetPositions;
  final _DrawFuncsCreateD drawFuncsCreate;
  final _SetMoveToD setMoveTo;
  final _SetLineToD setLineTo;
  final _SetQuadToD setQuadTo;
  final _SetCubicToD setCubicTo;
  final _SetCloseD setClose;
  final _FontDrawGlyphD fontDrawGlyph;
  final _VarAxisInfosD varAxisInfos;
  final _FeatureTagsD featureTags;
}

/// Candidate shared-library names per platform.
List<String> _candidateNames() {
  if (Platform.isMacOS) {
    return ['libharfbuzz.dylib', 'libharfbuzz.0.dylib'];
  }
  if (Platform.isWindows) {
    return ['harfbuzz.dll', 'libharfbuzz-0.dll'];
  }
  return ['libharfbuzz.so.0', 'libharfbuzz.so'];
}

/// Opens HarfBuzz, or returns null when it cannot be loaded (web has no
/// FFI; desktop without the lib bundled falls back to the glyf parser).
HarfBuzzLib? openHarfBuzz() {
  for (final name in _candidateNames()) {
    try {
      return HarfBuzzLib._(DynamicLibrary.open(name));
    } on ArgumentError {
      continue;
    } on Object {
      continue;
    }
  }
  return null;
}

/// Packs a 4-char OpenType/axis tag into HarfBuzz's big-endian tag int.
int hbTag(String tag) {
  final padded = tag.padRight(4).substring(0, 4);
  return (padded.codeUnitAt(0) << 24) |
      (padded.codeUnitAt(1) << 16) |
      (padded.codeUnitAt(2) << 8) |
      padded.codeUnitAt(3);
}

/// Unpacks a HarfBuzz tag int back to its 4-char string.
String tagString(int tag) => String.fromCharCodes([
      (tag >> 24) & 0xff,
      (tag >> 16) & 0xff,
      (tag >> 8) & 0xff,
      tag & 0xff,
    ]).trimRight();
