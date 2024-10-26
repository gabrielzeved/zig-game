const std = @import("std");

const MAX_COMPONENTS = 32;

pub const EntityType = enum {
    Player,
};

pub const Entity = u32;
pub const Signature = std.bit_set.IntegerBitSet(MAX_COMPONENTS);
pub const Allocator = std.mem.Allocator;

pub const EntityManager = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    currentEntityId: Entity = 0,
    entities: std.ArrayList(Entity),
    signatures: std.AutoHashMap(Entity, *Signature),

    pub fn init(allocator: std.mem.Allocator) EntityManager {
        return .{
            .allocator = allocator,
            .entities = std.ArrayList(Entity).init(allocator),
            .signatures = std.AutoHashMap(Entity, *Signature).init(allocator),
        };
    }

    pub fn createEntity(self: *Self) Allocator.Error!Entity {
        const entity = self.currentEntityId;
        defer self.currentEntityId += 1;

        try self.entities.append(entity);

        const new_ptr = try self.allocator.create(Signature);
        new_ptr.* = Signature.initEmpty();

        try self.signatures.put(entity, new_ptr);

        return entity;
    }

    pub fn destroyEntity(self: *Self, entity: Entity) void {
        self.signatures.get(entity).?.* = Signature.initEmpty();
        for (self.entities.items, 0..) |item, index| {
            if (entity == item) {
                self.entities.swapRemove(index);
                return;
            }
        }
    }

    pub fn getSignature(self: *EntityManager, entity: Entity) *Signature {
        return self.signatures.get(entity).?;
    }
};
