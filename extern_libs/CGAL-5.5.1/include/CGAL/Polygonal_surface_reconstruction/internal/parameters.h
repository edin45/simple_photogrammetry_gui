// Copyright (c) 2018  Liangliang Nan. All rights reserved.
//
// This file is part of CGAL (www.cgal.org)
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Polygonal_surface_reconstruction/include/CGAL/Polygonal_surface_reconstruction/internal/parameters.h $
// $Id: parameters.h 98e4718 2021-08-26T11:33:39+02:00 Sébastien Loriot
// SPDX-License-Identifier: LGPL-3.0-or-later OR LicenseRef-Commercial
//
// Author(s) : Liangliang Nan

#ifndef CGAL_POLYGONAL_SURFACE_RECONSTRUCTION_PARAMETERS_H
#define CGAL_POLYGONAL_SURFACE_RECONSTRUCTION_PARAMETERS_H

#include <CGAL/license/Polygonal_surface_reconstruction.h>

namespace CGAL {

        /// When an intersecting point (at an edge, computed from a plane and an edge)
        /// is very close to an existing vertex (i.e., an end point of an edge), we
        /// snap the intersecting point to the existing vertex. This way we can avoid
        /// many thin faces.
        /// \note Value really doesn't matter as long as it is small (default is 1e-10).
        ///       So this parameter is not intended to be changed by the user.
        template <class FT>
        FT snap_squared_distance_threshold() {
                return FT(1e-10);
        }


} //namespace CGAL

#endif // CGAL_POLYGONAL_SURFACE_RECONSTRUCTION_PARAMETERS_H
