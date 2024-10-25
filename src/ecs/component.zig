const transform = @import("./components/transform.zig");
const std = @import("std");
const Entity = @import("./entity.zig").Entity;

pub const ComponentType = enum {
    Transform,

    pub fn getComponentType(comptime T: type) ?ComponentType {
        const typeName = ComponentType.getSimpleName(T);
        inline for (std.meta.fields(ComponentType)) |field| {
            if (std.mem.eql(u8, typeName, field.name)) {
                return @enumFromInt(field.value);
            }
        }
        return null;
    }

    fn getSimpleName(comptime T: type) []const u8 {
        const fullName = @typeName(T);
        var segments = std.mem.splitSequence(u8, fullName, ".");

        var last_part: ?[]const u8 = null;

        while (segments.next()) |part| {
            last_part = part;
        }

        return last_part.?;
    }
};

pub fn ComponentArray(comptime T: type) type {
    return struct {
        const Self = @This();
        allocator: std.mem.Allocator,
        components: std.ArrayList(T),
        entityToIndex: std.AutoHashMap(Entity, usize),
        indexToEntity: std.AutoHashMap(usize, Entity),

        pub fn init(allocator: std.mem.Allocator) ComponentArray(T) {
            return ComponentArray(T){
                .allocator = allocator,
                .components = std.ArrayList(T).init(allocator),
                .entityToIndex = std.AutoHashMap(Entity, usize).init(allocator),
                .indexToEntity = std.AutoHashMap(usize, Entity).init(allocator),
            };
        }

        pub fn insertData(self: *Self, entity: Entity, data: T) !void {
            const index = self.components.items.len;

            try self.entityToIndex.put(entity, index);
            try self.indexToEntity.put(index, entity);
            try self.components.append(data);
        }

        pub fn removeData(self: *Self, entity: Entity) !void {
            const entityIndex = self.entityToIndex.get(entity);
            const lastElementIndex = self.components.items.len;

            if (entityIndex) |index| {
                _ = self.components.swapRemove(index);

                const lastEntity: ?Entity = self.indexToEntity.get(lastElementIndex - 1);

                if (lastEntity) |value| {
                    try self.entityToIndex.put(value, index);
                    try self.indexToEntity.put(index, value);
                }

                _ = self.indexToEntity.remove(entity);
                _ = self.entityToIndex.remove(entity);
            }
        }

        pub fn getData(self: *Self, entity: Entity) ?*T {
            if (self.entityToIndex.get(entity)) |index| {
                return &self.components.items[index];
            }
            return null;
        }

        pub fn entityDestroyed(self: *Self, entity: Entity) void {
            if (self.entityToIndex.contains(entity)) {
                self.entityToIndex.remove(entity);
            }
        }
    };
}

pub const ErasedComponentArray = struct {
    const Self = @This();
    ptr: *anyopaque,

    pub fn cast(self: *Self, comptime T: type) *ComponentArray(T) {
        return @ptrCast(@alignCast(self.ptr));
    }
};

pub const ComponentManager = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    componentArrays: std.StringArrayHashMap(ErasedComponentArray),

    pub fn init(allocator: std.mem.Allocator) ComponentManager {
        return .{
            .allocator = allocator,
            .componentArrays = std.StringArrayHashMap(ErasedComponentArray).init(allocator),
        };
    }

    pub fn registerComponent(self: *Self, comptime T: type) void {
        const new_ptr = self.allocator.create(ComponentArray(T)) catch {
            std.debug.panic("Was not able to allocate memory for ComponentArray", .{});
        };
        new_ptr.* = ComponentArray(T).init(self.allocator);

        self.componentArrays.put(@typeName(T), ErasedComponentArray{ .ptr = new_ptr }) catch {
            std.debug.panic("Was not able to put ComponentArray inside the map", .{});
        };
    }

    pub fn addComponent(self: *Self, entity: Entity, component: anytype) void {
        const componentArray = self.getComponentArray(@TypeOf(component));

        componentArray.insertData(entity, component) catch {
            std.debug.print("Component was not able to be added", .{});
        };
    }

    pub fn removeComponent(self: *Self, entity: Entity, comptime T: type) void {
        const componentArray = self.getComponentArray(T);
        componentArray.removeData(entity) catch {
            std.debug.print("Component was not found to remove", .{});
        };
    }

    pub fn getComponent(self: *Self, entity: Entity, comptime T: type) ?*T {
        const componentArray = self.getComponentArray(T);
        return componentArray.getData(entity);
    }

    pub fn getComponentArray(self: *Self, comptime T: type) *ComponentArray(T) {
        var erasedComponentArray = self.componentArrays.get(@typeName(T)) orelse std.debug.panic("Component array not found", .{});

        const componentArray: *ComponentArray(T) = erasedComponentArray.cast(T);

        return componentArray;
    }

    pub fn entityDestroyed(self: *Self, entity: Entity) void {
        const iterator = self.componentArrays.iterator();

        while (iterator.next()) |entry| {
            const component = entry.value_ptr;
            const componentArray: *ComponentArray(anyopaque) = component.cast(anyopaque);
            componentArray.entityDestroyed(entity);
        }
    }
};
