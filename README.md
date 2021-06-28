zig-webenc
==========

An implementation of https://encoding.spec.whatwg.org/ for the Zig programming language.

**Note**: I do not actually have anything hooked up that allows you to use `@import("webenc")` yet (maybe this
works with Gyro or Zigmod somehow but I'm not sure because I've never tried them).

Using the `TextEncoder` interface which is specified in the "Encoding" Living Standard
[here](https://encoding.spec.whatwg.org/#interface-textencoder).

```zig
pub const webenc = @import("webenc");
pub const TextEncoder = webenc.TextEncoder;

test "Encode 'Hello, World!' to UTF-8" {
    var encoder = try TextEncoder.init(testing.allocator, .{});
    defer encoder.deinit();

    try expectEqual(Encoding.Utf8, encoder.encoding);

    var hello_world_str = [_]u21{ 'H', 'e', 'l', 'l', 'o', ',', ' ', 'W', 'o', 'r', 'l', 'd', '!' };
    const hello_world_slice: []u21 = &hello_world_str;

    const encoded = try encoder.encode(hello_world_slice);
    defer testing.allocator.free(encoded);

    try expect(std.mem.eql(u8, "Hello, World!", encoded));
}
```

```zig
pub const webenc = @import("webenc");
pub const TextEncoder = webenc.TextEncoder;

test "Encode 'ə⚡𝅘𝅥𝅮'" {
    // U+0259 2 UTF-8 characters LATIN SMALL LETTER SCHWA
    // U+26A1 3 UTF-8 characters HIGH VOLTAGE SIGN
    // U+1D160 4 UTF-8 characters MUSICAL SYMBOL EIGHTH NOTE
    var encoder = try TextEncoder.init(testing.allocator, .{});
    defer encoder.deinit();

    try expectEqual(Encoding.Utf8, encoder.encoding);

    var schwa_lightning_note_str = [_]u21{ 0x0259, 0x26A1, 0x1D160 };
    const schwa_lightning_note_slice: []u21 = &schwa_lightning_note_str;

    const encoded = try encoder.encode(schwa_lightning_note_slice);
    defer testing.allocator.free(encoded);

    try expect(std.mem.eql(u8, "ə⚡𝅘𝅥𝅮", encoded));
}
```

Also yes this currently duplicates functionality that exists in the standard library at
[std.unicode](https://github.com/ziglang/zig/blob/master/lib/std/unicode.zig) but this is only a start.

I plan to implement as much of https://encoding.spec.whatwg.org/ as possible over time.

## [Terms defined by the specification](https://encoding.spec.whatwg.org/#index-defined-here)

**TODO**: Add examples of each one, listing which ones still need to be implemented, or which ones do not
apply to implementation (or maybe just delete those ones).

### [§3 Terminology](https://encoding.spec.whatwg.org/#terminology)

* convert
  * dfn for from I/O queue
  * dfn for to I/O queue
* End-of-queue
* I/O queue
  * definition of
* peek
* prepend
* push
* read
  * dfn for I/O queue

### [§4 Encodings](https://encoding.spec.whatwg.org/#encodings)

* encoding
  * definition of
* label
* name

#### [§4.1 Encoders and decoders](https://encoding.spec.whatwg.org/#encoders-and-decoders)

* continue
* decoder
  * definition of
* encoder
  * definition of
* error
* error mode
  * definition of
* finished
* handler
* process an item
* process a queue
* processing an item
* processing a queue

#### [§4.2 Names and labels](https://encoding.spec.whatwg.org/#names-and-labels)

* [get an encoding/getting an encoding](https://encoding.spec.whatwg.org/#concept-encoding-get)

```zig
pub const webenc = @import("webenc");
pub const Encoding = webenc.Encoding;
pub const getEncoding = webenc.getEncoding;

test "Get an encoding" {
    try expectEqual(Encoding.Utf8, try getEncoding("utf-8"));
}
```

**TODO**: Implement this for all encodings. Currently, it _only_ works for `utf-8`. Also it is sensitive to
leading/trailing space and case-sensitive, which is not consistent with the spec.

#### [§4.3 Output encodings](https://encoding.spec.whatwg.org/#output-encodings)

* get an output encoding

### [§5 Indexes](https://encoding.spec.whatwg.org/#indexes)

* index
* index Big5
* index Big5 pointer
* index code point
* index EUC-KR
* index gb18030
* index gb18030 ranges
* index gb18030 ranges code point
* index gb18030 ranges pointer
* index ISO-2022-JP katakana
* index jis0208
* index jis0212
* index pointer
* index Shift_JIS pointer

### [§6 Hooks for standards](https://encoding.spec.whatwg.org/#specification-hooks)

* UTF-8 decode
* UTF-8 decode without BOM
* UTF-8 decode without BOM or fail
* UTF-8 encode

#### [§6.1 Legacy hooks for standards](https://encoding.spec.whatwg.org/#legacy-hooks)

* BOM sniff
* decode
* encode
* encode or fail
* get an encoder
* getting an encoder

### [§7 API](https://encoding.spec.whatwg.org/#api)

#### [§7.1 Interface mixin TextDecoderCommon](https://encoding.spec.whatwg.org/#interface-mixin-textdecodercommon)

* BOM seen
* decoder
  * dfn for TextDecoderCommon
* encoding
  * attribute for TextDecoderCommon
  * dfn for TextDecoderCommon
* error mode
  * dfn for TextDecoderCommon
* fatal
  * attribute for TextDecoderCommon
* ignore BOM
* ignoreBOM
  * attribute for TextDecoderCommon
* I/O queue
  * dfn for TextDecoderCommon
* serialize I/O queue
* TextDecoderCommon

#### [§7.2 Interface TextDecoder](https://encoding.spec.whatwg.org/#interface-textdecoder)

* constructor()
  * constructor for TextDecoder
* constructor(label)
  * constructor for TextDecoder
* constructor(label, options)
  * constructor for TextDecoder
* decode()
* decode(input)
* decode(input, options)
* do not flush
* fatal
  * dict-member for TextDecoderOptions
* ignoreBOM
  * dict-member for TextDecoderOptions
* stream
* TextDecodeOptions
* TextDecoder
* TextDecoder()
* TextDecoder(label)
* TextDecoder(label, options)
* TextDecoderOptions

#### [§7.3 Interface mixin TextEncoderCommon](https://encoding.spec.whatwg.org/#interface-mixin-textencodercommon)

* encoding
  * attribute for TextEncoderCommon
* TextEncoderCommon

#### [§7.4 Interface TextEncoder](https://encoding.spec.whatwg.org/#interface-textencoder)

* constructor()
  * constructor for TextEncoder
* encode()
* encode(input)
* encodeInto(source, destination)
* read
  * dict-member for TextEncoderEncodeIntoResult
* TextEncoder
* TextEncoder()
* TextEncoderEncodeIntoResult
* written

#### [§7.5 Interface TextDecoderStream](https://encoding.spec.whatwg.org/#interface-textdecoderstream)

* constructor()
  * constructor for TextDecoderStream
* constructor(label)
  * constructor for TextDecoderStream
* constructor(label, options)
  * constructor for TextDecoderStream
* decode and enqueue a chunk
* flush and enqueue
* TextDecoderStream
* TextDecoderStream()
* TextDecoderStream(label)
* TextDecoderStream(label, options)

#### [§7.6 Interface TextEncoderStream](https://encoding.spec.whatwg.org/#interface-textencoderstream)

* constructor()
  * constructor for TextEncoderStream
* convert code unit to scalar value
* encode and enqueue a chunk
* encode and flush
* encoder
  * dfn for TextEncoderStream
* pending high surrogate
* TextEncoderStream
* TextEncoderStream()

### [§8 The encoding](https://encoding.spec.whatwg.org/#the-encoding)

* UTF-8

#### [§8.1 UTF-8](https://encoding.spec.whatwg.org/#utf-8)

* UTF-8 decoder

#### [§8.1.1 UTF-8 decoder](https://encoding.spec.whatwg.org/#utf-8-decoder)

* UTF-8 bytes needed
* UTF-8 bytes seen
* UTF-8 code point
* UTF-8 lower boundary
* UTF-8 upper boundary

#### [§8.1.2 UTF-8 encoder](https://encoding.spec.whatwg.org/#utf-8-encoder)

* UTF-8 encoder

### [§9 Legacy single-byte encodings](https://encoding.spec.whatwg.org/#legacy-single-byte-encodings)

* IBM866
* Index single-byte
* ISO-8859-10
* ISO-8859-13
* ISO-8859-14
* ISO-8859-15
* ISO-8859-16
* ISO-8859-2
* ISO-8859-3
* ISO-8859-4
* ISO-8859-5
* ISO-8859-6
* ISO-8859-7
* ISO-8859-8
* ISO-8859-8-I
* KOI8-R
* KOI8-U
* macintosh
* single-byte encoding
* windows-1250
* windows-1251
* windows-1252
* windows-1253
* windows-1254
* windows-1255
* windows-1256
* windows-1257
* windows-1258
* windows-874
* x-mac-cyrillic

#### [§9.1 single-byte decoder](https://encoding.spec.whatwg.org/#single-byte-decoder)

* single-byte decoder

#### [§9.2 single-byte encoder](https://encoding.spec.whatwg.org/#single-byte-encoder)

* single-byte encoder

### [§10 Legacy multi-byte Chinese (simplified) encodings](https://encoding.spec.whatwg.org/#legacy-multi-byte-chinese-(simplified)-encodings)

* GBK

#### [§10.1.1 GBK decoder](https://encoding.spec.whatwg.org/#gbk-decoder)

* GBK decoder

#### [§10.1.2 GBK encoder](https://encoding.spec.whatwg.org/#gbk-encoder)

* GBK encoder

#### [§10.2 gb18030](https://encoding.spec.whatwg.org/#gb18030)

* gb18030

#### [§10.2.1 gb18030 decoder](https://encoding.spec.whatwg.org/#gb18030-decoder)

* gb18030 decoder
* gb18030 first
* gb18030 second
* gb18030 third

#### [§10.2.2 gb18030 encoder](https://encoding.spec.whatwg.org/#gb18030-encoder)

* gb18030 encoder
* is GBK

### [§11 Legacy multi-byte Chinese (traditional) encodings](https://encoding.spec.whatwg.org/#legacy-multi-byte-chinese-(traditional)-encodings)

#### [§11.1 Big5](https://encoding.spec.whatwg.org/#big5)

* Big5

#### [§11.1.1 Big5 decoder](https://encoding.spec.whatwg.org/#big5-decoder)

* Big5 decoder
* Big5 lead

#### [§11.1.2 Big5 encoder](https://encoding.spec.whatwg.org/#big5-encoder)

* Big5 encoder

### [§12 Legacy multi-byte Japanese encodings](https://encoding.spec.whatwg.org/#legacy-multi-byte-japanese-encodings)

#### [§12.1 EUC-JP](https://encoding.spec.whatwg.org/#euc-jp)

* EUC-JP

#### [§12.1.1 EUC-JP decoder](https://encoding.spec.whatwg.org/#euc-jp-decoder)

* EUC-JP decoder
* EUC-JP jis0212
* EUC-JP lead

#### [§12.1.2 EUC-JP encoder](https://encoding.spec.whatwg.org/#euc-jp-encoder)

* EUC-JP encoder

#### [§12.2 ISO-2022-JP](https://encoding.spec.whatwg.org/#iso-2022-jp)

* ISO-2022-JP

#### [§12.2.1 ISO-2022-JP decoder](https://encoding.spec.whatwg.org/#iso-2022-jp-decoder)

* ISO-2022-JP decoder
* ISO-2022-JP decoder ASCII
* ISO-2022-JP decoder escape
* ISO-2022-JP decoder escape start
* ISO-2022-JP decoder katakana
* ISO-2022-JP decoder lead byte
* ISO-2022-JP decoder output state
* ISO-2022-JP decoder Roman
* ISO-2022-JP decoder state
* ISO-2022-JP decoder trail byte
* ISO-2022-JP lead
* ISO-2022-JP output

#### [§12.2.2 ISO-2022-JP encoder](https://encoding.spec.whatwg.org/#iso-2022-jp-encoder)

* ISO-2022-JP encoder
* ISO-2022-JP encoder ASCII
* ISO-2022-JP encoder jis0208
* ISO-2022-JP encoder Roman
* ISO-2022-JP encoder state

#### [§12.3 Shift_JIS](https://encoding.spec.whatwg.org/#shift_jis)

* Shift_JIS

#### [§12.3.1 Shift_JIS decoder](https://encoding.spec.whatwg.org/#shift_jis-decoder)

* Shift_JIS decoder
* Shift_JIS lead

#### [§12.3.2 Shift_JIS encoder](https://encoding.spec.whatwg.org/#shift_jis-encoder)

* Shift_JIS encoder

### [§13 Legacy multi-byte Korean encodings](https://encoding.spec.whatwg.org/#legacy-multi-byte-korean-encodings)

#### [§13.1 EUC-KR](https://encoding.spec.whatwg.org/#euc-kr)

* EUC-KR

#### [§13.1.1 EUC-KR decoder](https://encoding.spec.whatwg.org/#euc-kr-decoder)

* EUC-KR decoder
* EUC-KR lead

#### [§13.1.2 EUC-KR encoder](https://encoding.spec.whatwg.org/#euc-kr-encoder)

* EUC-KR encoder

### [§14 Legacy miscellaneous encodings](https://encoding.spec.whatwg.org/#legacy-miscellaneous-encodings)

#### [§14.1 replacement](https://encoding.spec.whatwg.org/#replacement)

* replacement

#### [§14.1.1 replacement decoder](https://encoding.spec.whatwg.org/#replacement-decoder)

* replacement decoder
* replacement error returned

#### [§14.2 Common infrastructure for UTF-16BE/LE](https://encoding.spec.whatwg.org/#common-infrastructure-for-utf-16be-and-utf-16le)

* UTF-16BE/LE

#### [§14.2.1 shared UTF-16 decoder](https://encoding.spec.whatwg.org/#shared-utf-16-decoder)

* shared UTF-16 decoder
* is UTF-16BE decoder
* UTF-16BE
* UTF-16 lead byte
* UTF-16 lead surrogate

#### [§14.3 UTF-16BE](https://encoding.spec.whatwg.org/#utf-16be)

#### [§14.3.1 UTF-16BE decoder](https://encoding.spec.whatwg.org/#utf-16be-decoder)

* UTF-16BE decoder

#### [§14.4 UTF-16LE](https://encoding.spec.whatwg.org/#utf-16le)

* UTF-16LE

#### [§14.4.1 UTF-16LE decoder](https://encoding.spec.whatwg.org/#utf-16le-decoder)

* UTF-16LE decoder

#### [§14.5 x-user-defined](https://encoding.spec.whatwg.org/#x-user-defined)

* x-user-defined

#### [§14.5.1 x-user-defined decoder](https://encoding.spec.whatwg.org/#x-user-defined-decoder)

* x-user-defined decoder

#### [§14.5.2 x-user-defined encoder](https://encoding.spec.whatwg.org/#x-user-defined-encoder)

* x-user-defined encoder
