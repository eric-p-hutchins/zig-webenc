const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;
const expectEqual = testing.expectEqual;
const ArrayList = std.ArrayList;

// https://encoding.spec.whatwg.org/#concept-stream
pub fn IoQueue(comptime T: type) type {
    return struct {
        allocator: *Allocator,
        items: []const T,
        pushed: ArrayList(T),
        pos: usize,

        pub const Item = union(enum) {
            Regular: T,
            EndOfQueue,
        };

        pub fn init(allocator: *Allocator, items: []const T) IoQueue(T) {
            return IoQueue(T){
                .allocator = allocator,
                .items = items,
                .pushed = ArrayList(T).init(allocator),
                .pos = 0,
            };
        }

        pub fn deinit(self: *IoQueue(T)) void {
            self.pushed.deinit();
        }

        pub fn peek(self: *IoQueue(T), n: usize) ![]Item {
            var result = ArrayList(Item).init(self.allocator);
            defer result.deinit();

            var i: usize = 0;
            while (i < n) : (i += 1) {
                if (self.pos + i < self.items.len) {
                    try result.append(Item{ .Regular = self.items[self.pos + i] });
                } else if (self.pos + i - self.items.len < self.pushed.items.len) {
                    try result.append(Item{ .Regular = self.pushed.items[self.pos + i - self.items.len] });
                } else {
                    break;
                }
            }

            return std.mem.dupe(self.allocator, Item, result.items);
        }

        pub fn peekOne(self: *IoQueue(T)) ?T {
            if (self.pos < self.items.len) {
                return self.items[self.pos];
            } else if (self.pos - self.items.len < self.pushed.items.len) {
                return self.pushed.items[self.pos - self.items.len];
            }
            return null;
        }

        pub fn size(self: *IoQueue(T)) usize {
            var result: usize = self.items.len + self.pushed.items.len - self.pos;
            result += 1;
            return result;
        }

        pub fn read(self: *IoQueue(T)) Item {
            if (self.pos >= self.items.len + self.pushed.items.len) {
                return .EndOfQueue;
            }
            var item: Item = undefined;
            if (self.pos < self.items.len) {
                item = Item{ .Regular = self.items[self.pos] };
            } else {
                item = Item{ .Regular = self.pushed.items[self.pos - self.items.len] };
            }
            self.pos += 1;
            return item;
        }

        pub fn push(self: *IoQueue(T), item: Item) !void {
            switch (item) {
                .Regular => |unwrapped| {
                    try self.pushed.append(unwrapped);
                },
                .EndOfQueue => {},
            }
        }

        pub fn serialize(self: *IoQueue(T)) ![]T {
            var buffer = try self.allocator.alloc(T, self.items.len + self.pushed.items.len - self.pos);
            if (self.pos < self.items.len) {
                std.mem.copy(T, buffer, self.items);
            }
            std.mem.copy(T, buffer[self.items.len..], self.pushed.items);
            return buffer;
        }
    };
}

test "Immediate I/O Queue of bytes" {
    var bytes = [_]u8{ 'A', 'B', 'C' };
    var byte_queue = IoQueue(u8).init(testing.allocator, &bytes);
    defer byte_queue.deinit();

    var peeked: []IoQueue(u8).Item = try byte_queue.peek(1);
    try expectEqual(@intCast(usize, 1), peeked.len);
    try expectEqual(IoQueue(u8).Item{ .Regular = 'A' }, peeked[0]);
    testing.allocator.free(peeked);

    peeked = try byte_queue.peek(2);
    try expectEqual(@intCast(usize, 2), peeked.len);
    try expectEqual(IoQueue(u8).Item{ .Regular = 'A' }, peeked[0]);
    try expectEqual(IoQueue(u8).Item{ .Regular = 'B' }, peeked[1]);
    testing.allocator.free(peeked);

    try expectEqual(IoQueue(u8).Item{ .Regular = 'A' }, byte_queue.read());
    try expectEqual(IoQueue(u8).Item{ .Regular = 'B' }, byte_queue.read());

    peeked = try byte_queue.peek(2);
    try expectEqual(@intCast(usize, 1), peeked.len);
    try expectEqual(IoQueue(u8).Item{ .Regular = 'C' }, peeked[0]);
    testing.allocator.free(peeked);

    try byte_queue.push(IoQueue(u8).Item{ .Regular = 'D' });

    try expectEqual(@intCast(u8, 'C'), byte_queue.peekOne().?);

    peeked = try byte_queue.peek(3);
    try expectEqual(@intCast(usize, 2), peeked.len);
    try expectEqual(IoQueue(u8).Item{ .Regular = 'C' }, peeked[0]);
    try expectEqual(IoQueue(u8).Item{ .Regular = 'D' }, peeked[1]);
    testing.allocator.free(peeked);

    try expectEqual(IoQueue(u8).Item{ .Regular = 'C' }, byte_queue.read());

    try expectEqual(@intCast(u8, 'D'), byte_queue.peekOne().?);

    try expectEqual(IoQueue(u8).Item{ .Regular = 'D' }, byte_queue.read());
    try expectEqual(IoQueue(u8).Item.EndOfQueue, byte_queue.read());
    try expectEqual(IoQueue(u8).Item.EndOfQueue, byte_queue.read());

    try expectEqual(@as(?u8, null), byte_queue.peekOne());

    peeked = try byte_queue.peek(3);
    try expectEqual(@intCast(usize, 0), peeked.len);
    testing.allocator.free(peeked);
}

test "Immediate I/O Queue of code points" {
    var code_points = [_]u21{ 'A', 'B', 0x26A1 }; // AB⚡
    var code_point_queue = IoQueue(u21).init(testing.allocator, &code_points);
    defer code_point_queue.deinit();

    var peeked: []IoQueue(u21).Item = try code_point_queue.peek(1);
    try expectEqual(@intCast(usize, 1), peeked.len);
    try expectEqual(IoQueue(u21).Item{ .Regular = 'A' }, peeked[0]);
    testing.allocator.free(peeked);

    peeked = try code_point_queue.peek(2);
    try expectEqual(@intCast(usize, 2), peeked.len);
    try expectEqual(IoQueue(u21).Item{ .Regular = 'A' }, peeked[0]);
    try expectEqual(IoQueue(u21).Item{ .Regular = 'B' }, peeked[1]);
    testing.allocator.free(peeked);

    try expectEqual(IoQueue(u21).Item{ .Regular = 'A' }, code_point_queue.read());
    try expectEqual(IoQueue(u21).Item{ .Regular = 'B' }, code_point_queue.read());

    peeked = try code_point_queue.peek(2);
    try expectEqual(@intCast(usize, 1), peeked.len);
    try expectEqual(IoQueue(u21).Item{ .Regular = 0x26A1 }, peeked[0]); // ⚡
    testing.allocator.free(peeked);

    try code_point_queue.push(IoQueue(u21).Item{ .Regular = 0xFFFD }); // �

    try expectEqual(@intCast(u21, 0x26A1), code_point_queue.peekOne().?);

    peeked = try code_point_queue.peek(3);
    try expectEqual(@intCast(usize, 2), peeked.len);
    try expectEqual(IoQueue(u21).Item{ .Regular = 0x26A1 }, peeked[0]); // ⚡
    try expectEqual(IoQueue(u21).Item{ .Regular = 0xFFFD }, peeked[1]); // �
    testing.allocator.free(peeked);

    try expectEqual(IoQueue(u21).Item{ .Regular = 0x26A1 }, code_point_queue.read()); // ⚡

    try expectEqual(@intCast(u21, 0xFFFD), code_point_queue.peekOne().?); // �

    try expectEqual(IoQueue(u21).Item{ .Regular = 0xFFFD }, code_point_queue.read()); // �
    try expectEqual(IoQueue(u21).Item.EndOfQueue, code_point_queue.read());
    try expectEqual(IoQueue(u21).Item.EndOfQueue, code_point_queue.read());

    try expectEqual(@as(?u21, null), code_point_queue.peekOne());

    peeked = try code_point_queue.peek(3);
    try expectEqual(@intCast(usize, 0), peeked.len);
    testing.allocator.free(peeked);
}

// TODO: Handle this use-case of streaming queue where read/peek operations wait until enough "items" are
// available. If possible, handle this with options to the IoQueue instead of adding a new type, but only if
// the syntax and calling of IoQueue remains convenient for the Immediate mode (meaning I don't want to have
// to suddenly add "async" or "await" to any of my calling code, but more "try"'s would be fine).
//
// pub fn StreamingIoQueue(type: comptime T) type {
//     return struct {
//         allocator: *Allocator,
//         items: []T,
//         pushed: ArrayList(T),
//         pos: usize,

//         pub const Item = union(enum) {
//             Regular: T,
//             EndOfQueue,
//         };

//         pub fn init(allocator: *Allocator, items: []T) IoQueue(T) {
//         }

//         pub fn deinit(self: *IoQueue(T)) void {
//         }

//         pub fn peek(self: *IoQueue(T), n: usize) ![]Item {
//         }

//         pub fn peekOne(self: *IoQueue(T)) ?T {
//         }

//         pub fn size(self: *IoQueue(T)) usize {
//         }

//         pub fn read(self: *IoQueue(T)) Item {
//         }

//         pub fn push(self: *IoQueue(T), item: Item) !void {
//         }
//     };
// }

// test "Streaming I/O Queue of bytes" {
//     var bytes = [_]u8{ 'A', 'B', 'C' };
//     var byte_queue = IoQueue(u8).init(testing.allocator, &bytes, .{ .type = .Streaming });
//     defer byte_queue.deinit();

//     var peeked: []IoQueue(u8).Item = try byte_queue.peek(1);
//     try expectEqual(@intCast(usize, 1), peeked.len);
//     try expectEqual(IoQueue(u8).Item{ .Regular = 'A' }, peeked[0]);
//     testing.allocator.free(peeked);

//     peeked = try byte_queue.peek(2);
//     try expectEqual(@intCast(usize, 2), peeked.len);
//     try expectEqual(IoQueue(u8).Item{ .Regular = 'A' }, peeked[0]);
//     try expectEqual(IoQueue(u8).Item{ .Regular = 'B' }, peeked[1]);
//     testing.allocator.free(peeked);

//     try expectEqual(IoQueue(u8).Item{ .Regular = 'A' }, byte_queue.read());
//     try expectEqual(IoQueue(u8).Item{ .Regular = 'B' }, byte_queue.read());

//     peeked = try byte_queue.peek(2);
//     try expectEqual(@intCast(usize, 1), peeked.len);
//     try expectEqual(IoQueue(u8).Item{ .Regular = 'C' }, peeked[0]);
//     testing.allocator.free(peeked);

//     try byte_queue.push(IoQueue(u8).Item{ .Regular = 'D' });

//     try expectEqual(@intCast(u8, 'C'), byte_queue.peekOne().?);

//     peeked = try byte_queue.peek(3);
//     try expectEqual(@intCast(usize, 2), peeked.len);
//     try expectEqual(IoQueue(u8).Item{ .Regular = 'C' }, peeked[0]);
//     try expectEqual(IoQueue(u8).Item{ .Regular = 'D' }, peeked[1]);
//     testing.allocator.free(peeked);

//     try expectEqual(IoQueue(u8).Item{ .Regular = 'C' }, byte_queue.read());

//     try expectEqual(@intCast(u8, 'D'), byte_queue.peekOne().?);

//     try expectEqual(IoQueue(u8).Item{ .Regular = 'D' }, byte_queue.read());
//     try expectEqual(IoQueue(u8).Item.EndOfQueue, byte_queue.read());
//     try expectEqual(IoQueue(u8).Item.EndOfQueue, byte_queue.read());

//     try expectEqual(@as(?u8, null), byte_queue.peekOne());

//     peeked = try byte_queue.peek(3);
//     try expectEqual(@intCast(usize, 0), peeked.len);
//     testing.allocator.free(peeked);
// }
