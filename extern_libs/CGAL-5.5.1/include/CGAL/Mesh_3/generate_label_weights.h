// Copyright (c) 2021 GeometryFactory
// All rights reserved.
//
// This file is part of CGAL (www.cgal.org).
//
// $URL: https://github.com/CGAL/cgal/blob/v5.5.1/Mesh_3/include/CGAL/Mesh_3/generate_label_weights.h $
// $Id: generate_label_weights.h 5913be0 2022-03-22T12:13:42+01:00 Jane Tournois
// SPDX-License-Identifier: GPL-3.0-or-later OR LicenseRef-Commercial
//
//
// Author(s)     : Laurent Rineau, Jane Tournois

#ifndef CGAL_MESH_3_GENERATE_LABEL_WEIGHTS_H
#define CGAL_MESH_3_GENERATE_LABEL_WEIGHTS_H

#include <CGAL/license/Mesh_3.h>

#include <CGAL/Image_3.h>
#include <CGAL/ImageIO.h>

#include <itkImage.h>
#include <itkImageDuplicator.h>
#include <itkBinaryThresholdImageFilter.h>
#include <itkRecursiveGaussianImageFilter.h>
#include <itkMaximumImageFilter.h>

#include <iostream>
#include <vector>
#include <set>
#include <type_traits>

namespace CGAL {
namespace Mesh_3 {
namespace internal {

template<typename Image_word_type, typename LabelsSet>
void convert_image_3_to_itk(const CGAL::Image_3& image,
                            itk::Image<Image_word_type, 3>* const itk_img,
                            LabelsSet& labels)
{
  const double spacing[3] = {image.vx(), image.vy(), image.vz()};
  itk_img->SetSpacing(spacing);

  const double origin[3] =  {image.tx(), image.ty(), image.tz()};
  itk_img->SetOrigin(origin);

  using ImageType = itk::Image<Image_word_type, 3/*Dimension*/>;
  typename ImageType::IndexType  corner = {{0, 0, 0 }};
  typename ImageType::SizeType   size = {{image.xdim(), image.ydim(), image.zdim()}};
  typename ImageType::RegionType region(corner, size);
  itk_img->SetRegions(region);

  itk_img->Allocate();

  const Image_word_type* img_begin = static_cast<const Image_word_type*>(image.data());
  std::copy(img_begin, img_begin + image.size(), itk_img->GetBufferPointer());

  labels.insert(img_begin, img_begin + image.size());
}

#ifdef CGAL_MESH_3_WEIGHTED_IMAGES_DEBUG
template<typename Image_word_type>
int count_non_white_pixels(const CGAL::Image_3& image)
{
  auto diff255 = [&](const Image_word_type p)
  {
    return p != 255;
  };
  const Image_word_type* img_begin = static_cast<const Image_word_type*>(image.data());
  return std::count_if(img_begin,
                       img_begin + image.size(),
                       diff255);
}

template<typename Image_word_type>
int count_non_white_pixels(itk::Image<Image_word_type, 3>* itk_img)
{
  auto diff255 = [&](const Image_word_type p)
  {
    return p != 255;
  };
  auto size = itk_img->GetLargestPossibleRegion().GetSize();
  return std::count_if(itk_img->GetBufferPointer(),
                       itk_img->GetBufferPointer() + size[0]*size[1]*size[2],
                       diff255);
}
#endif //CGAL_MESH_3_WEIGHTED_IMAGES_DEBUG

template<typename Image_word_type>
WORD_KIND get_wordkind()
{
  if (std::is_floating_point<Image_word_type>::value)
    return WK_FLOAT;
  else
    return WK_FIXED;
/** unknown (uninitialized) */
//    WK_UNKNOWN
}

template<typename Image_word_type>
SIGN get_sign()
{
  if (std::is_signed<Image_word_type>::value)
    return SGN_SIGNED;
  else
    return SGN_UNSIGNED;
/** unknown (uninitialized or floating point words) */
//    SGN_UNKNOWN
}

}//namespace internal

/// @cond INTERNAL
template<typename Image_word_type>
CGAL::Image_3 generate_label_weights_with_known_word_type(const CGAL::Image_3& image,
                                                    const float& sigma)
{
  typedef unsigned char Weights_type; //from 0 t 255
  const std::size_t img_size = image.size();

  //create weights image
  _image* weights
    = _createImage(image.xdim(), image.ydim(), image.zdim(),
                   1,                                        //vectorial dimension
                   image.vx(), image.vy(), image.vz(),
                   sizeof(Weights_type),                     //image word size in bytes
                   internal::get_wordkind<Weights_type>(),   //image word kind WK_FIXED, WK_FLOAT, WK_UNKNOWN
                   internal::get_sign<Weights_type>());      //image word sign
  Weights_type* weights_ptr = (Weights_type*)(weights->data);
  std::fill(weights_ptr,
            weights_ptr + img_size,
            Weights_type(0));
  weights->tx = image.tx();
  weights->ty = image.ty();
  weights->tz = image.tz();

  //convert image to itkImage
  using ImageType = itk::Image<Image_word_type, 3/*Dimension*/>;
  using WeightsType = itk::Image<Weights_type, 3>;
  typename ImageType::Pointer itk_img = ImageType::New();
  std::set<Image_word_type> labels;
  internal::convert_image_3_to_itk(image, itk_img.GetPointer(), labels);

  using DuplicatorType = itk::ImageDuplicator<ImageType>;
  using IndicatorFilter = itk::BinaryThresholdImageFilter<ImageType, WeightsType>;
  using GaussianFilterType = itk::RecursiveGaussianImageFilter<WeightsType, WeightsType>;
  using MaximumImageFilterType = itk::MaximumImageFilter<WeightsType>;

  std::vector<typename ImageType::Pointer> indicators(labels.size());
  typename DuplicatorType::Pointer duplicator = DuplicatorType::New();
  duplicator->SetInputImage(itk_img);
  duplicator->Update();

  for (std::size_t id = 0; id < labels.size(); ++id)
  {
    if (id > 0)
    {
      duplicator->SetInputImage(indicators[id - 1]);
      duplicator->Update();
    }
    indicators[id] = duplicator->GetOutput();
  }

  int id = 0;
  typename WeightsType::Pointer blured_max = WeightsType::New();
  for (Image_word_type label : labels)
  {
#ifdef CGAL_MESH_3_WEIGHTED_IMAGES_DEBUG
    std::cout << "\nLABEL = " << label << std::endl;
#endif

    //compute "indicator image" for "label"
    typename IndicatorFilter::Pointer indicator = IndicatorFilter::New();
    indicator->SetInput(indicators[id]);
    indicator->SetOutsideValue(0);
    indicator->SetInsideValue(255);
    indicator->SetLowerThreshold(label);
    indicator->SetUpperThreshold(label);
    indicator->Update();

    //perform gaussian smoothing
    typename GaussianFilterType::Pointer smoother = GaussianFilterType::New();
    smoother->SetInput(indicator->GetOutput());
    smoother->SetSigma(sigma);
    smoother->Update();

    //take the max of smoothed indicator functions
    if (id == 0)
      blured_max = smoother->GetOutput();
    else
    {
      typename MaximumImageFilterType::Pointer maximumImageFilter = MaximumImageFilterType::New();
      maximumImageFilter->SetInput(0, blured_max);
      maximumImageFilter->SetInput(1, smoother->GetOutput());
      maximumImageFilter->Update();
      blured_max = maximumImageFilter->GetOutput();
    }

    id++;

#ifdef CGAL_MESH_3_WEIGHTED_IMAGES_DEBUG
    std::cout << "AFTER MAX (label = " << label << ") : " <<  std::endl;
    std::cout << "\tnon zero in max ("
      << label << ")\t= " << internal::count_non_white_pixels(blured_max.GetPointer()) << std::endl;
#endif
  }

  //copy pixels to weights
  std::copy(blured_max->GetBufferPointer(),
            blured_max->GetBufferPointer() + img_size,
            weights_ptr);

  CGAL::Image_3 weights_img(weights);

#ifdef CGAL_MESH_3_WEIGHTED_IMAGES_DEBUG
  std::cout << "non white in image \t= "
    << internal::count_non_white_pixels<Image_word_type>(image) << std::endl;
  std::cout << "non white in weights \t= "
    << internal::count_non_white_pixels<Weights_type>(weights_img) << std::endl;
  std::cout << "non white in itkWeights \t= "
    << internal::count_non_white_pixels<Weights_type>(blured_max.GetPointer()) << std::endl;
  _writeImage(weights, "weights-image.inr.gz");
#endif

  return weights_img;
}
/// @endcond

/*!
* \ingroup PkgMesh3Functions
* Free function that generates a `CGAL::Image_3` of weights associated to each
* voxel of `image`, to make the output mesh surfaces smoother.
* The weights image is generated using the algorithm described by Stalling et al
* in \cgalCite{stalling1998weighted}.
* The [Insight toolkit](https://itk.org/) is needed to compile this function.
*
* @param image the input labeled image from which the weights image is computed.
*   Both will then be used to construct a `Labeled_mesh_domain_3`.
* @param sigma the standard deviation parameter of the internal Gaussian filter
*
* @returns a `CGAL::Image_3` of weights used to build a quality `Labeled_mesh_domain_3`,
* with the same dimensions as `image`
*/

CGAL::Image_3 generate_label_weights(const CGAL::Image_3& image,
                               const float& sigma)
{
  CGAL_IMAGE_IO_CASE(image.image(),
    return generate_label_weights_with_known_word_type<Word>(image, sigma);
  );
  CGAL_error_msg("This place should never be reached, because it would mean "
    "the image word type is a type that is not handled by "
    "CGAL_ImageIO.");
  return CGAL::Image_3();
}

}//namespace Mesh_3
}//namespace CGAL

#endif // CGAL_MESH_3_GENERATE_LABEL_WEIGHTS_H
