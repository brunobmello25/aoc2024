const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day02.txt");

pub fn main() !void {
    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    var safe_count: i32 = 0;

    while (lines.next()) |line| {
        if (try is_safe(line)) {
            safe_count += 1;
        }
    }

    print("Safe count: {}\n", .{safe_count});
}

fn is_safe(line: []const u8) !bool {
    var iter = tokenizeScalar(u8, line, ' ');
    var current = try std.fmt.parseInt(i32, iter.next().?, 10);

    var previous_slope: ?i32 = null;

    while (iter.next()) |next| {
        const next_int = try std.fmt.parseInt(i32, next, 10);
        const slope = get_slope(current, next_int);
        const diff = @abs(current - next_int);

        if (previous_slope != null and slope != previous_slope.?) {
            return false;
        }

        if (diff < 1 or diff > 3) {
            return false;
        }

        previous_slope = slope;
        current = next_int;
    }

    return true;
}

fn will_be_safe(line: []const u8) !bool {
    var list = std.ArrayList(i32).init(gpa);
    defer list.deinit();

    var line_iter = tokenizeScalar(u8, line, ' ');

    while (line_iter.next()) |elem| {
        try list.append(try std.fmt.parseInt(i32, elem, 10));
    }

    for (0..list.items.len) |i| {
        var candidate_list = std.ArrayList(i32).init(gpa);
        defer candidate_list.deinit();

        for (0..list.items.len) |j| {
            if (i != j) {
                try candidate_list.append(@intCast(j));
            }
        }

        const slice = try candidate_list.toOwnedSlice();
        if (try is_safe(join(slice))) {
            return true;
        }
    }
    return false;
}

fn join(elements: []i32) []u8 {
    var str = std.ArrayList(u8).init(gpa);
    defer str.deinit();

    var buf: [20]u8 = undefined;

    for (elements, 0..) |e, i| {
        // TODO: bruno - entender melhor esse buf [0..]
        // FIXME: provavelmente essa linha aqui é o que ta crashando o programa
        str.append(try std.fmt.format(buf[0..], "{d}", .{e}));

        if (i < elements.len - 1) {
            str.append(' ');
        }
    }

    return try str.toOwnedSlice();
}

fn get_slope(a: i32, b: i32) i32 {
    if (a < b) return 1;
    if (a > b) return -1;
    return 0;
}

// Useful stdlib functions
const tokenizeScalar = std.mem.tokenizeScalar;
const print = std.debug.print;

test "will_be_safe function" {
    try std.testing.expect(try will_be_safe("1 3 2 4 5"));
}

test "is_safe function" {
    // Unsafe lines
    const unsafe_lines = [_][]const u8{
        "66 73 76 77 78 78 85",
        "80 78 79 77 79 85",
        "33 34 33 31 27 26",
        "69 66 69 73 75 77 76",
        "36 30 27 25 23 23 23",
        "70 67 66 64 62 65",
        "23 25 23 20 19 20 17 11",
        "24 24 25 29 30 32 34 35",
        "76 77 80 83 86 92 94",
        "62 60 58 55 53 53 51 45",
        "14 16 13 12 10 10 7 7",
        "74 74 73 70 69 66 63 63",
        "50 53 56 59 60 65",
    };

    // Safe lines
    const safe_lines = [_][]const u8{
        "89 88 85 82 81 80",
        "27 25 22 21 20",
        "71 72 75 78 80 82",
        "58 55 54 53 52 51 50 49",
        "44 41 39 37 34 33",
        "78 81 84 86 88 91 94",
        "25 26 28 31 32 34",
        "47 46 43 40 38",
        "10 13 14 17 19 22",
        "80 82 83 84 86 89",
        "79 80 82 84 85 86 88",
        "52 55 57 60 61",
        "58 61 62 64 65 68 69 70",
        "82 83 86 89 91 93",
        "24 23 22 21 18 17",
        "23 26 27 28 31 32",
    };

    // Test unsafe lines
    for (unsafe_lines) |line| {
        try std.testing.expect(!(try is_safe(line)));
    }

    // Test safe lines
    for (safe_lines) |line| {
        try std.testing.expect(try is_safe(line));
    }
}

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
