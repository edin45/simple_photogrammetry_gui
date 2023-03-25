import os
import pymeshlab
import optparse

parser = optparse.OptionParser()
parser.add_option("-m","--mesh",action="store",help="To be textured mesh")
parser.add_option("-p","--project",action="store",help="Project")
parser.add_option("-o","--output_folder",action="store",help="Folder where Results are stored")

options, args = parser.parse_args()

output_folder = options.output_folder
project = options.project
mesh = options.mesh

ms = pymeshlab.MeshSet()
print("opening project...")
ms.load_project(project)
print('reading...')
ms.load_new_mesh(mesh)
print('repair non manifold...')
ms.meshing_repair_non_manifold_edges()
print('texturing...')
ms.compute_texcoord_parametrization_and_texture_from_registered_rasters(texturesize=10240,colorcorrection=True,colorcorrectionfiltersize=1,usedistanceweight=True,useimgborderweight=True,usealphaweight=False,cleanisolatedtriangles=True,stretchingallowed=False,texturegutter=4)
print('saving')
ms.save_current_mesh(os.path.join(output_folder,"textured.obj"))