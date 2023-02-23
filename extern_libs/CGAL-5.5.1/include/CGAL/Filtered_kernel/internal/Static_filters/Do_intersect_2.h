// Copyright (c) 2008 ETH Zurich (Switzerland)
// Copyright (c) 2008-2009 INRIA Sophia-Antipolis (France)
// Copyright (c) 2017 GeometryFactory Sarl (France)
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org)
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Filtered_kernel/include/CGAL/Filtered_kernel/internal/Static_filters/Do_intersect_2.h $
// $Id: Do_intersect_2.h 5945e48 2021-09-17T08:14:06+02:00 Sébastien Loriot
// SPDX-License-Identifier: LGPL-3.0-or-later OR LicenseRef-Commercial
//
//
// Author(s)     : Andreas Fabri, Laurent Rineau


#ifndef CGAL_INTERNAL_STATIC_FILTERS_DO_INTERSECT_2_H
#define CGAL_INTERNAL_STATIC_FILTERS_DO_INTERSECT_2_H

#include <iostream>

namespace CGAL {

namespace internal {

namespace Static_filters_predicates {

template < typename K_base, typename SFK >
class Do_intersect_2
  : public K_base::Do_intersect_2
{
  typedef typename K_base::Point_2   Point_2;
  typedef typename K_base::Segment_2 Segment_2;
  typedef typename K_base::Do_intersect_2 Base;

  typedef K_base TA1;
  typedef SFK TA2;
public:

  typedef typename Base::result_type  result_type;

  using Base::operator();

  // The internal::do_intersect(..) function
  // only performs orientation tests on the vertices
  // of the segment
  // By calling the do_intersect function with
  // the  statically filtered kernel we avoid
  // that doubles are put into Interval_nt
  // to get taken out again with fit_in_double
  result_type
  operator()(const Segment_2 &s, const Segment_2& t) const
  {
    return Intersections::internal::do_intersect(s,t, SFK());
  }

  result_type
  operator()(const Point_2 &p, const Segment_2& t) const
  {
    return Intersections::internal::do_intersect(p,t, SFK());
  }

  result_type
  operator()(const Segment_2& t, const Point_2 &p) const
  {
    return Intersections::internal::do_intersect(p,t, SFK());
  }

};
} // Static_filters_predicates
} // internal
} // CGAL
#endif
