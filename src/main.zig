const std = @import("std");
const testing = std.testing;

pub const WebEncError = @import("error.zig").WebEncError;

pub const TextDecoder = @import("decode.zig").TextDecoder;
pub const TextDecoderStream = @import("decode.zig").TextDecoderStream;

pub const TextEncoder = @import("encode.zig").TextEncoder;
pub const TextEncoderStream = @import("encode.zig").TextEncoderStream;

pub const Encoding = @import("encoding.zig").Encoding;
pub const getEncoding = @import("encoding.zig").getEncoding;
