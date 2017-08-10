/*  
[INFO] 

NAME = Ortho Material Renamer
VERSION = 1.0.1
AUTHOR = Vasily Lukyanenko
DEV = VISCO
HELP = 
[INSTALL]

MACRO=OrhtoMaterialRenamer
CAT=VISCO
TEXT=Ortho Material Renamer
ICON=#("PhysX_Main", 4)

[1.0.0]

* First release =

[1.0.1]

+ Added: Custom Extension option=

[ABOUT]
Material and texture renamer/relinker to provide automatic import of orthos into UE4=

[TEST]

[SCRIPT]
*/	


try(closeRolloutFloater fOrthoMaterialRenamer)catch()
global fOrthoMaterialRenamer = newRolloutFloater "Ortho Material Renamer" 220 500

global _rOrthoMaterialRenamer

fn getScriptInfo s releaseInfo: "" =
(		
	if(releaseInfo != "") do
	(
		r = getINISetting s releaseInfo
		return r
	)
	
	v = getINISetting s "INFO" "VERSION"
	a = getINISetting s "INFO" "AUTHOR"
	n = getINISetting s "INFO" "NAME"
	o = getINISetting s "ABOUT"
	c = getINISetting s "INFO" "DEV"
	h = getINISetting s "INFO" "HELP"
	
	r = for i in (getINISetting s) where i != "ABOUT" and i != "SCRIPT" and i != "COPY" collect i
	
	return #(n, a, v, o, r, c, h)
)


global meshSample = #()

fn showPreview =
(
	meshSample = #()
	
	s = selection as array
	if(s.count == 0) do
	(
		_rOrthoMaterialRenamer.lblPreviewMaterial.caption = ""
		_rOrthoMaterialRenamer.lblPreviewMesh.caption = ""
		_rOrthoMaterialRenamer.lblPreviewTex.caption = ""
		
		return false
	)
	
	meshSample[1] = s[1].name
	meshSample[2]  = undefined
	meshSample[3]  = undefined
	
	if(s[1].material != undefined and classOf s[1].material.diffuseMap == BitmapTex) do
	(
		d = s[1].material.diffuseMap.filename
		meshSample[2]  = getFilenamePath d
		meshSample[3]  = getFilenameType  d
	)
	
	_rOrthoMaterialRenamer.showSamplePreview()
)	


rollout _rOrthoMaterialRenamer  "Renamer Parameters" category:1
(	
	group "Settings"
	(
		label lbl1 "Delete prefix from mesh name:" align: #left
		edittext edtMeshDelPrefix "" align: #left
		
		label lbl2 "New Material prefix:" align: #left
		edittext edtMatPrefix "" align: #left
		
		label lbl3 "New Texture prefix and postfix:" align: #left
		edittext edtTexPrefix "" align: #left across: 2
		edittext edtTexPostfix "" align: #left
		checkbox cbxCustomExt "Extension:" across: 2 offset: [0, 4]
		dropdownlist ddlCustomExt "" items: #(".jpg", ".png", ".bmp", ".dds", ".tga", ".tif") enabled: false	
	)		
	
	label lblDummy1 ""
	
	group "Preview Mesh Name"
	(
		label lblPreviewMesh "Select Objects"
	)
	
	group "Preview Material Name"
	(
		label lblPreviewMaterial "Select Objects"
	)
	
	group "Preview Texture Name"
	(
		label lblPreviewTex "Select Objects"
	)
	
	button btnRename "Rename" width: 190 height: 35 offset: [0, 25]
	
	fn showSamplePreview =
	(
		if(meshSample.count == 0) do return false
		n = trimLeft meshSample[1] (edtMeshDelPrefix.text)
		
		lblPreviewMesh.caption = n
		lblPreviewMaterial.caption = edtMatPrefix.text + n
		
		if(meshSample[2] != undefined) do
		(
			ext = meshSample[3]
			if(cbxCustomExt.checked) do ext = ddlCustomExt.selected
			
			lblPreviewTex.caption = edtTexPrefix.text + n + edtTexPostfix.text + ext
		)		
	)
	
	on edtMeshDelPrefix changed v do showSamplePreview()
	on edtMatPrefix changed v do showSamplePreview()
	on edtMeshDelPrefix changed v do showSamplePreview()
	on edtTexPrefix changed v do showSamplePreview()
	on edtTexPostfix changed v do showSamplePreview()
	on ddlCustomExt selected v do showSamplePreview()
	on cbxCustomExt changed v do 
	(	
		ddlCustomExt.enabled = v
		showSamplePreview()
	)
	
		
	on _rOrthoMaterialRenamer close do
	(
		callbacks.removescripts id:#selectionSetChanged0
	)
	
	on _rOrthoMaterialRenamer open do
	(
		callbacks.removescripts id:#selectionSetChanged0
								
		callbacks.addScript #selectionSetChanged "showPreview()" id:#selectionSetChanged0 persistent:false	
		
		showPreview()
	)
	
	on btnRename pressed do
	(
		s = selection as array
		
		if(s.count == 0) do return messageBox "Please select objects!" title: "Warning!"
		
		for i in s where i.material != undefined and classOf i.material == Standard and classOf i.material.diffuseMap == BitmapTex do
		(
			meshDelPrefix = edtMeshDelPrefix.text
			matPrefix = edtMatPrefix.text
			texPrefix = edtTexPrefix.text
			texPostfix = edtTexPostfix.text
			
			n = trimLeft i.name meshDelPrefix
			d = i.material.diffuseMap.filename
			
			texName = getFilenamePath d
			texExt = getFilenameType d
			if(cbxCustomExt.checked) do texExt = ddlCustomExt.selected
			
			texPath = getFilenamePath d
			
			newFileName = texPath + texPrefix + n + texPostfix + texExt
			newMatName = matPrefix + n
			
			i.material.name = newMatName
			i.material.diffuseMap.filename = newFileName
		)
	)
)


rollout _rAbout "About" category:2
(
	label lblName "" 
	label lblVer "" 
	
	label lblAuthor "" height: 30
	label lblCopy ""  height: 30
	
	on _rAbout open do
	(	
		i = getScriptInfo (getThisScriptFilename())
			
		lblName.caption = i[1]
		lblAuthor.caption = i[2]
		lblVer.caption = i[3]
		lblCopy.caption = i[6]
	)
)

addRollout _rOrthoMaterialRenamer fOrthoMaterialRenamer rolledUp:false
addRollout _rAbout fOrthoMaterialRenamer rolledUp:true
