// Copyright (c) 2018  GeometryFactory Sarl (France).
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org)
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Intersections_3/include/CGAL/Intersections_3/internal/Tetrahedron_3_Unbounded_3_do_intersect.h $
// $Id: Tetrahedron_3_Unbounded_3_do_intersect.h c2d1adf 2021-06-23T17:34:48+02:00 Mael Rouxel-Labbé
// SPDX-License-Identifier: LGPL-3.0-or-later OR LicenseRef-Commercial
//
//
// Author(s)     : Andreas Fabri

#ifndef CGAL_INTERNAL_INTERSECTIONS_3_TETRAHEDRON_3_DO_INTERSECT_H
#define CGAL_INTERNAL_INTERSECTIONS_3_TETRAHEDRON_3_DO_INTERSECT_H

#include <CGAL/Intersections_3/internal/Line_3_Triangle_3_do_intersect.h>
#include <CGAL/Intersections_3/internal/Plane_3_Triangle_3_do_intersect.h>
#include <CGAL/Intersections_3/internal/Ray_3_Triangle_3_do_intersect.h>
#include <CGAL/Intersections_3/internal/Sphere_3_Triangle_3_do_intersect.h>

namespace CGAL {
namespace Intersections {
namespace internal {

template<typename K, class Unbounded>
typename K::Boolean
do_intersect_tetrahedron_unbounded(const typename K::Tetrahedron_3& tet,
                                   const Unbounded& unb,
                                   const K& k)
{
  typedef typename K::Boolean Boolean;

  Boolean result = false;
  for(int i = 0; i < 4; ++i)
  {
    const Boolean b = do_intersect(unb,
                                   k.construct_triangle_3_object()(tet[i],
                                                                   tet[(i+1)%4],
                                                                   tet[(i+2)%4]),
                                   k);
    if(certainly(b))
      return b;

    if(is_indeterminate(b))
      result = b;
  }

  return result;
}

} // namespace internal
} // namespace Intersections
} // namespace CGAL

#endif // CGAL_INTERNAL_INTERSECTIONS_3_TETRAHEDRON_3_DO_INTERSECT_H
