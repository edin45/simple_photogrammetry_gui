// Copyright (c) 1998-2021
// Utrecht University (The Netherlands),
// ETH Zurich (Switzerland),
// INRIA Sophia-Antipolis (France),
// Max-Planck-Institute Saarbruecken (Germany),
// and Tel-Aviv University (Israel).  All rights reserved.
//
// This file is part of CGAL (www.cgal.org)
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Distance_3/include/CGAL/Distance_3/Weighted_point_3_Weighted_point_3.h $
// $Id: Weighted_point_3_Weighted_point_3.h cf15bbe 2021-05-07T19:22:00+02:00 Mael Rouxel-Labbé
// SPDX-License-Identifier: LGPL-3.0-or-later OR LicenseRef-Commercial
//
//
// Author(s)     : Geert-Jan Giezeman, Andreas Fabri

#ifndef CGAL_DISTANCE_3_WEIGHTED_POINT_3_WEIGHTED_POINT_3_H
#define CGAL_DISTANCE_3_WEIGHTED_POINT_3_WEIGHTED_POINT_3_H

#include <CGAL/Weighted_point_3.h>

namespace CGAL {

template <class K>
inline
typename K::FT
squared_distance(const Weighted_point_3<K>& wpt1,
                 const Weighted_point_3<K>& wpt2)
{
  return K().compute_squared_distance_3_object()(wpt1.point(), wpt2.point());
}

} // namespace CGAL

#endif // CGAL_DISTANCE_3_WEIGHTED_POINT_3_WEIGHTED_POINT_3_H
