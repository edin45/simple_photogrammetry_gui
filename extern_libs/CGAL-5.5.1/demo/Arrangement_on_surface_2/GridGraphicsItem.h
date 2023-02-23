// Copyright (c) 2020 GeometryFactory Sarl (France).
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org).
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Arrangement_on_surface_2/demo/Arrangement_on_surface_2/GridGraphicsItem.h $
// $Id: GridGraphicsItem.h a30658a 2020-09-21T09:09:48+02:00 Ahmed Essam
// SPDX-License-Identifier: GPL-3.0-or-later OR LicenseRef-Commercial
//
// Author(s): Ahmed Essam <theartful.ae@gmail.com>

#ifndef ARRANGEMENT_DEMO_GRID_GRAPHICS_ITEM_H
#define ARRANGEMENT_DEMO_GRID_GRAPHICS_ITEM_H

#include <QColor>
#include <QGraphicsItem>

class QWidget;
class QPainter;
class QStyleOptionGraphicsItem;

class GridGraphicsItem : public QGraphicsItem
{
public:
  GridGraphicsItem();
  int getXPower5() const;
  int getXPower2() const;
  int getYPower5() const;
  int getYPower2() const;
  float getXUnit() const;
  float getYUnit() const;

  QColor getGridColor() const;
  QColor getAxesColor() const;
  QColor getLabelsColor() const;
  int getSpacing() const;

  void setGridColor(const QColor&);
  void setAxesColor(const QColor&);
  void setLabelsColor(const QColor&);
  void setSpacing(int);

protected:
  void paint(QPainter*, const QStyleOptionGraphicsItem*, QWidget*) override;
  QRectF viewportRect(QPainter*) const;
  QRectF viewportRect() const;
  QRectF boundingRect() const override;

private:
  QColor gridColor;
  QColor axesColor;
  QColor labelsColor;

  int spacing;
  int x_power5;
  int x_power2;
  int y_power5;
  int y_power2;
  float x_unit;
  float y_unit;
};

#endif // ARRANGEMENT_DEMO_GRID_GRAPHICS_ITEM_H
