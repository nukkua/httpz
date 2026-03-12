// we are gonna create a TCP socket through the listen()
// method from std.Io.net.IpAdress that returns std.Io.net.Server
// we use the accept() method to stablish the connection between the
// server and the client
//
// TCP socket object -> bind(host, port)
const std = @import("std");
const Io = std.Io;
const Socket = Io.net.Socket;
const Protocol = Io.net.Protocol;

pub const Server = struct {
    host: []const u8,
    port: u16,
    addr: Io.net.IpAddress,
    io: Io,
    pub fn init(io: Io) !Server {
        const host: []const u8 = "127.0.0.1";
        const port: u16 = 3490;
        const addr = try Io.net.IpAddress.parseIp4(host, port); // bind();

        return .{ .host = host, .port = port, .addr = addr, .io = io };
    }

    pub fn listen(self: Server) !Io.net.Server {
        std.debug.print("Server listening at: {s}:{}\n", .{ self.host, self.port });
        return try self.addr.listen(self.io, .{
            .mode = Socket.Mode.stream,
            .protocol = Protocol.tcp,
        });
    }
};
