/obj/machinery/modular_computer/console/preset
	// Can be changed to give devices specific hardware
	var/_has_second_id_slot = FALSE
	var/_has_battery = FALSE
	///List of programs the computer starts with, given on Initialize.
	var/list/datum/computer_file/starting_programs = list()

/obj/machinery/modular_computer/console/preset/Initialize(mapload)
	. = ..()
	if(!cpu)
		return

	cpu.install_component(new /obj/item/computer_hardware/card_slot)
	if(_has_second_id_slot)
		cpu.install_component(new /obj/item/computer_hardware/card_slot/secondary)
	if(_has_battery)
		cpu.install_component(new /obj/item/computer_hardware/battery(cpu, /obj/item/stock_parts/cell/computer/super))
	for(var/programs in starting_programs)
		var/datum/computer_file/program/program_type = new programs
		cpu.store_file(program_type)

// ===== ENGINEERING CONSOLE =====
/obj/machinery/modular_computer/console/preset/engineering
	console_department = "Engineering"
	name = "Инженерная консоль"
	desc = "Стационарный компьютер. Он поставляется с предустановленными инженерными программами.."
	starting_programs = list(
		/datum/computer_file/program/power_monitor,
		/datum/computer_file/program/alarm_monitor,
		/datum/computer_file/program/supermatter_monitor,
	)

// ===== RESEARCH CONSOLE =====
/obj/machinery/modular_computer/console/preset/research
	console_department = "Research"
	name = "Консоль директора по исследованиям"
	desc = "Стационарный компьютер. Он поставляется с предустановленными исследовательскими программами."
	_has_second_id_slot = TRUE
	starting_programs = list(
		/datum/computer_file/program/ntnetmonitor,
		/datum/computer_file/program/chatclient,
		/datum/computer_file/program/ai_restorer,
		/datum/computer_file/program/robocontrol,
	)

// ===== COMMAND CONSOLE =====
/obj/machinery/modular_computer/console/preset/command
	console_department = "Command"
	name = "Командная консоль"
	desc = "Стационарный компьютер. Он поставляется с предустановленными командными программами."
	_has_second_id_slot = TRUE
	starting_programs = list(
		/datum/computer_file/program/chatclient,
		/datum/computer_file/program/card_mod,
	)

// ===== IDENTIFICATION CONSOLE =====
/obj/machinery/modular_computer/console/preset/id
	console_department = "Identification"
	name = "Идентификационная консоль"
	desc = "Стационарный компьютер. Он поставляется с предустановленными программами модификации идентификации."
	_has_second_id_slot = TRUE
	starting_programs = list(
		/datum/computer_file/program/chatclient,
		/datum/computer_file/program/card_mod,
		/datum/computer_file/program/job_management,
		/datum/computer_file/program/crew_manifest,
	)

/obj/machinery/modular_computer/console/preset/id/centcom
	desc = "A stationary computer. This one comes preloaded with CentCom identification modification programs."

/obj/machinery/modular_computer/console/preset/id/centcom/Initialize(mapload)
	. = ..()
	var/datum/computer_file/program/card_mod/card_mod_centcom = cpu.find_file_by_name("plexagonidwriter")
	card_mod_centcom.is_centcom = TRUE

// ===== CIVILIAN CONSOLE =====
/obj/machinery/modular_computer/console/preset/civilian
	console_department = "Civilian"
	name = "Гражданская консоль"
	desc = "Стационарный компьютер. Он поставляется с предустановленными общими программами."
	starting_programs = list(
		/datum/computer_file/program/chatclient,
		/datum/computer_file/program/arcade,
	)

// curator
/obj/machinery/modular_computer/console/preset/curator
	console_department = "Civilian"
	name = "curator console"
	desc = "A stationary computer. This one comes preloaded with art programs."
	starting_programs = list(
		/datum/computer_file/program/portrait_printer,
	)

// ===== CARGO CHAT CONSOLES =====
/obj/machinery/modular_computer/console/preset/cargochat
	name = "cargo chatroom console"
	desc = "A stationary computer. This one comes preloaded with a chatroom for your cargo requests."
	starting_programs = list(
		/datum/computer_file/program/chatclient,
	)

/obj/machinery/modular_computer/console/preset/cargochat/Initialize(mapload)
	. = ..()
	var/datum/computer_file/program/chatclient/chatprogram = cpu.find_file_by_name("ntnrc_client")
	chatprogram.username = "[lowertext(console_department)]_department"
	chatprogram.program_state = PROGRAM_STATE_ACTIVE
	cpu.active_program = chatprogram

/obj/machinery/modular_computer/console/preset/cargochat/service
	console_department = "Service"

/obj/machinery/modular_computer/console/preset/cargochat/engineering
	console_department = "Engineering"

/obj/machinery/modular_computer/console/preset/cargochat/science
	console_department = "Science"

/obj/machinery/modular_computer/console/preset/cargochat/security
	console_department = "Security"

/obj/machinery/modular_computer/console/preset/cargochat/medical
	console_department = "Medical"


//ONE PER MAP PLEASE, IT MAKES A CARGOBUS FOR EACH ONE OF THESE
/obj/machinery/modular_computer/console/preset/cargochat/cargo
	console_department = "Cargo"
	name = "department chatroom console"
	desc = "A stationary computer. This one comes preloaded with a chatroom for incoming cargo requests. You may moderate it from this computer."

/obj/machinery/modular_computer/console/preset/cargochat/cargo/LateInitialize()
	. = ..()
	var/datum/computer_file/program/chatclient/chatprogram = cpu.find_file_by_name("ntnrc_client")
	chatprogram.username = "cargo_requests_operator"

	var/datum/ntnet_conversation/cargochat = chatprogram.create_new_channel("#cargobus", strong = TRUE)
	for(var/obj/machinery/modular_computer/console/preset/cargochat/cargochat_console in GLOB.machines)
		if(cargochat_console == src)
			continue
		var/datum/computer_file/program/chatclient/other_chatprograms = cargochat_console.cpu.find_file_by_name("ntnrc_client")
		other_chatprograms.active_channel = chatprogram.active_channel
		cargochat.add_client(other_chatprograms, silent = TRUE)
