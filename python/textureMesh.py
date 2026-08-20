import os
import pymeshlab
import optparse

parser = optparse.OptionParser()
parser.add_option("-p","--project",action="store",help="Input Project")
parser.add_option("-m","--mesh",action="store",help="To be textured mesh")
parser.add_option("-o","--output_folder",action="store",help="Folder where Results are stored")
parser.add_option("-t","--face_reduction_factor",action="store",help="face reduction factor (0 = disabled)")
options, args = parser.parse_args()
project = options.project
output_folder = options.output_folder
mesh = options.mesh
face_reduction_factor = float(options.face_reduction_factor)

ms = pymeshlab.MeshSet()
print("loading project...")
ms.load_project(project)
# ms.load_project(['bundle.rd.out', 'cams.txt'])
# print(ms.number_rasters())
ms.delete_current_mesh()
print('reading...')
ms.load_new_mesh(mesh)
if(face_reduction_factor != 0):
    ms.meshing_decimation_quadric_edge_collapse(targetfacenum=int(ms.current_mesh().face_number()/face_reduction_factor))
# ms.set_current_mesh(new_curr_id=1)
print('texturing')
ms.meshing_repair_non_manifold_edges()
ms.compute_texcoord_parametrization_and_texture_from_registered_rasters(texturesize=8192,texturename="texture.jpg")
print('saving')
ms.save_current_mesh(os.path.join(output_folder,"textured.obj"))
# mesh(self: pmeshlab.MeshSet, id: int) → pmeshlab.Mesh