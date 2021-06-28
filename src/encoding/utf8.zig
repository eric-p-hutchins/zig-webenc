const std = @import("std");
const Allocator = std.mem.Allocator;
const EncoderHandler = @import("../encode.zig").EncoderHandler;
const HandlerResult = @import("../encode.zig").HandlerResult;

const WebEncError = @import("../error.zig").WebEncError;

const IoQueue = @import("../io_queue.zig").IoQueue;

// https://encoding.spec.whatwg.org/#utf-8-encoder
pub const Utf8EncoderHandler = struct {
    allocator: *Allocator,
    handler: EncoderHandler = EncoderHandler{
        .handleFn = handle,
        .deinitFn = deinit,
    },

    pub fn init(allocator: *Allocator) !*Utf8EncoderHandler {
        var handler = try allocator.create(Utf8EncoderHandler);
        handler.* = Utf8EncoderHandler{ .allocator = allocator };
        return handler;
    }

    fn deinit(self: *EncoderHandler) void {
        var utf8EncoderHandler: *Utf8EncoderHandler = @fieldParentPtr(Utf8EncoderHandler, "handler", self);
        utf8EncoderHandler.allocator.destroy(utf8EncoderHandler);
    }

    fn handle(self: *EncoderHandler, item: IoQueue(u21).Item) !HandlerResult {
        var utf8_handler = @fieldParentPtr(Utf8EncoderHandler, "handler", self);
        var alloc = utf8_handler.allocator;
        switch (item) {
            .EndOfQueue => {
                return .Finished;
            },
            .Regular => |code_point| {
                var byte_count: u3 = undefined;
                var offset: u8 = undefined;
                var first_byte: u8 = undefined;
                switch (code_point) {
                    0x00...0x7F => {
                        byte_count = 1;
                        first_byte = @intCast(u8, item.Regular);
                    },
                    0x0080...0x07FF => {
                        byte_count = 2;
                        offset = 0xC0;
                    },
                    0x0800...0xFFFF => {
                        byte_count = 3;
                        offset = 0xE0;
                    },
                    0x10000...0x10FFFF => {
                        byte_count = 4;
                        offset = 0xF0;
                    },
                    else => {
                        return WebEncError.RangeError;
                    },
                }
                if (byte_count > 1) {
                    first_byte = @intCast(u8, (code_point >> @intCast(u5, (6 * @intCast(u8, (byte_count - 1)))))) + offset;
                }
                var bytes: []u8 = try alloc.alloc(u8, byte_count);
                bytes[0] = first_byte;
                var i: u3 = 1;
                while (byte_count > 1) : (byte_count -= 1) {
                    var temp = code_point >> @intCast(u5, @intCast(u8, 6) * @intCast(u8, byte_count - 1 - 1));
                    bytes[i] = @intCast(u8, 0x80 | (temp & 0x3F));
                    i += 1;
                }
                return HandlerResult{
                    .Items = bytes,
                };
            },
        }
    }
};
