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
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Intersections_3/include/CGAL/Intersections_3/Line_3_Plane_3.h $
// $Id: Line_3_Plane_3.h c2d1adf 2021-06-23T17:34:48+02:00 Mael Rouxel-Labbé
// SPDX-License-Identifier: LGPL-3.0-or-later OR LicenseRef-Commercial
//
//
// Author(s)     : Sebastien Loriot
//

#ifndef CGAL_INTERSECTIONS_3_LINE_PLANE_3_H
#define CGAL_INTERSECTIONS_3_LINE_PLANE_3_H

#include <CGAL/Intersection_traits.h>
#include <CGAL/Intersections_3/internal/Line_3_Plane_3_do_intersect.h>
#include <CGAL/Intersections_3/internal/Line_3_Plane_3_intersection.h>

#include <CGAL/Line_3.h>
#include <CGAL/Plane_3.h>

#include <boost/optional.hpp>

namespace CGAL {

CGAL_DO_INTERSECT_FUNCTION(Line_3, Plane_3, 3)
CGAL_INTERSECTION_FUNCTION(Line_3, Plane_3, 3)

template <class K>
inline
boost::optional<typename K::Point_3>
intersection_point_for_polyhedral_envelope(const Plane_3<K>& plane,
                                           const Line_3<K>& line)
{
  return K().intersect_point_3_for_polyhedral_envelope_object()(plane, line);
}

template <class K>
inline
boost::optional<typename K::Point_3>
intersection_point_for_polyhedral_envelope(const Line_3<K>& line,
                                           const Plane_3<K>& plane)
{
  return K().intersect_point_3_for_polyhedral_envelope_object()(plane, line);
}

} // namespace CGAL

#endif // CGAL_INTERSECTIONS_3_LINE_PLANE_3_H
