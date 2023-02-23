// Copyright (c) 2020  GeometryFactory (France).
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org).
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Orthtree/include/CGAL/Octree.h $
// $Id: Octree.h 4d761ed 2021-04-01T14:21:01+02:00 Simon Giraudot
// SPDX-License-Identifier: GPL-3.0-or-later OR LicenseRef-Commercial
//
// Author(s)     : Simon Giraudot

#ifndef CGAL_OCTREE_H
#define CGAL_OCTREE_H

#include <CGAL/license/Orthtree.h>

#include <CGAL/Orthtree.h>
#include <CGAL/Orthtree_traits_3.h>

namespace CGAL {

/*!
  \ingroup PkgOrthtreeClasses

  \brief Alias that specializes the `Orthtree` class to a 3D octree.

  These two types are exactly equivalent:
  - `Octree<GeomTraits, PointRange, PointMap>`
  - `Orthtree<Orthtree_traits_3<GeomTraits>, PointRange, PointMap>`.

  \warning This is a not a real class but an alias, please refer to
  the documentation of `Orthtree`.

  \tparam GeomTraits must be a model of `Kernel`
  \tparam PointRange_ must be a model of range whose value type is the key type of `PointMap`
  \tparam PointMap must be a model of `ReadablePropertyMap` whose value type is `GeomTraits::Point_3`
 */
template <typename GeomTraits, typename PointRange,
          typename PointMap = Identity_property_map
         <typename std::iterator_traits<typename PointRange::iterator>::value_type> >
#ifdef DOXYGEN_RUNNING
class Octree;
#else
using Octree = Orthtree<Orthtree_traits_3<GeomTraits>, PointRange, PointMap>;
#endif

} // namespace CGAL


#endif // CGAL_OCTREE_H
