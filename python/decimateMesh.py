import os
import pymeshlab
import optparse

parser = optparse.OptionParser()
parser.add_option("-m","--mesh",action="store",help="To be textured mesh")
parser.add_option("-o","--output_folder",action="store",help="Folder where Results are stored")
parser.add_option("-t","--face_reduction_factor",action="store",help="face reduction factor (0 = disabled)")
options, args = parser.parse_args()
output_folder = options.output_folder
mesh = options.mesh
face_reduction_factor = float(options.face_reduction_factor)

ms = pymeshlab.MeshSet()
print('reading...')
ms.load_new_mesh(mesh)
ms.meshing_decimation_quadric_edge_collapse(targetfacenum=int(ms.current_mesh().face_number()/face_reduction_factor))
print('saving')
ms.save_current_mesh(os.path.join(output_folder,"model_surface_decimated.ply"))