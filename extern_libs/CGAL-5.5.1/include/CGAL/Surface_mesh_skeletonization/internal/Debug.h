// Copyright (c) 2013  GeometryFactory (France). All rights reserved.
//
// This file is part of CGAL (www.cgal.org).
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Surface_mesh_skeletonization/include/CGAL/Surface_mesh_skeletonization/internal/Debug.h $
// $Id: Debug.h 98e4718 2021-08-26T11:33:39+02:00 Sébastien Loriot
// SPDX-License-Identifier: GPL-3.0-or-later OR LicenseRef-Commercial
//
// Author(s)     : Xiang Gao <gaox@ethz.ch>
//

#ifndef CGAL_MCFSKEL_DEBUG_H
#define CGAL_MCFSKEL_DEBUG_H

#include <CGAL/license/Surface_mesh_skeletonization.h>


/// @cond CGAL_DOCUMENT_INTERNAL

/**
 * @file Debug.h
 * @brief This file contains some macro used to hide/show the log for debugging
 * purpose.
 *
 */

// enable debugging output statement
// this is for locating bugs
//#define CGAL_MCFSKEL_DEBUG

// enable info output statement
// this is for tuning parameters
//#define CGAL_MCFSKEL_INFO

#ifdef CGAL_MCFSKEL_DEBUG
#define MCFSKEL_DEBUG(x) x
#else
#define MCFSKEL_DEBUG(x)
#endif

#ifdef CGAL_MCFSKEL_INFO
#define MCFSKEL_INFO(x) x
#else
#define MCFSKEL_INFO(x)
#endif

/// @endcond

#endif // CGAL_MCFSKEL_DEBUG_H
