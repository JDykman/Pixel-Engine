package main

MAX_ENTITIES :: 2048

import "base:runtime"
import "core:log"
import "core:fmt"

Entity_Handle :: struct {
	index: int,
	id: int,
}

zero_entity: Entity

get_all_ents :: proc() -> []Entity_Handle {
	return ctx.gs.scratch.all_entities
}

is_valid :: proc {
	entity_is_valid,
	entity_is_valid_ptr,
}
entity_is_valid :: proc(entity: Entity) -> bool {
	return entity.handle.id != 0
}
entity_is_valid_ptr :: proc(entity: ^Entity) -> bool {
	return entity != nil && entity_is_valid(entity^)
}

entity_init_core :: proc() {
	entity_setup(&zero_entity, .nil)
}

entity_from_handle :: proc(handle: Entity_Handle) -> (entity: ^Entity, ok:bool) #optional_ok {
	if handle.index <= 0 || handle.index > ctx.gs.entity_top_count {
		return &zero_entity, false
	}

	ent := &ctx.gs.entities[handle.index]
	if ent.handle.id != handle.id {
		return &zero_entity, false
	}

	return ent, true
}

entity_create :: proc(kind: Entity_Kind) -> ^Entity {

	index:= -1
	if len(ctx.gs.entity_free_list) > 0 {
		index = pop(&ctx.gs.entity_free_list)
	}

	if index == -1 {
		assert(ctx.gs.entity_top_count+1 < MAX_ENTITIES, "ran out of entities, increase size")
		ctx.gs.entity_top_count += 1
		index = ctx.gs.entity_top_count
	}

	ent := &ctx.gs.entities[index]
	ent.handle.index = index
	ent.handle.id = ctx.gs.latest_entity_id + 1
	ctx.gs.latest_entity_id = ent.handle.id

	entity_setup(ent, kind)
	fmt.assertf(ent.kind != nil, "entity %v needs to define a kind during setup", kind)

	return ent
}

entity_destroy :: proc(e: ^Entity) {
	append(&ctx.gs.entity_free_list, e.handle.index)
	e^ = {}
}