extends Area2D

export var interaction_parent : NodePath
export(NodePath) var pBar_path

signal sound(state, soundStream)
signal on_interactable_changed(newInteractable)

var interaction_target : Node
onready var interactionCounter = 0.0

onready var pBar = get_node(pBar_path)

# Called every frame
func _process(delta):
	# Check whether the player is trying to interact
	if (interaction_target != null):
		if (Input.is_action_pressed("interact")):
			interactionCounter += 20 * delta
			emit_signal("sound", "Progress")
			pBar._on_interface_progress_changed(interactionCounter, true)
			# If so, we'll call interaction_interact() if our target supports it
			if (interactionCounter >= 100 and interaction_target.has_method("interaction_interact")):
				emit_signal("sound", "Finish")
				interaction_target.interaction_interact(self)
		elif (Input.is_action_just_released("interact")):
			interactionCounter = 0.0
			emit_signal("sound", "Fail")
			pBar._on_interface_progress_changed(interactionCounter, false)

# Signal triggered when our collider collides with something on the interaction layer
func _on_InteractionComponent_body_entered(body):
	var canInteract := false
	
	# GDScript lacks the concept of interfaces, so we can't check whether the body implements an interface
	# Instead, we'll see if it has the methods we need
	if (body.has_method("interaction_can_interact")):
		# Interactables tell us whether we're allowed to interact with them.
		canInteract = body.interaction_can_interact(get_node(interaction_parent))
	
	if not canInteract:
		return
		
	# Store the thing we'll be interacting with, so we can trigger it from _process
	interaction_target = body
	emit_signal("on_interactable_changed", interaction_target)


func _on_InteractionComponent_body_exited(body):
	if (body == interaction_target):
		interaction_target = null
		interactionCounter = 0
		pBar._on_interface_progress_changed(interactionCounter, false)
		emit_signal("on_interactable_changed", null)
