// Copyright (c) 2001 GeometryFactory(France).
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org)
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Intersections_3/include/CGAL/Intersections_3/internal/Tetrahedron_3_Triangle_3_do_intersect.h $
// $Id: Tetrahedron_3_Triangle_3_do_intersect.h c2d1adf 2021-06-23T17:34:48+02:00 Mael Rouxel-Labbé
// SPDX-License-Identifier: LGPL-3.0-or-later OR LicenseRef-Commercial
//
//
// Author(s)     : Nico Kruithof

#ifndef CGAL_INTERNAL_INTERSECTIONS_3_TETRAHEDRON_3_TRIANGLE_3_DO_INTERSECT_H
#define CGAL_INTERNAL_INTERSECTIONS_3_TETRAHEDRON_3_TRIANGLE_3_DO_INTERSECT_H

#include <CGAL/Intersections_3/internal/Tetrahedron_3_Bounded_3_do_intersect.h>

namespace CGAL {
namespace Intersections {
namespace internal {

template <class K, class Bounded>
typename K::Boolean
do_intersect_tetrahedron_bounded(const Bounded& tr,
                                 const typename K::Tetrahedron_3& tet,
                                 const typename K::Point_3& p,
                                 const K& k);

template <class K>
inline
typename K::Boolean
do_intersect(const typename K::Tetrahedron_3& tet,
             const typename K::Triangle_3& tr,
             const K& k)
{
  return do_intersect_tetrahedron_bounded(tr, tet, tr[0], k);
}

template <class K>
inline
typename K::Boolean
do_intersect(const typename K::Triangle_3& tr,
             const typename K::Tetrahedron_3& tet,
             const K& k)
{
  return do_intersect_tetrahedron_bounded(tr, tet, tr[0], k);
}

} // namespace internal
} // namespace Intersections
} // namespace CGAL

#endif // CGAL_INTERNAL_INTERSECTIONS_3_TETRAHEDRON_3_TRIANGLE_3_DO_INTERSECT_H
