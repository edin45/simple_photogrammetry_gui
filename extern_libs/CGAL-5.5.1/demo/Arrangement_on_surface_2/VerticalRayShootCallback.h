// Copyright (c) 2012, 2020 Tel-Aviv University (Israel).
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org).
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Arrangement_on_surface_2/demo/Arrangement_on_surface_2/VerticalRayShootCallback.h $
// $Id: VerticalRayShootCallback.h 1d3815f 2020-10-02T17:29:03+02:00 Ahmed Essam
// SPDX-License-Identifier: GPL-3.0-or-later OR LicenseRef-Commercial
//
// Author(s): Alex Tsui <alextsui05@gmail.com>
//            Ahmed Essam <theartful.ae@gmail.com>

#ifndef VERTICAL_RAY_SHOOT_CALLBACK_H
#define VERTICAL_RAY_SHOOT_CALLBACK_H

#include "Callback.h"
#include <CGAL/Object.h>

namespace demo_types
{
enum class TraitsType : int;
}

class QGraphicsSceneMouseEvent;
class QGraphicsScene;

/*
 * Supports visualization of vertical ray shooting on arrangements.
 */
class VerticalRayShootCallbackBase : public CGAL::Qt::Callback
{
public:
  static VerticalRayShootCallbackBase*
  create(demo_types::TraitsType, CGAL::Object arr_obj, QObject* parent);

  void setShootingUp( bool isShootingUp );

  virtual void setEdgeWidth( int width ) = 0;
  virtual void setEdgeColor( const QColor& color ) = 0;
  virtual const QColor& edgeColor( ) const = 0;
  virtual int edgeWidth( ) const = 0;

protected:
  VerticalRayShootCallbackBase( QObject* parent_ );
  bool shootingUp;
}; // class VerticalRayShootCallbackBase

#endif // VERTICAL_RAY_SHOOT_CALLBACK_H
