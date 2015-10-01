init!

function init
	# Settings
	scene = new THREE.Scene!
	width = window.inner-width
	height = window.inner-height
	#camera = new THREE.PerspectiveCamera 75 (width / height), 0.1 1000
	scale = 256
	camera = new THREE.OrthographicCamera -(width / scale), (width / scale), (height / scale), -(height / scale), -100, 100
	
	renderer = new THREE.WebGLRenderer {+antialias}
	renderer.set-pixel-ratio window.device-pixel-ratio
	renderer.set-size width, height
	renderer.auto-clear = off
	#renderer.set-clear-color new THREE.Color 0x8ebddb
	#renderer.set-clear-color new THREE.Color 0x051f2d
	renderer.shadow-map.enabled = on
	
	#document.get-element-by-id \main .append-child renderer.dom-element
	document.body.append-child renderer.dom-element

	# DEBUG GUIDE
	scene.add new THREE.AxisHelper 1000
	#scene.add new THREE.GridHelper 10 1
	
	init-sky!
	
	# SKY
	function init-sky
		sun-sphere = new THREE.Mesh do
			new THREE.SphereBufferGeometry 20000 16 8
			new THREE.MeshBasicMaterial {color: 0xffffff}
		sun-sphere.position.y = -700000
		sun-sphere.visible = no
		scene.add sun-sphere

		sky = new THREE.Sky!
		sky.uniforms.turbidity.value = 10
		sky.uniforms.reileigh.value = 4
		sky.uniforms.luminance.value = 1
		
		inclination = 0
		azimuth = 0

		theta = Math.PI * (inclination - 0.5)
		phi = 2 * Math.PI * (azimuth - 0.5)
		
		distance = 400000

		sun-sphere.position.x = distance * (Math.cos phi)
		sun-sphere.position.y = distance * (Math.sin phi) * (Math.sin theta)
		sun-sphere.position.z = distance * (Math.sin phi) * (Math.cos theta)
		
		sky.uniforms.sun-position.value.copy sun-sphere.position
		
		scene.add sky.mesh

	loader = new THREE.JSONLoader!
	loader.load '/resources/common/3d-models/milk/milk.json' (geometry, materials) ->
		geo = geometry
		mat = new THREE.MeshFaceMaterial materials
		mesh = new THREE.Mesh geo, mat
		mesh.position.set 0 0 0
		mesh.scale.set 1 1 1
		mesh.cast-shadow = on
		scene.add mesh

	loader = new THREE.ObjectLoader!
	loader.load '/resources/common/3d-models/desk/desk.json' (object) ->
		object.position.set -2.2 0 -1.9
		object.rotation.y = Math.PI
		scene.add object
	loader = new THREE.ObjectLoader!
	loader.load '/resources/common/3d-models/chair/chair.json' (object) ->
		object.position.set -1.8 0 -1.9
		object.rotation.y = - Math.PI / 2
		scene.add object
	loader = new THREE.ObjectLoader!
	loader.load '/resources/common/3d-models/monitor/monitor.json' (object) ->
		object.position.set -2.2 0.7 -1.9
		scene.add object
	loader.load '/resources/common/3d-models/keyboard/keyboard.json' (object) ->
		object.position.set -2 0.7 -1.9
		object.rotation.y = Math.PI
		scene.add object
	loader = new THREE.ObjectLoader!
	loader.load '/resources/common/3d-models/plant/plant.json' (object) ->
		object.position.set -2.3 0.7 -1.5
		scene.add object
	loader = new THREE.ObjectLoader!
	loader.load '/resources/common/3d-models/eraser/eraser.json' (object) ->
		object.position.set -2.1 0.7 -1.5
		scene.add object
	loader = new THREE.JSONLoader!
	loader.load '/resources/common/3d-models/milk/milk.json' (geometry, materials) ->
		geo = geometry
		mat = new THREE.MeshFaceMaterial materials
		mesh = new THREE.Mesh geo, mat
		mesh.position.set -2.3 0.7 -2.2
		mesh.rotation.y = - Math.PI / 8
		scene.add mesh
	loader = new THREE.ObjectLoader!
	loader.load '/resources/common/3d-models/facial-tissue/facial-tissue.json' (object) ->
		object.position.set -2.35 0.7 -2.35
		object.rotation.y = - Math.PI / 4
		scene.add object
	loader = new THREE.ObjectLoader!
	loader.load '/resources/common/3d-models/corkboard/corkboard.json' (object) ->
		object.position.set -2 0.9 -2.495
		object.rotation.y = Math.PI / 2
		scene.add object
	loader = new THREE.ObjectLoader!
	loader.load '/resources/common/3d-models/piano/piano.json' (object) ->
		object.position.set 0 0 -2.5
		object.rotation.y = Math.PI / 2
		scene.add object

	loader = new THREE.OBJMTLLoader!
	loader.load '/resources/common/3d-models/room/room.obj' '/resources/common/3d-models/room/room.mtl' (object) ->
		object.position.set 0 0 0
		#object.rotation.y = Math.PI
		object.cast-shadow = off
		object.receive-shadow = on
		scene.add object

	## Floor
	#floor-geometry = new THREE.CubeGeometry 5 0.25 5
	#floor-material = new THREE.MeshPhongMaterial {color: 0xdcc38d}
	#floor = new THREE.Mesh floor-geometry, floor-material
	#floor.receive-shadow = on
	#floor.position.set 0 -0.25 0
	#scene.add floor

	#floor-geometry = new THREE.CubeGeometry 5 0.125 5
	#floor-material = new THREE.MeshPhongMaterial {color: 0xEE7C6D}
	#floor = new THREE.Mesh floor-geometry, floor-material
	#floor.receive-shadow = on
	#floor.position.set 0 -0.0625 0
	#scene.add floor

	## Walls
	#wall1-geometry = new THREE.CubeGeometry 0.5 2 5
	#wall1-material = new THREE.MeshPhongMaterial {color: 0xFA861B}
	#wall1 = new THREE.Mesh wall1-geometry, wall1-material
	#wall1.receive-shadow = on
	#wall1.position.set -2.75 1 0
	#scene.add wall1
	#wall2-geometry = new THREE.CubeGeometry 5 2 0.5
	#wall2-material = new THREE.MeshPhongMaterial {color: 0xFA861B}
	#wall2 = new THREE.Mesh wall2-geometry, wall2-material
	#wall2.receive-shadow = on
	#wall2.position.set 0 1 -2.75
	#scene.add wall2

	# AmbientLight
	ambient-light = new THREE.AmbientLight 0xffffff 1
	ambient-light.cast-shadow = no
	scene.add ambient-light

	# Room light (for shadow)
	room-light = new THREE.SpotLight 0xffffff 0.8
	room-light.position.set 0, 3, 0
	room-light.cast-shadow = on
	room-light.shadow-map-width = 4096
	room-light.shadow-map-height = 4096
	room-light.shadow-camera-near = 0.1
	room-light.shadow-camera-far = 16
	room-light.shadow-camera-fov = 135
	#room-light.only-shadow = on
	#room-light.shadow-camera-visible = on #debug
	scene.add room-light

	room-light = new THREE.SpotLight 0xffffff 0.5
	room-light.position.set 8, 3, -2
	room-light.cast-shadow = on
	room-light.shadow-map-width = 4096
	room-light.shadow-map-height = 4096
	room-light.shadow-camera-near = 0.1
	room-light.shadow-camera-far = 16
	room-light.shadow-camera-fov = 135
	#room-light.only-shadow = on
	#room-light.shadow-camera-visible = on #debug
	scene.add room-light

	# Camera setting
	camera.position.x = 2
	camera.position.y = 2
	camera.position.z = 2
	scene.add camera

	# Controller setting
	controls = new THREE.OrbitControls camera
	controls.target.set 0 1 0
	controls.enable-zoom = no
	controls.enable-pan = no
	controls.min-polar-angle = 0
	controls.max-polar-angle = Math.PI / 2
	controls.min-azimuth-angle = 0
	controls.max-azimuth-angle = Math.PI / 2

	parameters = {
		min-filter: THREE.LinearFilter
		mag-filter: THREE.LinearFilter
		format: THREE.RGBFormat
		-stencil-buffer
	}
	render-target = new THREE.WebGLRenderTarget width, height, parameters

	composer = new THREE.EffectComposer renderer, render-target
	composer.add-pass new THREE.RenderPass scene, camera
	composer.add-pass new THREE.BloomPass 0.5 25 64.0 512
	fxaa = new THREE.ShaderPass THREE.FXAAShader
	fxaa.uniforms['resolution'].value = new THREE.Vector2 (1 / width), (1 / height)
	composer.add-pass fxaa
	to-screen = new THREE.ShaderPass THREE.CopyShader
	to-screen.render-to-screen = on
	composer.add-pass to-screen
	
	render!

	# Renderer
	function render
		request-animation-frame render
		controls.update!
		renderer.clear!
		composer.render!