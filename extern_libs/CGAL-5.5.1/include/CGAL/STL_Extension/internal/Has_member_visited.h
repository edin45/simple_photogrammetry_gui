// Copyright (c) 2017 GeometryFactory (France).
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org)
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/STL_Extension/include/CGAL/STL_Extension/internal/Has_member_visited.h $
// $Id: Has_member_visited.h 98e4718 2021-08-26T11:33:39+02:00 Sébastien Loriot
// SPDX-License-Identifier: LGPL-3.0-or-later OR LicenseRef-Commercial
//
// Author(s)     : Mael Rouxel-Labbé

#ifndef CGAL_HAS_MEMBER_VISITED_H
#define CGAL_HAS_MEMBER_VISITED_H

#include <boost/mpl/has_xxx.hpp>

namespace CGAL {
namespace internal {

  BOOST_MPL_HAS_XXX_TRAIT_NAMED_DEF(Has_member_visited,
                                    Has_visited_for_vertex_extractor,
                                    false)

} // end namespace internal
} // end namespace CGAL

#endif // CGAL_HAS_NESTED_TYPE_BARE_POINT_H
