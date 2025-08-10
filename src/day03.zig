const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const file = @embedFile("data/day03.txt");

var index: usize = 0;
var add_enabled = true;

pub fn main() !void {
    const data = std.mem.bytesAsSlice(u8, file);

    const result = process_all_operations(data);

    print("Result: {}\n", .{result});
}

fn process_all_operations(data: []const u8) isize {
    var result: isize = 0;

    while (!is_done(data)) {
        advance_till_valid(data);
        if (is_done(data)) break;

        const op_result = process_operation(data) orelse continue;
        print("Operation result: {}\n", .{op_result});
        result += if (add_enabled) op_result else 0;
    }

    return result;
}

test "process all operations" {
    index = 0;
    const result = process_all_operations("mul(2,3)   mul(4,5)xyz1mul(6,7)");
    try std.testing.expectEqual(6 + 20 + 42, result);
}

fn process_operation(data: []const u8) ?isize {
    advance_till_alphabetic(data);
    if (is_done(data)) return null;

    advance_till_targets(data, "md");
    if (is_done(data)) return null;

    if (data[index] == 'm') {
        return process_mul_operation(data);
    } else if (data[index] == 'd') {
        process_toggle_operation(data);
        return null;
    } else unreachable;
}

fn process_toggle_operation(data: []const u8) void {
    advance_till_alphabetic(data);
    if (is_done(data)) return;

    const word = consume_word(data) catch return;
    if (std.mem.eql(u8, word, "don") and data[index] == '\'') {
        advance();

        if (is_done(data) or data[index] != 't') return;
        advance();

        if (data[index] != '(') return;
        advance();

        if (data[index] != ')') return;
        advance();

        add_enabled = false;
    } else if (std.mem.eql(u8, word, "do") and data[index] == '(') {
        advance();
        if (is_done(data) or data[index] != ')') return;

        add_enabled = true;
        advance();

        return;
    }
}

test "process toggle operation" {
    index = 0;
    add_enabled = true;
    const data = "don't()do()do()don't()do()";
    process_toggle_operation(data);
    try std.testing.expect(!add_enabled);
    try std.testing.expectEqual(7, index);

    process_toggle_operation(data);
    try std.testing.expect(add_enabled);
    try std.testing.expectEqual(11, index);

    process_toggle_operation(data);
    try std.testing.expect(add_enabled);
    try std.testing.expectEqual(15, index);

    process_toggle_operation(data);
    try std.testing.expect(!add_enabled);
    try std.testing.expectEqual(22, index);

    process_toggle_operation(data);
    try std.testing.expect(add_enabled);
    try std.testing.expectEqual(26, index);
}

fn process_mul_operation(data: []const u8) ?isize {
    const word = consume_word(data) catch return null;

    if (!std.mem.eql(u8, word, "mul")) return null;

    if (data[index] != '(') return null;
    advance();
    const left = consume_number(data) catch return null;
    if (data[index] != ',') return null;
    advance();
    const right = consume_number(data) catch return null;
    if (data[index] != ')') return null;
    advance();
    return left * right;
}

test "process operation" {
    index = 0;
    const result = process_operation("mul(3,4)abc") orelse -1;
    try std.testing.expectEqual(12, result);
}

fn advance_till_targets(data: []const u8, targets: []const u8) void {
    while (!is_done(data) and std.mem.indexOfScalar(u8, targets, data[index]) == null) {
        advance();
    }
}

fn advance_till_alphabetic(data: []const u8) void {
    while (!is_done(data) and !std.ascii.isAlphabetic(data[index])) {
        advance();
    }
}

// TODO: maybe handle cases where the the input is "asdfasdfmul(3,4)",
// meaning it has some alphabetic characters before a valid operation.
fn consume_word(data: []const u8) ![]const u8 {
    var word = std.ArrayList(u8).init(gpa);

    while (std.ascii.isAlphabetic(data[index])) {
        try word.append(data[index]);
        advance();
    }

    const res: []const u8 = try word.toOwnedSlice();
    return res;
}

test "consume word" {
    index = 0;
    const word = try consume_word("banana1234");
    try std.testing.expectEqualSlices(u8, "banana", word);
    try std.testing.expectEqual(6, index);

    index = 0;
    const word2 = try consume_word("apple pie");
    try std.testing.expectEqualSlices(u8, "apple", word2);
    try std.testing.expectEqual(5, index);
}

fn is_valid_char(data: []const u8) bool {
    const char = data[index];
    if (std.ascii.isAlphabetic(char)) return true;
    if (std.ascii.isDigit(char)) return true;
    if (char == '(' or char == ')') return true;
    if (char == ',') return true;
    return false;
}

test "is valid char" {
    index = 0;
    try std.testing.expect(is_valid_char("a\t"));
    try std.testing.expect(!is_valid_char(" \n"));
    try std.testing.expect(is_valid_char(")"));
    try std.testing.expect(is_valid_char("1"));
    try std.testing.expect(!is_valid_char("\t"));
}

fn consume_number(data: []const u8) !isize {
    var number = std.ArrayList(u8).init(gpa);

    while (std.ascii.isDigit(data[index])) {
        try number.append(data[index]);
        advance();
    }

    const num_str = try number.toOwnedSlice();
    const parsed = try std.fmt.parseInt(isize, num_str, 10);
    return parsed;
}

test "consume number" {
    index = 0;
    const num = try consume_number("12345abc");
    try std.testing.expectEqual(12345, num);
    try std.testing.expectEqual(5, index);

    index = 0;
    const num2 = try consume_number("007bond");
    try std.testing.expectEqual(7, num2);
    try std.testing.expectEqual(3, index);
}

fn advance() void {
    index += 1;
}

fn advance_till_valid(data: []const u8) void {
    while (!is_done(data) and !is_valid_char(data)) {
        advance();
    }
}

test "skip till valid" {
    index = 0;
    advance_till_valid("   \n\t  apple");
    try std.testing.expectEqual(7, index);
}

fn is_done(data: []const u8) bool {
    return index >= data.len;
}

// Useful stdlib functions
const tokenizeAny = std.mem.tokenizeAny;
const tokenizeSeq = std.mem.tokenizeSequence;
const tokenizeSca = std.mem.tokenizeScalar;
const splitAny = std.mem.splitAny;
const splitSeq = std.mem.splitSequence;
const splitSca = std.mem.splitScalar;
const indexOf = std.mem.indexOfScalar;
const indexOfAny = std.mem.indexOfAny;
const indexOfStr = std.mem.indexOfPosLinear;
const lastIndexOf = std.mem.lastIndexOfScalar;
const lastIndexOfAny = std.mem.lastIndexOfAny;
const lastIndexOfStr = std.mem.lastIndexOfLinear;
const trim = std.mem.trim;
const sliceMin = std.mem.min;
const sliceMax = std.mem.max;

const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.block;
const asc = std.sort.asc;
const desc = std.sort.desc;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
