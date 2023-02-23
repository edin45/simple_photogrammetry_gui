// Copyright (c) 2020 GeometryFactory Sarl (France).
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org).
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Arrangement_on_surface_2/demo/Arrangement_on_surface_2/Utils/EnvelopeFunctions.h $
// $Id: EnvelopeFunctions.h 1d3815f 2020-10-02T17:29:03+02:00 Ahmed Essam
// SPDX-License-Identifier: GPL-3.0-or-later OR LicenseRef-Commercial
//
// Author(s): Ahmed Essam <theartful.ae@gmail.com>

#ifndef ARRANGEMENT_DEMO_ENVELOPE_FUNCTIONS
#define ARRANGEMENT_DEMO_ENVELOPE_FUNCTIONS

#include <vector>
#include <CGAL/Envelope_diagram_1.h>

template <typename Arr_>
class EnvelopeFunctions
{
public:
  using Arrangement = Arr_;
  using Traits = typename Arrangement::Geometry_traits_2;
  using X_monotone_curve_2 = typename Arrangement::X_monotone_curve_2;
  using Diagram_1 = CGAL::Envelope_diagram_1<Traits>;

  void lowerEnvelope(Arrangement* arr, Diagram_1& diagram);
  void upperEnvelope(Arrangement* arr, Diagram_1& diagram);

private:
  std::vector<X_monotone_curve_2> getXMonotoneCurves(Arrangement* arr);
};

#endif
