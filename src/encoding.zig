const std = @import("std");
const testing = std.testing;
const expectEqual = testing.expectEqual;
const Allocator = std.mem.Allocator;

const EncoderHandler = @import("encode.zig").EncoderHandler;

const WebEncError = @import("error.zig").WebEncError;

pub const Encoding = enum {
    Utf8,
    Ibm866,
    Iso8859_2,
    Iso8859_3,
    Iso8859_4,
    Iso8859_5,
    Iso8859_6,
    Iso8859_7,
    Iso8859_8,
    Iso8859_8I,
    Iso8859_10,
    Iso8859_13,
    Iso8859_14,
    Iso8859_15,
    Iso8859_16,
    Koi8R,
    Koi8U,
    Macintosh,
    Windows874,
    Windows1250,
    Windows1251,
    Windows1252,
    Windows1253,
    Windows1254,
    Windows1255,
    Windows1256,
    Windows1257,
    Windows1258,
    XMacCyrillic,
    Gbk,
    Gb18030,
    Big5,
    EucJp,
    Iso2022Jp,
    ShiftJis,
    EucKr,
    Replacement,
    Utf16Be,
    Utf16Le,
    XUserDefined,
};

const Utf8EncoderHandler = @import("encoding/utf8.zig").Utf8EncoderHandler;

// https://encoding.spec.whatwg.org/#concept-encoding-get
pub fn getEncoding(label: []const u8) !Encoding {
    if (std.mem.eql(u8, "utf-8", label)) return .Utf8;
    return error.EncodingNotFound;
}

pub fn getEncoderHandler(allocator: *Allocator, encoding: Encoding) !*EncoderHandler {
    switch (encoding) {
        .Utf8 => {
            var utf8EncoderHandler = try Utf8EncoderHandler.init(allocator);
            return &utf8EncoderHandler.handler;
        },
        else => {
            return WebEncError.RangeError;
        },
    }
}

test "Get an encoding" {
    try expectEqual(Encoding.Utf8, try getEncoding("utf-8"));
}
