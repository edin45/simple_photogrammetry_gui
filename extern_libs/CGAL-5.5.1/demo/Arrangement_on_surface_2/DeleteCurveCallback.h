// Copyright (c) 2012  Tel-Aviv University (Israel).
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org).
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Arrangement_on_surface_2/demo/Arrangement_on_surface_2/DeleteCurveCallback.h $
// $Id: DeleteCurveCallback.h 1d3815f 2020-10-02T17:29:03+02:00 Ahmed Essam
// SPDX-License-Identifier: GPL-3.0-or-later OR LicenseRef-Commercial
//
// Author(s)     : Alex Tsui <alextsui05@gmail.com>

#ifndef DELETE_CURVE_CALLBACK_H
#define DELETE_CURVE_CALLBACK_H

#include "Callback.h"

namespace demo_types
{
enum class TraitsType : int;
}

enum class DeleteMode
{
  DeleteOriginatingCuve,
  DeleteEdge,
};

/**
   Handles deletion of arrangement curves selected from the scene.

   The template parameter is a CGAL::Arrangement_with_history_2 of some type.
*/
class DeleteCurveCallbackBase : public CGAL::Qt::Callback
{
public:
  static DeleteCurveCallbackBase*
  create(demo_types::TraitsType, CGAL::Object arr_obj, QObject* parent);

  void setDeleteMode(DeleteMode deleteMode_) { this->deleteMode = deleteMode_; }
  DeleteMode getDeleteMode() { return this->deleteMode; }

protected:
  using CGAL::Qt::Callback::Callback;

  DeleteMode deleteMode;
};

#endif // DELETE_CURVE_CALLBACK_H
