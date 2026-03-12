// HTTP request 3 parts
//
// HTTP top header, (method, the URI, HTTP version)
// list of HTTP headers (key: value)
// body HTTP request
//
// http header -> Accept. MIME types. 
// -> the list of formats the client can read, or parse, or interpret

const std = @import("std");
const Io =  std.Io;
const Stream = Io.net.Stream;

pub const Method = enum {
    GET,
    pub fn init(method: []const u8) !Method {
        return std.meta.stringToEnum(Method, method) orelse error.InvalidMethod;
    }
    pub fn is_supported(method: []const u8) bool {
        _ = Method.init(method) catch |e| switch (e) {
            error.InvalidMethod => return false,
        };

        return true;
    }
};

pub const Request = struct {
    method: Method,
    uri: []const u8,
    version: []const u8,

    pub fn init(method: Method, uri: []const u8, version: []const u8) Request {
        return .{
            .method = method,
            .uri = uri,
            .version = version,
        };
    }
    pub fn parse_request(text: []u8) !Request {
        const line_index = std.mem.indexOfScalar(u8, text[0..], '\n') orelse text.len;
        var iterator = std.mem.splitScalar(u8, text[0..line_index], ' ');
        const method = try Method.init(iterator.next().?);
        const uri = iterator.next().?;
        const version = iterator.next().?;
        const request = Request.init(method, uri, version);

        return request;
    }
};

pub fn read_request(io: Io, conn: Stream, buffer: []u8) !void {
    var reader_buffer: [1024]u8 = undefined;
    var conn_reader = conn.reader(io, &reader_buffer);
    const reader = &conn_reader.interface;

    var start: usize = 0;
    for(0..10) |_| {
        const next_line_len = try read_next_line(reader, buffer, start);
        start += next_line_len;
    }
}

fn read_next_line(reader: *Io.Reader, buffer: []u8, start: usize) !usize {
    const next_line = try reader.takeDelimiterInclusive('\n');
    @memcpy(
        buffer[start..(start + next_line.len)],
        next_line[0..]
    );
    return next_line.len;
}
