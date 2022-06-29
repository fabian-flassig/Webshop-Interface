# Webshop-Interface
 **A demo of how to implement a Webshop interface as a PYTHA plugin

## Introduction

PYTHA offers a Webshop interface in XML language. This interface can e.g. load parametrized library elements, create some geometry primitives or assign attributes.

This PYTHA plugin acts as an example of how to implement similar functionality via the Lua Api. It mainly consists of two parts: the interface itself and an archive, where the completed jobs are managed. 

## The Webshop Import

This plugin function offers a simple user interface that allows to select an open job and gives some information on that job. The results are directly displayed in PYTHA. Pressing OK will generate the geometry and transfer the job to the archive. 

## The Webshop Archive

Here, open and completed jobs can be managed. Open jobs can be closed or deleted, while completed jobs can also be reopened. No geometry is created via this plugin.

## The Web Interface

Currently, PYTHA plugins have very limited file I/O operations. The [pyio.save_values](https://github.com/pytha-3d-cad/pytha-lua-api/wiki/pyio.save_values) and [pyio.load_values](https://github.com/pytha-3d-cad/pytha-lua-api/wiki/pyio.load_values) functions can be used to access the local storage of the plugins (plugin-settings/plugin-GUID). Different Lua tables can be stored and opened, where each lua table is saved in an individual file. 

### Multiple open jobs
The current implementation of the interface requires each open job to be inserted as a table in the 'open_jobs.lua' table with consecutive numerical keys.    

### Job information
Each job can contain key-value pairs representing customizable information like project name, customer name, address or order date that is displayed in the user interface and can be e.g. transfered to the PYTHA project header ([pytha.set_project_header](https://github.com/pytha-3d-cad/pytha-lua-api/wiki/pytha.set_project_header)).

```lua
{
  name = "Job 1",
  customer = "John Doe",
  ...
}
```

### Geometry objects
The geometry information is stored under the table key `objects`. Each object is represented as an individual table with the key `type` identifying the type of object. Currently implemented types are `"pyo"`, `"ngo"`, `"block"` and `"cylinder"`. Additional types can be implemented similar to these types. Depending on the type, additional keys are required:
#### `type = "pyo"` 
`type` | Required | Optional | Description
---|---|---|---
`pyo` | `file_handle` | `origin`, `attributes`, `parametrics` |  

```lua
{ 
  [1] = { 
		name = "Job 1 with NGO",
		customer = "John Doe",
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
	[2] = { 
		name = "A library file",
		customer = "Fabian",
		date = "27.06.2022 12:46",
		objects = { 
			[1] = { 
				type = "pyo",
				file_handle = __pytha_load_directory_handle("C:\\Users\\fflas\\Desktop\\parametrik.pyo", "parametrik.pyo"),
				origin = {0,0,0},
				attributes = { 
					name = "Cabinet 1",
				},
				parametrics = { 
					hoehe = 2000,
				},
			},
			[2] = { 
				type = "pyo",
				file_handle = __pytha_load_directory_handle("C:\\Users\\fflas\\Desktop\\parametrik.pyo", "parametrik.pyo"),
				origin = {1080,0,0},
				attributes = { 
					name = "Cabinet 2",
				},
				parametrics = { 
					hoehe = 1500,
				},
			},
		},
	},
	[3] = { 
		name = "Objects",
		customer = "Jane Doe",
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
}
```
