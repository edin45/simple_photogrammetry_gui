// Copyright (c) 2016 GeometryFactory (France).  All rights reserved.
//
// This file is part of CGAL (www.cgal.org)
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/BGL/include/CGAL/boost/graph/internal/Has_member_clear.h $
// $Id: Has_member_clear.h e5862bd 2022-04-21T13:59:43+02:00 Laurent Rineau
// SPDX-License-Identifier: LGPL-3.0-or-later OR LicenseRef-Commercial
//
// Author(s) : Philipp Moeller


#ifndef CGAL_HAS_MEMBER_CLEAR_H
#define CGAL_HAS_MEMBER_CLEAR_H

namespace CGAL {
namespace internal {

template<class T>
class Has_member_clear
{
private:
  template <class C>
  static auto f(int) -> decltype(std::declval<C>().clear(), char());

  template<class C>
  static int f(...);
public:
  static const bool value = (sizeof(f<T>(0)) == sizeof(char));
};

}  // internal
}  // cgal

#endif /* CGAL_HAS_MEMBER_CLEAR_H */
