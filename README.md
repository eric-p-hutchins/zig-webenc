zig-webenc
==========

An implementation of https://encoding.spec.whatwg.org/ for the Zig programming language.

**Note**: I do not actually have anything hooked up that allows you to use `@import("webenc")` yet (maybe this works with Gyro or Zigmod somehow but I'm not sure because I've never tried them).

Using the `TextEncoder` interface which is specified in the "Encoding" Living Standard [here](https://encoding.spec.whatwg.org/#interface-textencoder).

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

#### Get an encoding (https://encoding.spec.whatwg.org/#concept-encoding-get)

```zig
test "Get an encoding" {
    try expectEqual(Encoding.Utf8, try getEncoding("utf-8"));
}
```

Also yes this currently duplicates functionality that exists in the standard library at
[std.unicode](https://github.com/ziglang/zig/blob/master/lib/std/unicode.zig) but this is only a start.

I plan to implement as much of https://encoding.spec.whatwg.org/ as possible over time.

## Terms defined by the specification

**TODO**: Sort the rest of these in section order and make examples of each, listing which ones still need to
be implemented, or which ones do not apply to implementation.

### §3

* convert
  * dfn for from I/O queue, in §3
  * dfn for to I/O queue, in §3
* End-of-queue, in §3
* I/O queue
  * definition of, in §3
* peek, in §3
* prepend, in §3
* push, in §3
* read
  * dfn for I/O queue, in §3

### §4

* encoding
  * definition of, in §4
* label, in §4
* name, in §4

#### §4.1

* continue, in §4.1
* decoder
  * definition of, in §4.1
* encoder
  * definition of, in §4.1
* error, in §4.1
* error mode
  * definition of, in §4.1
* finished, in §4.1
* handler, in §4.1
* process an item, in §4.1
* process a queue, in §4.1
* processing an item, in §4.1
* processing a queue, in §4.1

#### §4.2

* get an encoding, in §4.2
* getting an encoding, in §4.2

#### §4.3

* get an output encoding, in §4.3

### Unsorted

* Big5, in §11
* Big5 decoder, in §11.1
* Big5 encoder, in §11.1.1
* Big5 lead, in §11.1.1
* BOM seen, in §7.1
* BOM sniff, in §6.1
* constructor()
  * constructor for TextDecoder, in §7.2
  * constructor for TextDecoderStream, in §7.5
  * constructor for TextEncoder, in §7.4
  * constructor for TextEncoderStream, in §7.6
* constructor(label)
  * constructor for TextDecoder, in §7.2
  * constructor for TextDecoderStream, in §7.5
* constructor(label, options)
  * constructor for TextDecoder, in §7.2
  * constructor for TextDecoderStream, in §7.5
* convert code unit to scalar value, in §7.6
* decode, in §6.1
* decode(), in §7.2
* decode and enqueue a chunk, in §7.5
* decode(input), in §7.2
* decode(input, options), in §7.2
* decoder
  * dfn for TextDecoderCommon, in §7.1
* do not flush, in §7.2
* encode, in §6.1
* encode(), in §7.4
* encode and enqueue a chunk, in §7.6
* encode and flush, in §7.6
* encode(input), in §7.4
* encodeInto(source, destination), in §7.4
* encode or fail, in §6.1
* encoder
  * dfn for TextEncoderStream, in §7.6
* encoding
  * attribute for TextDecoderCommon, in §7.1
  * attribute for TextEncoderCommon, in §7.3
  * dfn for TextDecoderCommon, in §7.1
* error mode
  * dfn for TextDecoderCommon, in §7.1
* EUC-JP, in §12
* EUC-JP decoder, in §12.1
* EUC-JP encoder, in §12.1.1
* EUC-JP jis0212, in §12.1.1
* EUC-JP lead, in §12.1.1
* EUC-KR, in §13
* EUC-KR decoder, in §13.1
* EUC-KR encoder, in §13.1.1
* EUC-KR lead, in §13.1.1
* fatal
  * attribute for TextDecoderCommon, in §7.1
  * dict-member for TextDecoderOptions, in §7.2
* flush and enqueue, in §7.5
* gb18030, in §10.1.2
* gb18030 decoder, in §10.2
* gb18030 encoder, in §10.2.1
* gb18030 first, in §10.2.1
* gb18030 second, in §10.2.1
* gb18030 third, in §10.2.1
* GBK, in §10
* GBK decoder, in §10.1
* GBK encoder, in §10.1.1
* get an encoder, in §6.1
* getting an encoder, in §6.1
* IBM866, in §9
* ignore BOM, in §7.1
* ignoreBOM
  * attribute for TextDecoderCommon, in §7.1
  * dict-member for TextDecoderOptions, in §7.2
* index, in §5
* index Big5, in §5
* index Big5 pointer, in §5
* index code point, in §5
* index EUC-KR, in §5
* index gb18030, in §5
* index gb18030 ranges, in §5
* index gb18030 ranges code point, in §5
* index gb18030 ranges pointer, in §5
* index ISO-2022-JP katakana, in §5
* index jis0208, in §5
* index jis0212, in §5
* index pointer, in §5
* index Shift_JIS pointer, in §5
* Index single-byte, in §9
* I/O queue
  * dfn for TextDecoderCommon, in §7.1
* is GBK, in §10.2.2
* ISO-2022-JP, in §12.1.2
* ISO-2022-JP decoder, in §12.2
* ISO-2022-JP decoder ASCII, in §12.2.1
* ISO-2022-JP decoder escape, in §12.2.1
* ISO-2022-JP decoder escape start, in §12.2.1
* ISO-2022-JP decoder katakana, in §12.2.1
* ISO-2022-JP decoder lead byte, in §12.2.1
* ISO-2022-JP decoder output state, in §12.2.1
* ISO-2022-JP decoder Roman, in §12.2.1
* ISO-2022-JP decoder state, in §12.2.1
* ISO-2022-JP decoder trail byte, in §12.2.1
* ISO-2022-JP encoder, in §12.2.1
* ISO-2022-JP encoder ASCII, in §12.2.2
* ISO-2022-JP encoder jis0208, in §12.2.2
* ISO-2022-JP encoder Roman, in §12.2.2
* ISO-2022-JP encoder state, in §12.2.2
* ISO-2022-JP lead, in §12.2.1
* ISO-2022-JP output, in §12.2.1
* ISO-8859-10, in §9
* ISO-8859-13, in §9
* ISO-8859-14, in §9
* ISO-8859-15, in §9
* ISO-8859-16, in §9
* ISO-8859-2, in §9
* ISO-8859-3, in §9
* ISO-8859-4, in §9
* ISO-8859-5, in §9
* ISO-8859-6, in §9
* ISO-8859-7, in §9
* ISO-8859-8, in §9
* ISO-8859-8-I, in §9
* is UTF-16BE decoder, in §14.2.1
* KOI8-R, in §9
* KOI8-U, in §9
* macintosh, in §9
* pending high surrogate, in §7.6
* read
  * dict-member for TextEncoderEncodeIntoResult, in §7.4
* replacement, in §14
* replacement decoder, in §14.1
* replacement error returned, in §14.1.1
* serialize I/O queue, in §7.1
* shared UTF-16 decoder, in §14.2
* Shift_JIS, in §12.2.2
* Shift_JIS decoder, in §12.3
* Shift_JIS encoder, in §12.3.1
* Shift_JIS lead, in §12.3.1
* single-byte decoder, in §9
* single-byte encoder, in §9.1
* single-byte encoding, in §9
* stream, in §7.2
* TextDecodeOptions, in §7.2
* TextDecoder, in §7.2
* TextDecoder(), in §7.2
* TextDecoderCommon, in §7.1
* TextDecoder(label), in §7.2
* TextDecoder(label, options), in §7.2
* TextDecoderOptions, in §7.2
* TextDecoderStream, in §7.5
* TextDecoderStream(), in §7.5
* TextDecoderStream(label), in §7.5
* TextDecoderStream(label, options), in §7.5
* TextEncoder, in §7.4
* TextEncoder(), in §7.4
* TextEncoderCommon, in §7.3
* TextEncoderEncodeIntoResult, in §7.4
* TextEncoderStream, in §7.6
* TextEncoderStream(), in §7.6
* UTF-16BE, in §14.2.1
* UTF-16BE decoder, in §14.3
* UTF-16BE/LE, in §14.2
* UTF-16LE, in §14.3.1
* UTF-16 lead byte, in §14.2.1
* UTF-16 lead surrogate, in §14.2.1
* UTF-16LE decoder, in §14.4
* UTF-8, in §8
* UTF-8 bytes needed, in §8.1.1
* UTF-8 bytes seen, in §8.1.1
* UTF-8 code point, in §8.1.1
* UTF-8 decode, in §6
* UTF-8 decoder, in §8.1
* UTF-8 decode without BOM, in §6
* UTF-8 decode without BOM or fail, in §6
* UTF-8 encode, in §6
* UTF-8 encoder, in §8.1.1
* UTF-8 lower boundary, in §8.1.1
* UTF-8 upper boundary, in §8.1.1
* windows-1250, in §9
* windows-1251, in §9
* windows-1252, in §9
* windows-1253, in §9
* windows-1254, in §9
* windows-1255, in §9
* windows-1256, in §9
* windows-1257, in §9
* windows-1258, in §9
* windows-874, in §9
* written, in §7.4
* x-mac-cyrillic, in §9
* x-user-defined, in §14.4.1
* x-user-defined decoder, in §14.5
* x-user-defined encoder, in §14.5.1
