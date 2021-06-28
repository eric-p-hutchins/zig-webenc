const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const testing = std.testing;
const expect = testing.expect;
const expectEqual = testing.expectEqual;

const Encoding = @import("encoding.zig").Encoding;
const getEncoding = @import("encoding.zig").getEncoding;
const getEncoderHandler = @import("encoding.zig").getEncoderHandler;

const ErrorMode = @import("error.zig").ErrorMode;
const WebEncError = @import("error.zig").WebEncError;

const IoQueue = @import("io_queue.zig").IoQueue;

pub const TextEncodeOptions = struct {
    encoding: []const u8 = "utf-8",
    fatal: bool = false,
};

pub const HandlerResult = union(enum) {
    Finished,
    Items: []u8,
    Continue,
};

pub const EncoderHandler = struct {
    handleFn: fn (self: *EncoderHandler, item: IoQueue(u21).Item) anyerror!HandlerResult,
    deinitFn: fn (self: *EncoderHandler) void,

    pub fn handle(self: *EncoderHandler, item: IoQueue(u21).Item) anyerror!HandlerResult {
        return self.handleFn(self, item);
    }

    pub fn deinit(self: *EncoderHandler) void {
        self.deinitFn(self);
    }
};

// https://encoding.spec.whatwg.org/#interface-textencoder
pub const TextEncoder = struct {
    allocator: *Allocator,
    options: TextEncodeOptions,
    encoding: Encoding,
    error_mode: ErrorMode,
    handler: *EncoderHandler,

    pub fn init(allocator: *Allocator, options: TextEncodeOptions) !TextEncoder {
        var encoding = getEncoding(options.encoding);
        if (encoding == null or encoding.? == Encoding.Replacement) {
            return WebEncError.RangeError;
        }
        var handler: *EncoderHandler = try getEncoderHandler(allocator, encoding.?);
        return TextEncoder{
            .allocator = allocator,
            .options = options,
            .encoding = encoding.?,
            .handler = handler,
            .error_mode = if (options.fatal) .Fatal else .Replacement,
        };
    }

    pub fn deinit(self: *TextEncoder) void {
        self.handler.deinit();
    }

    /// The caller owns the returned text
    pub fn encode(self: *TextEncoder, input: []const u21) ![]u8 {
        var text = ArrayList(u8).init(self.allocator);
        defer text.deinit();

        var input_queue: IoQueue(u21) = IoQueue(u21).init(self.allocator, input);
        defer input_queue.deinit();

        var output_queue: IoQueue(u8) = IoQueue(u8).init(self.allocator, "");
        defer output_queue.deinit();

        outer: while (true) {
            const item = input_queue.read();
            const result = try self.handler.handle(item);
            switch (result) {
                .Finished => {
                    break :outer;
                },
                .Items => |items| {
                    for (items) |output_item| {
                        try output_queue.push(IoQueue(u8).Item{ .Regular = output_item });
                    }
                    self.allocator.free(items);
                },
                .Continue => {},
            }
        }

        return try output_queue.serialize();
    }
};

// https://encoding.spec.whatwg.org/#interface-textencoderstream
pub const TextEncoderStream = struct {};

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
