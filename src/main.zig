const sokol = @import("sokol");
const std = @import("std");
const slog = sokol.log;
const sg = sokol.gfx;
const sapp = sokol.app;
const sglue = sokol.glue;
const shd = @import("shaders/shader.glsl.zig");

const state = struct {
    var bind: sg.Bindings = .{};
    var pip: sg.Pipeline = .{};
    var pass_action: sg.PassAction = .{};
};


const VS_PARAMS = struct {
    aspect: f32,
    _pad: [1]f32,
    resolution: [2]f32,
};



export fn init() void {

    sg.setup(.{
        .environment = sglue.environment(),
        .logger = .{ .func = slog.func },
    });
    
    
    // a vertex buffer
    state.bind.vertex_buffers[0] = sg.makeBuffer(.{
        .data = sg.asRange(&[_]f32{
            // positions    |     colors        | texcoord
            -0.5, 0.5,  0.5, 1.0, 0.0, 0.0, 1.0, 
            0.5,  0.5,  0.5, 0.0, 1.0, 0.0, 1.0,  
            0.5,  -0.5, 0.5, 0.0, 0.0, 1.0, 1.0,  
            -0.5, -0.5, 0.5, 1.0, 1.0, 0.0, 1.0,  
        }),
    });

    // an index buffer
    state.bind.index_buffer = sg.makeBuffer(.{
        .usage = .{ .index_buffer = true },
        .data = sg.asRange(&[_]u16{ 
            0, 1, 2, 
            0, 2, 3,
        }),
    });

    // a shader and pipeline state object
    state.pip = sg.makePipeline(.{
        .shader = sg.makeShader(shd.quadShaderDesc(sg.queryBackend())),
        .layout = init: {
            var l = sg.VertexLayoutState{};
            l.attrs[shd.ATTR_quad_position].format = .FLOAT3;
            l.attrs[shd.ATTR_quad_color0].format = .FLOAT4;    
            break :init l;
        },
        .index_type = .UINT16,
        .colors = [_]sg.ColorTargetState {
            .{
            
                .blend = .{
                    .enabled = true,
                    .src_factor_rgb = .SRC_ALPHA,
                    .dst_factor_rgb = .ONE_MINUS_SRC_ALPHA,
                    .op_rgb = .ADD,
                    .src_factor_alpha = .ONE,
                    .dst_factor_alpha = .ONE_MINUS_SRC_ALPHA,
                    .op_alpha = .ADD,
                
                },
            
            },
            
        } ** 4,
    });

    // clear to black
    state.pass_action.colors[0] = .{
        .load_action = .CLEAR,
        .clear_value = .{ .r = 0.176, .g = 0.243, .b = 0.314, .a = 1.0 },
    };
}

export fn frame() void {
    const width = sapp.width();
    const height = sapp.height();
    

    const params: VS_PARAMS = .{
        .aspect = @as(f32, @floatFromInt(width)) / @as(f32, @floatFromInt(height)),
        ._pad = undefined,
        .resolution = .{ @as(f32, @floatFromInt(width)), @as(f32, @floatFromInt(height))},    
    };
    

    std.debug.print("Wditth: {d}, Aspect: {}\n", .{params.resolution, params.aspect});
        
    sg.beginPass(.{ .action = state.pass_action, .swapchain = sglue.swapchain() });
    sg.applyPipeline(state.pip);
    sg.applyBindings(state.bind);
    sg.applyUniforms(shd.UB_vs_params, sg.Range{.ptr = &params, .size = @sizeOf(f32) * 4});
    sg.draw(0, 9, 1);
    sg.endPass();
    sg.commit();
}

export fn cleanup() void {
    sg.shutdown();
}

pub fn main() void {
    sapp.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .width = 600,
        .height = 600,
        .icon = .{ .sokol_default = true },
        .window_title = "quad.zig",
        .logger = .{ .func = slog.func },
    });
}
