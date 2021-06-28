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

# Get an encoding (https://encoding.spec.whatwg.org/#concept-encoding-get)

```zig
test "Get an encoding" {
    try expectEqual(Encoding.Utf8, try getEncoding("utf-8"));
}
```

Also yes this currently duplicates functionality that exists in the standard library at [std.unicode](https://github.com/ziglang/zig/blob/master/lib/std/unicode.zig) but this is only a start.

I plan to implement as much of https://encoding.spec.whatwg.org/ as possible over time.
