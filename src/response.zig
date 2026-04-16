const std = @import("std");
const Io = std.Io;
const Stream = Io.net.Stream;

pub fn send_200(conn: Stream, io: Io) !void {
    const message = (
        "HTTP/1.1 200 OK\nContent-Length: 48"
        ++ "\nContent-Type: text/html\n"
        ++ "Connection: Closed\n\n<html><body>"
        ++ "<h1>Hello, World!</h1></body></html>"
        ++ "<h1>Pancakes</h1></body></html>"
    );

    var stream_writer = conn.writer(io, &.{});
    _ = try stream_writer.interface.write(message);
}
