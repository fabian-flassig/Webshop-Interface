# Webshop-Interface
A demo of how to implement a Webshop interface as a PYTHA plugin

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
Key | Type | Description
---|---|---
`file_handle` | Required | `__pytha_load_directory_handle(file_path, file_name)` is used to create a file handle 
`parametrics` | Optional | A table containing key-value pairs for the parametrics of the pyo-file 
`attributes` | Optional | A table containing [attributes](https://github.com/pytha-3d-cad/pytha-lua-api/wiki/pytha.set_element_attributes) being assigned to the loaded objects. Can be modified to affect only e.g. the topmost group 
`origin` | Optional | The relative origin coordinates `{x,y,z}` at which the object is inserted

#### `type = "ngo"` 
Key | Type | Description
---|---|---
`attributes` | Optional | A table containing [attributes](https://github.com/pytha-3d-cad/pytha-lua-api/wiki/pytha.set_element_attributes) being assigned to the created NGO's. 

At least one attribute should be assigned for the NGO to make sense.

#### `type = "block"` 
Key | Type | Description
---|---|---
`length` | Required | Length of the block
`width` | Required | Width of the block
`height` | Required | Height of the block
`attributes` | Optional | A table containing [attributes](https://github.com/pytha-3d-cad/pytha-lua-api/wiki/pytha.set_element_attributes) being assigned to the created block. 
`origin` | Optional | The relative origin coordinates `{x,y,z}` at which the block is created

#### `type = "cylinder"` 
Key | Type | Description
---|---|---
`height` | Required | Height of the cylinder
`radius` | Required | Radius of the cylinder
`attributes` | Optional | A table containing [attributes](https://github.com/pytha-3d-cad/pytha-lua-api/wiki/pytha.set_element_attributes) being assigned to the created cylinder. 
`origin` | Optional | The relative origin coordinates `{x,y,z}` at which the cylinder is created

#### Example
An example for an open job queue is given in the following. The numeric keys to the tables are optional and can be omitted, but are displayed here for better visual distinction. Adding a new job to that list requires its insertion before the final closing braces.

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
				file_handle = __pytha_load_directory_handle("C:\\Users\\fabian\\Desktop\\parametrics.pyo", "parametrics.pyo"),
				origin = {0,0,0},
				attributes = { 
					name = "Cabinet 1",
				},
				parametrics = { 
					height = 2000,
				},
			},
			[2] = { 
				type = "pyo",
				file_handle = __pytha_load_directory_handle("C:\\Users\\fabian\\Desktop\\parametrics.pyo", "parametrics.pyo"),
				origin = {1080,0,0},
				attributes = { 
					name = "Cabinet 2",
				},
				parametrics = { 
					height = 1500,
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
## Final remarks
The options given here are intended for demonstration purposes only and should be modified accordingly before implementation to fit the specific requirements. Grouping of objects has been omitted, but can in principle be included as a new type of objects that itself can have a table of objects. Check the [>>>documentation<<<](https://github.com/pytha-3d-cad/pytha-lua-api/wiki) for the range of features that can be implemented.
