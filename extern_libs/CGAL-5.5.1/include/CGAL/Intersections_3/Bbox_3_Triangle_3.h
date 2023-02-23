// Copyright (c) 1997-2021
// Utrecht University (The Netherlands),
// ETH Zurich (Switzerland),
// INRIA Sophia-Antipolis (France),
// Max-Planck-Institute Saarbruecken (Germany),
// and Tel-Aviv University (Israel).
// GeometryFactory (France)
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org)
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Intersections_3/include/CGAL/Intersections_3/Bbox_3_Triangle_3.h $
// $Id: Bbox_3_Triangle_3.h c2d1adf 2021-06-23T17:34:48+02:00 Mael Rouxel-Labbé
// SPDX-License-Identifier: LGPL-3.0-or-later OR LicenseRef-Commercial
//
//
// Author(s)     : Sebastien Loriot
//

#ifndef CGAL_INTERSECTIONS_3_BBOX_3_TRIANGLE_3_H
#define CGAL_INTERSECTIONS_3_BBOX_3_TRIANGLE_3_H

#include <CGAL/Bbox_3.h>
#include <CGAL/Triangle_3.h>

#include <CGAL/Intersections_3/internal/Bbox_3_Triangle_3_do_intersect.h>
#include <CGAL/Intersections_3/internal/Iso_cuboid_3_Triangle_3_intersection.h>

namespace CGAL {

template<typename K>
bool do_intersect(const CGAL::Bbox_3& box,
                  const Triangle_3<K>& tr)
{
  return K().do_intersect_3_object()(box, tr);
}

template<typename K>
bool do_intersect(const Triangle_3<K>& tr,
                  const CGAL::Bbox_3& box)
{
  return K().do_intersect_3_object()(tr, box);
}

template<typename K>
typename Intersection_traits<K, typename K::Triangle_3, Bbox_3>::result_type
intersection(const CGAL::Bbox_3& box,
             const Triangle_3<K>& tr)
{
  // @fixme illegal for non-CGAL kernels
  typename K::Iso_cuboid_3 cub(box.xmin(), box.ymin(), box.zmin(),
                               box.xmax(), box.ymax(), box.zmax());
  return typename K::Intersect_3()(cub, tr);
}

template<typename K>
typename Intersection_traits<K, typename K::Triangle_3, Bbox_3>::result_type
intersection(const Triangle_3<K>& tr,
             const CGAL::Bbox_3& box)
{
  return intersection(box, tr);
}

} // namespace CGAL

#endif // CGAL_INTERSECTIONS_3_BBOX_3_TRIANGLE_3_H
