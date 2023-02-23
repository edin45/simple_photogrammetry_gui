// Copyright (c) 2018 INRIA Sophia-Antipolis (France)
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org)
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Intersections_3/include/CGAL/Intersections_3/internal/Line_3_Segment_3_do_intersect.h $
// $Id: Line_3_Segment_3_do_intersect.h c2d1adf 2021-06-23T17:34:48+02:00 Mael Rouxel-Labbé
// SPDX-License-Identifier: LGPL-3.0-or-later OR LicenseRef-Commercial
//
//
// Author(s)     : Sébastien Loriot

#ifndef CGAL_INTERNAL_INTERSECTIONS_3_LINE_3_SEGMENT_3_DO_INTERSECT_H
#define CGAL_INTERNAL_INTERSECTIONS_3_LINE_3_SEGMENT_3_DO_INTERSECT_H

#include <CGAL/Intersections_3/internal/Line_3_Line_3_do_intersect.h>

#include <CGAL/enum.h>
#include <CGAL/kernel_assertions.h>

namespace CGAL {
namespace Intersections {
namespace internal {

template <class K>
inline
bool
do_intersect(const typename K::Line_3& l,
             const typename K::Segment_3& s,
             const K& k)
{
  CGAL_precondition(!l.is_degenerate() && !s.is_degenerate());

  bool b = do_intersect(l, s.supporting_line(), k);
  if(b)
  {
    // supporting_line intersects: points are coplanar
    typename K::Coplanar_orientation_3 cpl_orient = k.coplanar_orientation_3_object();
    const typename K::Point_3& p1 = l.point(0);
    const typename K::Point_3& p2 = l.point(1);
    ::CGAL::Orientation or1 = cpl_orient(p1, p2, s[0]);

    if(or1 == COLLINEAR)
      return true;

    ::CGAL::Orientation or2 = cpl_orient(p1, p2, s[1]);
    return (or1 != or2);
  }

  return false;
}

template <class K>
inline
bool
do_intersect(const typename K::Segment_3& s,
             const typename K::Line_3& l,
             const K& k)
{
  return do_intersect(l,s,k);
}

} // namespace internal
} // namespace Intersections
} // namespace CGAL

#endif // CGAL_INTERNAL_INTERSECTIONS_3_LINE_3_SEGMENT_3_DO_INTERSECT_H
