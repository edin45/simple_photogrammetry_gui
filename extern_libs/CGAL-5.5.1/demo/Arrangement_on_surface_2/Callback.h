// Copyright (c) 2012, 2020 Tel-Aviv University (Israel).
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org).
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Arrangement_on_surface_2/demo/Arrangement_on_surface_2/Callback.h $
// $Id: Callback.h a30658a 2020-09-21T09:09:48+02:00 Ahmed Essam
// SPDX-License-Identifier: GPL-3.0-or-later OR LicenseRef-Commercial
//
// Author(s): Alex Tsui <alextsui05@gmail.com>
//            Ahmed Essam <theartful.ae@gmail.com>

#ifndef CGAL_QT_CALLBACK_H
#define CGAL_QT_CALLBACK_H

#include <QObject>
#include "GraphicsSceneMixin.h"

class QEvent;
class QKeyEvent;
class QGraphicsScene;
class QGraphicsSceneMouseEvent;

namespace CGAL {
namespace Qt {

class Callback : public QObject, public GraphicsSceneMixin
{
Q_OBJECT

public:
  Callback( QObject* parent, QGraphicsScene* scene_ = nullptr );
  virtual void reset( );
  virtual bool eventFilter( QObject* object, QEvent* event );

public Q_SLOTS:
  virtual void slotModelChanged( );

Q_SIGNALS:
  void modelChanged( );

protected:
  virtual void mousePressEvent( QGraphicsSceneMouseEvent* event );
  virtual void mouseMoveEvent( QGraphicsSceneMouseEvent* event );
  virtual void mouseReleaseEvent( QGraphicsSceneMouseEvent* event );
  virtual void keyPressEvent( QKeyEvent* event );
};

} // namespace Qt
} // namespace CGAL

#endif // CGAL_QT_CALLBACK_H
