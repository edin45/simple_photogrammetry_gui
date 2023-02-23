// Copyright (c) 2009  GeometryFactory (France)
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org).
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Kernel_23/include/CGAL/Projection_traits_3.h $
// $Id: Projection_traits_3.h dacbd18 2021-08-30T12:35:34+02:00 Sébastien Loriot
// SPDX-License-Identifier: LGPL-3.0-or-later OR LicenseRef-Commercial
//
//
// Author(s)     : Laurent Rineau


#ifndef CGAL_PROJECTION_TRAITS_3_H
#define CGAL_PROJECTION_TRAITS_3_H

#include <CGAL/Kernel_23/internal/Filtered_projection_traits_3.h>

namespace CGAL {

// This declaration is needed to break the cyclic dependency.
template < class Filtered_kernel >
class Filtered_projection_traits_3;

template <class Kernel, bool Has_filtered_predicates=Kernel::Has_filtered_predicates>
class Projection_traits_3
  : public Projection_traits_base_3<Kernel>
{
public:
  explicit Projection_traits_3(const typename Kernel::Vector_3& n_)
    : Projection_traits_base_3<Kernel>(n_)
  {}
};

template <class Kernel>
class Projection_traits_3<Kernel, true>
  : public Filtered_projection_traits_3<Kernel>
{
public:
  explicit Projection_traits_3(const typename Kernel::Vector_3& n_)
    : Filtered_projection_traits_3<Kernel>(n_)
  {}
};

} // namespace CGAL

#endif // CGAL_PROJECTION_TRAITS_3_H
