const std = @import("std");
const expect = std.testing.expect;

const No = struct { data: ?[]const u8, next: ?*No, prev: ?*No};
const List = struct {
    head: ?*No = null,

    fn insertFirst(self: *List, new_no: *No) !void {
        if (self.head == null) {
            std.debug.print("null", .{});
            self.head = new_no;
            self.head.?.*.prev = new_no;
            return;
        }

        new_no.prev = self.head.?.*.prev;
        self.head.?.*.prev = new_no;

        new_no.next = null;
        self.head.?.*.prev.?.*.prev.?.*.next = new_no;
    }

    fn printList(self: *List) !void {
        var atual = self.head;
        while(true) {
            std.debug.print("Data: {?}\n", .{atual});

            if (atual.?.next == null){
                break;
            } else {
                atual = atual.?.next;
            }

        }
    }

};


pub fn main() !void {
    const file = try std.fs.cwd().openFile("./src/lib/zigml_parser.zig", .{ .mode = .read_only });


    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    //TODO TROCAR PARA ALOCAÇÂO DE MEMORIA, NÂO DEIXAR ISSO SER ALGO PADRÂO *1024*, COLOCAR PARA SER DINAMICO
    var line_buffer: [1024]u8 = undefined;

    var list: List = .{};

    var i: usize = 0;
    while(try in_stream.readUntilDelimiterOrEof(&line_buffer, '\r')) |line|: (i+=1) {
        if (std.mem.indexOf(u8, line, "//TODO")) |index| {
            const todo_line = line[index..(index+6)];
            std.debug.print("{s}\n", .{todo_line});


        }
    }

    var no: No = .{
        .data = "line[index..(index+6)]",
        .next = null,
        .prev = null
    };

    if (list.insertFirst(&no)) |_| {} else |err| {std.debug.print("Erro: {}", .{err});}
    if (list.insertFirst(&no)) |_| {} else |err| {std.debug.print("Erro: {}", .{err});}


    if (list.printList()) |_| {} else |err| {std.debug.print("Err: ", .{err});}
}