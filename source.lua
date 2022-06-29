open_jobs = {}
completed_jobs = {}
active_job = 0
origin = {0,0,0}
cur_elements = {}

function main()
	open_jobs = pyio.load_values("open_jobs") or open_jobs
	completed_jobs = pyio.load_values("completed_jobs") or completed_jobs
	
	if #open_jobs == 0 then 
		if create_default_question() == true then
			pyio.save_values("open_jobs", create_demo_table())
			open_jobs = pyio.load_values("open_jobs") or open_jobs
		end
	end
	if #open_jobs == 0 then --still no available jobs!
		pyui.alert(pyloc "No open jobs available!")
		return
	end
	active_job = #open_jobs
	pyui.run_modal_dialog(webshop_dialog)

	table.insert(completed_jobs, open_jobs[active_job])
	table.remove(open_jobs, active_job)
	pyio.save_values("open_jobs", open_jobs)
	pyio.save_values("completed_jobs", completed_jobs)
end

function webshop_dialog(dialog, data)
	
	dialog:set_window_title(pyloc "Webshop Import")  

	local label_job_list = dialog:create_label(1, pyloc "Open jobs")
	local job_list = dialog:create_drop_list({2,3})
	for i,k in ipairs(open_jobs) do
		job_list:insert_control_item(k.name)
	end
	job_list:set_control_selection(active_job)
	
 	dialog:create_align({1,3})
	

	local label_name = dialog:create_label(1, pyloc "Project")
	local name = dialog:create_text_display({2,3}, open_jobs[active_job].name)
	local label_customer = dialog:create_label(1, pyloc "Customer")
	local customer = dialog:create_text_display({2,3}, open_jobs[active_job].customer)
	local label_date = dialog:create_label(1, pyloc "Date")
	local date = dialog:create_text_display({2,3}, open_jobs[active_job].date)
	
	dialog:create_align({1,3})
	dialog:equalize_column_widths({1,2,3})
	dialog:create_ok_button(2)
    dialog:create_cancel_button(3)
		
	job_list:set_on_change_handler(function(text, new_index)
		active_job = new_index
		name:set_control_text(open_jobs[active_job].name)
		customer:set_control_text(open_jobs[active_job].customer)
		date:set_control_text(open_jobs[active_job].date)
		recreate_geometry()
	end)
	recreate_geometry()
end

function recreate_geometry()
    if cur_elements ~= nil then
        pytha.delete_element(cur_elements)
    end
	cur_elements = {}

	for i,obj in ipairs(open_jobs[active_job].objects) do
		if obj.type == "pyo" and obj.file_handle ~= nil then 
			local loaded_parts = pytha.import_pyo(obj.file_handle, obj.origin, nil, obj.parametrics)
			for i,k in pairs(loaded_parts) do
				table.insert(cur_elements, k)
			end
			if obj.attributes ~= nil then 
				pytha.set_element_attributes(loaded_parts, obj.attributes)
			end
		elseif obj.type == "block" then 
			local length = obj.length or 0
			local width = obj.width or 0
			local height = obj.height or 0
			local new_part = pytha.create_block(length, width, height, obj.origin)
			table.insert(cur_elements, new_part)
			if obj.attributes ~= nil then 
				pytha.set_element_attributes(new_part, obj.attributes)
			end
		elseif obj.type == "cylinder" then 
			local height = obj.height or 0
			local radius = obj.radius or 0
			local new_part = pytha.create_cylinder(height, radius, obj.origin)
			table.insert(cur_elements, new_part)
			if obj.attributes ~= nil then 
				pytha.set_element_attributes(new_part, obj.attributes)
			end
		elseif obj.type == "ngo" then 
			local new_part = pytha.create_ngo(obj.attributes)
			table.insert(cur_elements, new_part)
			
			
			--here you can add further types or support for groups or attributes similar to the parametrics etc.
		end
	end
end



function database_edit()
	open_jobs = pyio.load_values("open_jobs") or open_jobs
	completed_jobs = pyio.load_values("completed_jobs") or completed_jobs
	
	if #open_jobs == 0 and #completed_jobs then 
		pyui.alert(pyloc "No jobs available!")
		return
	end
	pyui.run_modal_dialog(webshop_archive_dialog)

	pyio.save_values("open_jobs", open_jobs)
	pyio.save_values("completed_jobs", completed_jobs)
end

function webshop_archive_dialog(dialog, data)
	local cur_open = #open_jobs
	local cur_completed = #completed_jobs
	local controls = {}

	dialog:set_window_title(pyloc "Webshop Archive")  

	dialog:create_group_box({1,3}, pyloc "Open jobs")
	controls.job_list = dialog:create_drop_list({1,3})
	dialog:create_label(1, pyloc "Project")
	controls.name = dialog:create_text_display({2,3})
	dialog:create_label(1, pyloc "Customer")
	controls.customer = dialog:create_text_display({2,3})
	dialog:create_label(1, pyloc "Date")
	controls.date = dialog:create_text_display({2,3})

	controls.close_job = dialog:create_button(1, pyloc "Close job")
	controls.delete_job = dialog:create_button(3, pyloc "Delete job")
	dialog:end_group_box()
---------
	dialog:create_group_box({4,6}, pyloc "Completed jobs")
	controls.comp_job_list = dialog:create_drop_list({4,6})
	dialog:create_label(4, pyloc "Project")
	controls.comp_name = dialog:create_text_display({5,6})
	dialog:create_label(4, pyloc "Customer")
	controls.comp_customer = dialog:create_text_display({5,6})
	dialog:create_label(4, pyloc "Date")
	controls.comp_date = dialog:create_text_display({5,6})

	controls.reopen_job = dialog:create_button(4, pyloc "Reopen job")
	controls.delete_comp_job = dialog:create_button(6, pyloc "Delete job")
	dialog:end_group_box()

	dialog:create_align({1,6})
	dialog:equalize_column_widths({1,2,3,4,5,6})
	dialog:create_ok_button(5)
	dialog:create_cancel_button(6)
	
	update_archive_ui(controls, cur_open, cur_completed)

	controls.job_list:set_on_change_handler(function(text, new_index)
		cur_open = new_index
	update_archive_ui(controls, cur_open, cur_completed)
	end)
	controls.comp_job_list:set_on_change_handler(function(text, new_index)
		cur_completed = new_index
		update_archive_ui(controls, cur_open, cur_completed)
	end)
	controls.close_job:set_on_click_handler(function(state)
		if cur_open == 0 or #open_jobs == 0 then return end
		table.insert(completed_jobs, open_jobs[cur_open])
		table.remove(open_jobs, cur_open)
		cur_open = math.min(cur_open, #open_jobs)
		cur_completed = math.max(cur_completed, 1)
		update_archive_ui(controls, cur_open, cur_completed)
	end)
	controls.reopen_job:set_on_click_handler(function(state)
		if cur_completed == 0 or #completed_jobs == 0 then return end
		table.insert(open_jobs, completed_jobs[cur_completed])
		table.remove(completed_jobs, cur_completed)
		cur_completed = math.min(cur_completed, #completed_jobs)
		cur_open = math.max(cur_open, 1)
		update_archive_ui(controls, cur_open, cur_completed)
	end)
	controls.delete_job:set_on_click_handler(function(state)
		if cur_open == 0 or #open_jobs == 0 then return end
		if safety_question() == true then
			table.remove(open_jobs, cur_open)
			cur_open = math.min(cur_open, #open_jobs)
			update_archive_ui(controls, cur_open, cur_completed)
		end
	end)
	controls.delete_comp_job:set_on_click_handler(function(state)
		if cur_completed == 0 or #completed_jobs == 0 then return end
		if safety_question() == true then
			table.remove(completed_jobs, cur_completed)
			cur_completed = math.min(cur_completed, #completed_jobs)
			update_archive_ui(controls, cur_open, cur_completed)
		end
	end)

end

function update_archive_ui(controls, cur_open, cur_completed)
	local open_exists = cur_open > 0 and #open_jobs > 0
	controls.job_list:reset_content()
	for i,k in ipairs(open_jobs) do
		controls.job_list:insert_control_item(k.name)
	end
	controls.job_list:enable_control(open_exists)
	controls.name:enable_control(open_exists)
	controls.customer:enable_control(open_exists)
	controls.date:enable_control(open_exists)
	controls.close_job:enable_control(open_exists)
	controls.delete_job:enable_control(open_exists)
	if open_exists then 
		controls.job_list:set_control_selection(cur_open)
		controls.name:set_control_text(open_jobs[cur_open].name)
		controls.customer:set_control_text(open_jobs[cur_open].customer)
		controls.date:set_control_text(open_jobs[cur_open].date)
	else 
		controls.name:set_control_text("")
		controls.customer:set_control_text("")
		controls.date:set_control_text("")
	end
---------
	local comp_exists = cur_completed > 0 or #completed_jobs > 0
	controls.comp_job_list:reset_content()
	for i,k in ipairs(completed_jobs) do
		controls.comp_job_list:insert_control_item(k.name)
	end
	controls.comp_job_list:enable_control(comp_exists)
	controls.comp_name:enable_control(comp_exists)
	controls.comp_customer:enable_control(comp_exists)
	controls.comp_date:enable_control(comp_exists)
	controls.reopen_job:enable_control(comp_exists)
	controls.delete_comp_job:enable_control(comp_exists)


	if comp_exists then 
		controls.comp_job_list:set_control_selection(cur_completed)
		controls.comp_name:set_control_text(completed_jobs[cur_completed].name)
		controls.comp_customer:set_control_text(completed_jobs[cur_completed].customer)
		controls.comp_date:set_control_text(completed_jobs[cur_completed].date)
	else 
		controls.comp_name:set_control_text("")
		controls.comp_customer:set_control_text("")
		controls.comp_date:set_control_text("")
	end

end

function create_default_question()
	local question_result = pyui.run_modal_subdialog(yes_no_question_dialog, 
													pyloc "Webshop", 
													pyloc "No jobs found! Load demo jobs?")
	if question_result == "ok" then 
		return true
	end
	return false
end
function safety_question()
	local question_result = pyui.run_modal_subdialog(yes_no_question_dialog, 
													pyloc "Webshop Archive", 
													pyloc "Permanently delete this job?")
	if question_result == "ok" then 
		return true
	end
	return false
end
function yes_no_question_dialog(dialog, title, question)
	dialog:set_window_title(title)
	dialog:create_standalone_label({1,2}, question)
	dialog:create_ok_button(1)
	dialog:create_cancel_button(2)
	dialog:equalize_column_widths({1,2})
end

function create_demo_table()
	return { 
		[1] = { 
			name = "Objects",
			customer = "Max Mustermann",
			date = "27.06.2022 13:12",
			objects = { 
				[1] = { 
					type = "block",
					length = 400,
					width = 19,
					height = 200,
					origin = {0,0,0},
				},
				[2] = { 
					type = "cylinder",
					height = 700,
					radius = 200,
					attributes = { 
						name = "A cylinder",
						price = 50,
					},
				origin = {1000,0,0},
				},	
			},
		},
		[2] = { 
			name = "NGO",
			customer = "Max Mustermann",
			date = "28.06.2022 18:12",
			objects = { 
				[1] = { 
					type = "ngo",
					attributes = { price = 1200,
						name = "Expensive NGO",
						["58"] = 3,
					},
				},
			},
		},
		[3] = { 
			name = "A library file",
			customer = "Fabian",
			date = "27.06.2022 12:46",
			objects = { 
				[1] = { 
					type = "pyo",
					file_handle = pyux.get_library_handle("library", "KitchenWizardLib", "Panels"),	--this folder should be preinstalled with parametrized panels with the keys 'length' and 'height' from the KitchenWizard
					origin = {0,0,0},
					attributes = { 
						name = "Cabinet 1",
					},
					parametrics = { 
						length = 600,
						height = 800,
					},
				},
				[2] = { 
					type = "pyo",
					file_handle = pyux.get_library_handle("library", "KitchenWizardLib", "Panels"),
					origin = {800,0,0},
					attributes = { 
						name = "Cabinet 2",
					},
					parametrics = { 
						length = 450,
						height = 450,
					},
				},
				[3] = {
					type = "pyo",
					file_handle = pyux.get_library_handle("library", "KitchenWizardLib", "Panels"),
					origin = {1600,0,0},
					attributes = { 
						name = "Cabinet 3",
					},
					parametrics = { 
						length = 600,
						height = 350,
					},
				},
			},
		},
	}
end