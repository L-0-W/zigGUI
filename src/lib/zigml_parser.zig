const std = @import("std");

const no = struct { data: ?[]const u8, next: ?*no, prev: ?*no};

const stack = struct {
    head: ?*no = null,

    pub fn insertLast(self: *stack, new_no: *no) void {
        if (self.head == null) {
            self.head = new_no;
            self.head.?.*.prev = new_no;
            return;
        }

        new_no.prev = self.head.?.*.prev;
        self.head.?.*.prev = new_no;

        new_no.next = null;
        self.head.?.*.prev.?.*.prev.?.*.next = new_no;
    }

    pub fn listPrint(self: *stack) !void {
        var atual = self.head;

        while(atual != null) {
                std.debug.print("{?s}", .{atual.?.*.data});
                atual = atual.?.next;
        }
    }

    pub fn removeLast(self: *stack, ) !void {
        const ultimo = self.head.?.*.prev;
        ultimo.?.*.prev.?.*.next = null;

        self.head.?.*.prev = ultimo.?.*.prev;
    }

};

pub fn main() !void {
    const file = try std.fs.cwd().openFile("./public/main.zigml", .{ .mode = .read_only });

    defer file.close();
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    //TROCAR PARA ALOCAÇÂO DE MEMORIA, NÂO DEIXAR ISSO SER ALGO PADRÂO *1024*, COLOCAR PARA SER DINAMICO
    var line_buffer: [1024]u8 = undefined;
    var list = stack{};

    var new_no: no = .{ .data =  "", .next = null, .prev = null};
    while(try in_stream.readUntilDelimiterOrEof(&line_buffer, '\r')) |line| {

        // MELHORAR PARA SE LINHA (QUE CONTEM <CONTAINER>) RETIRANDO OS <>, EXISTE EM STRUCT *NODES*? SE SIM
        // INSERIR NA PILHA COMO *CONTAINER*

        if (std.mem.eql(u8, line[0..line.len],"<container>")){
            const value: []const u8 = line;
            //ARRUMAR ESTA COLOCANDO APENAS */containe* -> container
            new_no.data = value;
            //std.debug.print("{s}", .{line[1..line.len - 1]});

        } else if (std.mem.eql(u8, line[0..line.len],"</container>")) {

            //
        }
    }

    list.insertLast(&new_no);

   // if(list.removeLast()) |_| {} else |err| {std.debug.print("{?}", .{err}); return;}

   // list.insertLast(&new_no__);

   if (list.listPrint()) |_| {} else |err| {std.debug.print("{}", .{err});return;}
}