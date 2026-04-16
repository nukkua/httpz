// it needs to be a genius to understand the simplicity
// 1 Create a TCP socket object
// 2 Bind a name to this socket object
// 3 Socket object to listen and wait incoming connections
// 4 connection arrives -> accept connection -> exchange the HTTP messages
// (HTTP request and HTTP response)
// 5 close the connection

// socket object
// -> it needs to be binded to a particular address binds();
// -> it needs to listen for incoming connections in this address listen();
// -> listen() waits for incoming connections
// -> it needs to accept the connection (stablish)
// -> it needs to close the connection

const std = @import("std");
const Server = @import("server.zig").Server;
const Request = @import("request.zig");
const Io = std.Io;
const Response = @import("response.zig");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const server = try Server.init(io);

    var listening = try server.listen();
    defer listening.deinit(io);

    const conn = try listening.accept(io);
    defer conn.close(io);

    var request_buffer: [1024]u8 = undefined;
    @memset(request_buffer[0..], 0);
    try Request.read_request(io, conn, request_buffer[0..]);
    const request = try Request.Request.parse_request(request_buffer[0..]);
    if (request.method == Request.Method.GET) {
        if (std.mem.eql(u8, request.uri, "/")) {
            try Response.send_200(conn, io);
        }
    }
}
