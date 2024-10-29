const std = @import("std");
const Signature = @import("entity.zig").Signature;
const Entity = @import("entity.zig").Entity;
const EntityManager = @import("entity.zig").EntityManager;
const ComponentType = @import("component.zig").ComponentType;
const ComponentManager = @import("component.zig").ComponentManager;

pub fn System(comptime T: type) type {
    return struct {
        entities: std.AutoArrayHashMap(Entity, void),

        pub fn init(allocator: std.mem.Allocator) System(T) {
            return .{
                .entities = std.AutoArrayHashMap(Entity, void).init(allocator),
            };
        }

        pub fn start(self: *System(T), coordinator: *Coordinator) void {
            for (self.entities.keys()) |entity| {
                T.start(coordinator, entity);
            }
        }

        pub fn update(self: *System(T), coordinator: *Coordinator, delta: f32) void {
            for (self.entities.keys()) |entity| {
                T.update(coordinator, entity, delta);
            }
        }
    };
}

pub const SystemManager = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    signatures: std.StringArrayHashMap(*Signature),
    systems: std.StringArrayHashMap(*anyopaque),

    pub fn init(allocator: std.mem.Allocator) SystemManager {
        return SystemManager{
            .allocator = allocator,
            .systems = std.StringArrayHashMap(*anyopaque).init(allocator),
            .signatures = std.StringArrayHashMap(*Signature).init(allocator),
        };
    }

    pub fn registerSystem(self: *Self, comptime T: type) *System(T) {
        const new_ptr = self.allocator.create(System(T)) catch @panic("Was not able to allocate memory for System");
        const typeName = @typeName(T);

        new_ptr.* = System(T).init(self.allocator);

        self.systems.put(
            typeName,
            new_ptr,
        ) catch @panic("Was not able to put System inside the map");

        const signture_ptr = self.allocator.create(Signature) catch @panic("Was not able to allocate memory for Signature");
        signture_ptr.* = Signature.initEmpty();

        // TODO: CHANGE THE COMPONENTS TYPE TO STORE AN ARRAY OF THE COMPONENT ITSELF INSTED OF THE ENUM
        for (T.components) |component| {
            const index = @intFromEnum(component);
            signture_ptr.set(index);
        }

        self.signatures.put(typeName, signture_ptr) catch @panic("Was not able to put Signature inside the map");

        return new_ptr;
    }

    pub fn entityDestroyed(self: *Self, entity: Entity) void {
        const iterator = self.systems.iterator();

        while (iterator.next()) |entry| {
            const system: *System(anyopaque) = @ptrCast(@alignCast(entry.value_ptr.*));
            system.entities.swapRemove(entity);
        }
    }

    pub fn signatureChanged(self: *Self, entity: Entity, entitySignature: Signature) void {
        var iterator = self.systems.iterator();

        while (iterator.next()) |entry| {
            const system: *System(anyopaque) = @ptrCast(@alignCast(entry.value_ptr.*));
            const key = entry.key_ptr.*;

            const signature: *Signature = self.signatures.get(key).?;

            if ((entitySignature.mask & signature.mask) == signature.mask) {
                system.entities.put(entity, {}) catch @panic("Could not add entity to system array");
            } else {
                _ = system.entities.swapRemove(entity);
            }
        }
    }
};

pub const Coordinator = struct {
    const Self = @This();

    componentManager: ComponentManager,
    systemManager: SystemManager,
    entityManager: EntityManager,

    pub fn init(allocator: std.mem.Allocator) Coordinator {
        return .{
            .componentManager = ComponentManager.init(allocator),
            .systemManager = SystemManager.init(allocator),
            .entityManager = EntityManager.init(allocator),
        };
    }

    pub fn createEntity(self: *Self) Entity {
        return self.entityManager.createEntity() catch @panic("Could not create a new entity");
    }

    pub fn destroyEntity(self: *Self, entity: Entity) void {
        self.entityManager.destroyEntity(entity);
        self.systemManager.entityDestroyed(entity);
        self.componentManager.entityDestroyed(entity);
    }

    pub fn registerComponent(self: *Self, comptime T: type) void {
        self.componentManager.registerComponent(T);
    }

    pub fn addComponent(self: *Self, entity: Entity, component: anytype) void {
        self.componentManager.addComponent(entity, component);
        const componentType = ComponentType.getComponentType(@TypeOf(component)).?;

        const signature = self.entityManager.getSignature(entity);
        signature.set(@intFromEnum(componentType));

        self.systemManager.signatureChanged(entity, signature.*);
    }

    pub fn removeComponent(self: *Self, entity: Entity, comptime T: type) void {
        self.componentManager.removeComponent(entity, T);
        const componentType = ComponentType.getComponentType(T).?;

        const signature = self.entityManager.getSignature(entity);
        signature.unset(@intFromEnum(componentType));

        self.systemManager.signatureChanged(entity, signature);
    }

    pub fn getComponent(self: *Self, entity: Entity, comptime T: type) ?*T {
        return self.componentManager.getComponent(entity, T);
    }

    pub fn registerSystem(self: *Self, comptime T: type) *System(T) {
        return self.systemManager.registerSystem(T);
    }
};
